//
//  CasesModel.swift
//  StockSafe
//
//  Created by David Jabech on 7/10/21.
//

import UIKit
import Firebase
import FirebaseFirestore

enum ShelfLifeParameter {
    case newSL
    case noNewSL
    case eraseSL
    case doNotEraseSL
    case nonexistantSL
}

enum UndoParameter {
    case undo(from: String, to: String)
    case undoArchive(from: String)
    case undoNewCases(to: String)
}

enum CaseExistsCheck {
    case alreadyExists
    case doesNotExist
}

enum CapacityCheck {
    case atMaxCapacity
    case notAtMaxCapacity
}

enum CaseSortParameter {
    case byNumber
    case byExpiryDate
    case byDateAdded
    // case alphabetical <- this is for when case naming is implemented
}

class CaseManager: ProductManager {
    
    // Variable representing the case limit for a given product's location
    public var limit: Int = 0
    
    // Variable representing the current number of cases in a given product's location
    public var currentCount: Int = 0
    
    // Array of tuples, each representing an array of cases, their previous location, and shelfLifeParam for undoing
    public var undoQueue: [([Case], ShelfLifeParameter, UndoParameter)] = []
    
    // Array of tuples, each representing an array of cases, their previous location, and shelfLifeParam for redoing
    public var redoQueue: [([Case], ShelfLifeParameter, UndoParameter)] = []
    
    // Bool used to determine whether the cases that the user is trying to undo need to be added back in
    private var archived: Bool = false
    
    // (Case to replace, slp, and location)
    private var casesQueue: ([Case], ShelfLifeParameter, String)?
    
    // Query firestore for data (cases)
    public func queryFirestore(parameters: (productName: String, locationName: String), sort: CaseSortParameter?, completion: @escaping ([(Case, String)]) -> Void) {
        // Creating the array of tuples, each storing a Case and it's corresponding expiry date string
        var cases: [(Case, String)] = []
        // Setting search parameters
        let searchRef = db.collection("testData")
            .whereField("product", isEqualTo: parameters.0)
            .whereField("location", isEqualTo: parameters.1)
            .whereField("userID", isEqualTo: Constants.userID)
        
        searchRef.getDocuments() { [self] querySnapshot, err in
            if err != nil {
                print("Error getting documents - CasesManager.swift in `queryFirestore()`): \(String(describing: err))")
            }
            else {
                guard let documents = querySnapshot?.documents else {
                    print("no documents found - CasesManager.swift in `queryFirestore()`")
                    return
                }
                currentCount = documents.count
                limit = UserDefaults.standard.integer(forKey: "\(parameters.0)LimitKey")
                let group = DispatchGroup()
                for document in documents {
                    group.enter()
                    do {
                        let caseKey = try document.data(as: Case.self)
                        let expiryDate = getExpirationDate(timestamp: caseKey!.shelfLife)
                        cases.append((caseKey!, expiryDate))
                        group.leave()
                    }
                    catch let error {
                        print("Error reading document (case) from Firestore: \(error)")
                    }
                }
                group.notify(queue: DispatchQueue.main) {
                        switch sort {
                        case .byExpiryDate:
                            cases.sort(by: { $0.0.shelfLife?.dateValue() ?? Date() > $1.0.shelfLife?.dateValue() ?? Date() })
                        case .byDateAdded:
                            cases.sort(by: { $0.0.entryDate.dateValue() < $1.0.entryDate.dateValue()})
                        default:
                            cases = cases.sorted(by: { $0.0 < $1.0})
                        }
                    completion(cases)
                }
            }
        }
    }
    
    public func singleNewCaseAlgo(caseAttributes: (caseNumber: Int, productName: String, locationName: String), slp: ShelfLifeParameter, completion: @escaping (CaseExistsCheck, String?) -> Void) {
        casesQueue = ([], slp, caseAttributes.2)
        checkIfCaseExists(caseNumber: caseAttributes.0, productName: caseAttributes.1) { [self] existCheck, existingCase in
            switch existCheck {
            case .alreadyExists:
                casesQueue!.0.append(existingCase!)
                completion(existCheck, "Case \(String(describing: existingCase!.caseNumber)) already exists")
            case .doesNotExist:
                addCase(caseAttributes: caseAttributes, slp: slp) {
                    addNewCasesToUndoQueue(caseAttributes: (caseRange: [caseAttributes.0], productName: caseAttributes.1, locationName: caseAttributes.2), slp: slp)
                    completion(existCheck, nil)
                }
            }
        }
    }
    
    public func multipleNewCasesAlgo(caseAttributes: (caseRange: [Int], productName: String, locationName: String), slp: ShelfLifeParameter, completion: @escaping (String) -> Void) {
        casesQueue = ([], slp, caseAttributes.2)
        let group = DispatchGroup()
        for number in caseAttributes.0 {
            group.enter()
            checkIfCaseExists(caseNumber: number, productName: caseAttributes.1) { [self] existCheck, existingCase in
                switch existCheck {
                case .alreadyExists:
                    casesQueue!.0.append(existingCase!)
                case .doesNotExist:
                    addCase(caseAttributes: (number, caseAttributes.1, caseAttributes.2), slp: slp) {
                    }
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) { [self] in
            let aec_string = buildAECString()
            addNewCasesToUndoQueue(caseAttributes: caseAttributes, slp: slp)
            completion(aec_string)
        }
    }
    
    public func addCase(caseAttributes: (caseNumber: Int, productName: String, locationName: String), slp: ShelfLifeParameter, completion: (() -> Void)?) {
        var shelfLifeBegins: Timestamp?
        switch slp {
        case .newSL:
            shelfLifeBegins = Timestamp()
        case .noNewSL:
            shelfLifeBegins = nil
        default:
            print("Error in NewCaseViewController.swift - addCase()")
        }
        let caseToAdd = Case(product: caseAttributes.1,
                             location: caseAttributes.2,
                             caseNumber: caseAttributes.0,
                             entryDate: Timestamp(),
                             shelfLife: shelfLifeBegins,
                             userID: Constants.userID)
        let _ = try? db.collection("testData").addDocument(from: caseToAdd) { error in
            if error != nil {
                print("Error writing document to Firestore: \(String(describing: error))")
            }
            else if let completion = completion {
                completion()
            }
        }
    }
    
    public func addNewCasesToUndoQueue(caseAttributes: (caseRange: [Int], productName: String, locationName: String), slp: ShelfLifeParameter) {
        var lastAddedCases = [Case]()
        let group = DispatchGroup()
        for number in caseAttributes.0 {
            group.enter()
            checkIfCaseExists(caseNumber: number, productName: caseAttributes.1) { _, addedCase in
                if let addedCase = addedCase {
                    lastAddedCases.append(addedCase)
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) { [self] in
            undoQueue.append((lastAddedCases, slp, .undoNewCases(to: caseAttributes.2)))
        }
    }
    
    
    public func checkIfCaseExists(caseNumber: Int, productName: String, completion: @escaping (CaseExistsCheck, Case?) -> Void) {
        db.collection("testData")
            .whereField("product", isEqualTo: productName)
            .whereField("caseNumber", isEqualTo: caseNumber)
            .whereField("userID", isEqualTo: Constants.userID)
            .getDocuments() { querySnapshot, err in
                if querySnapshot!.documents.count != 0 {
                    let existingCase = try? querySnapshot!.documents[0].data(as: Case.self)
                    completion(.alreadyExists, existingCase)
                }
                else {
                    completion(.doesNotExist, nil)
                }
            }
    }
    
    public func archiveCase(caseID: String, completion: @escaping () -> Void) {
        let document = db.collection("testData").document(caseID)
        document.delete { error in
            if error != nil {
                print("Error deleting document from Firestore: \(String(describing: error))")
            }
            completion()
        }
    }
    
    public func archiveAndReplaceCase(caseToArchive: Case, slp: ShelfLifeParameter, location: String, completion: @escaping () -> Void) {
        archiveCase(caseID: caseToArchive.id!) { [self] in
            addCase(caseAttributes: (caseNumber: caseToArchive.caseNumber, productName: caseToArchive.product, locationName: location), slp: slp) {
                completion()
            }
        }
    }
    
    // This function works for a single case as well, it archives/replaces all cases added to casesQueue
    public func archiveAndReplaceMultipleCases(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        for caseToReplace in casesQueue!.0 {
            group.enter()
            archiveAndReplaceCase(caseToArchive: caseToReplace, slp: casesQueue!.1, location: casesQueue!.2) {
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
    
    
    private func getExpirationDate(timestamp: Timestamp?) -> String {
        var expirationDate = ""
        if timestamp != nil {
            let timeStamp = (timestamp as AnyObject).dateValue()
            let offsetDate = Calendar.current.date(byAdding: .hour, value: -4, to: Date())
            
            let components = Calendar.current.dateComponents([.day], from: timeStamp, to: offsetDate!)
            let hourComponents = Calendar.current.dateComponents([.hour], from: timeStamp, to: offsetDate!)
            
            let daysRemaining = 4 - components.day!
            let hoursRemaining = 96 - hourComponents.hour!
            
            if daysRemaining == 1 {
                expirationDate = "Expires in 1 day"
            }
            else if daysRemaining < 1 {
                if hoursRemaining <= 0 {
                    expirationDate = "Expired"
                }
                else {
                    expirationDate = "Expires in \(hoursRemaining) hours"
                }
            }
            else if daysRemaining > 1 {
                expirationDate = "Expires in \(daysRemaining) days"
            }
        }
        return expirationDate
    }
    
    private func buildAECString() -> String {
        var aec_string = ""
        if casesQueue!.0.count > 0 {
            if casesQueue!.0.count == 1 {
                aec_string.append("Case ")
            }
            else {
                aec_string.append("Cases ")
            }
            let group = DispatchGroup()
            var sortedCases = casesQueue!.0.map { $0.caseNumber }
            sortedCases.sort()
            for number in 0..<casesQueue!.0.count {
                group.enter()
                aec_string.append(String(describing: sortedCases[number]))
                if number < sortedCases.count - 1 && sortedCases.count != 1 && sortedCases.count != 2 {
                    aec_string.append(", ")
                }
                if number == casesQueue!.0.count - 2 {
                    aec_string.append("and ")
                }
                group.leave()
            }
            if casesQueue!.0.count == 1 {
                aec_string.append(" already exists")
            }
            else {
                aec_string.append(" already exist")
            }
        }
        return aec_string
    }
    
    public func checkForCapacity(selectedCases: [Case]) -> (CapacityCheck) {
        if currentCount == limit {
            return .atMaxCapacity
        }
        else if currentCount + selectedCases.count > limit {
            return .atMaxCapacity
        }
        else {
            return .notAtMaxCapacity
        }
    }
    
    public func undo(completion: @escaping () -> Void) {
        let casesToUndo = undoQueue.last!
        redoQueue.append(casesToUndo)
        switch casesToUndo.2 {
        case .undo(let from, _):
            if casesToUndo.1 == .newSL {
                for caseToUndo in casesToUndo.0 {
                    db.collection("testData").document(caseToUndo.id!).updateData(["location" : from,
                                                                                   "shelfLife" : FieldValue.delete()])
                }
            }
            else if casesToUndo.1 == .eraseSL {
                for caseToUndo in casesToUndo.0 {
                    db.collection("testData").document(caseToUndo.id!).updateData(["location" : from,
                                                                                   "shelfLife" : caseToUndo.shelfLife!])
                }
            }
            else {
                for caseToUndo in casesToUndo.0 {
                    db.collection("testData").document(caseToUndo.id!).updateData(["location" : from])
                }
            }
        case .undoArchive:
            for caseToUndo in casesToUndo.0 {
                let _ = try? db.collection("testData").document(caseToUndo.id!).setData(from: caseToUndo) { error in
                    if error != nil {
                        print("Error undoing archived case: \(String(describing: error))")
                    }
                }
            }
        case .undoNewCases:
            for caseToUndo in casesToUndo.0 {
                db.collection("testData").document(caseToUndo.id!).delete()
            }
        }
        undoQueue.removeLast()
        completion()
    }
    
    public func redo(completion: () -> Void) {
        let casesToRedo = redoQueue.last!
        
        switch casesToRedo.2 {
        case .undo(_, let to):
            if casesToRedo.1 == .newSL {
                for caseToRedo in casesToRedo.0 {
                    db.collection("testData").document(caseToRedo.id!).updateData(["location" : to,
                                                                                   "shelfLife" : caseToRedo.shelfLife!])
                }
            }
            else if casesToRedo.1 == .eraseSL {
                for caseToRedo in casesToRedo.0 {
                    db.collection("testData").document(caseToRedo.id!).updateData(["location" : to,
                                                                                   "shelfLife" : FieldValue.delete()])
                }
            }
            else {
                for caseToRedo in casesToRedo.0 {
                    db.collection("testData").document(caseToRedo.id!).updateData(["location" : to])
                }
            }
        case .undoArchive:
            for caseToRedo in casesToRedo.0 {
                db.collection("testData").document(caseToRedo.id!).delete()
            }
        case .undoNewCases:
            for caseToRedo in casesToRedo.0 {
                let _ = try? db.collection("testData").document(caseToRedo.id!).setData(from: caseToRedo) { error in
                    if error != nil {
                        print("Error undoing archived case: \(String(describing: error))")
                    }
                }
            }
        }
        redoQueue.removeLast()
        completion()
    }
    
    public func stockAlgorithm(cases: [Case], slp: ShelfLifeParameter, destination: [Int:String], product: Product, completion: @escaping ((CapacityCheck, String, [Case]) -> Void)) {
        UserDefaults.standard.setValue(false, forKey: "SetLimitsKey") // temporary code in place until limits are implemented
        
        var sl_string =  String()
        var casesWithSL = [Case]()
        var stockedCases = [Case]()
        
        if UserDefaults.standard.bool(forKey: "SetLimitsKey") {
            if checkForCapacity(selectedCases: cases) == .atMaxCapacity {
                completion(.atMaxCapacity, sl_string, casesWithSL)
            }
        }
        
        let group = DispatchGroup()
        for caseToStock in cases {
            group.enter()
            if destination.first!.value == "Archive" {
                stockCase(caseToStock: caseToStock, destination: destination.first!.value, slp: slp)
                stockedCases.append(caseToStock)
                group.leave()
            }
            else if slp != .nonexistantSL {
                if caseToStock.shelfLife != nil && (product.shelfLife?.startingPoint.first?.key)! > destination.first!.key && slp == .noNewSL {
                    casesWithSL.append(caseToStock)
                    group.leave()
                }
                else if slp == .eraseSL {
                    db.collection("testData").document(caseToStock.id!).getDocument() { [self] document, error in
                        let stockedCase = try? document?.data(as: Case.self)
                        stockedCases.append(stockedCase!)
                        stockCase(caseToStock: caseToStock, destination: destination.first!.value, slp: slp)
                        group.leave()
                    }
                }
                else {
                    stockCase(caseToStock: caseToStock, destination: destination.first!.value, slp: slp)
                    db.collection("testData").document(caseToStock.id!).getDocument() { document, error in
                        let stockedCase = try? document?.data(as: Case.self)
                        stockedCases.append(stockedCase!)
                        group.leave()
                    }
                }
            }
            else {
                stockCase(caseToStock: caseToStock, destination: destination.first!.value, slp: slp)
                db.collection("testData").document(caseToStock.id!).getDocument() { document, error in
                    let stockedCase = try? document?.data(as: Case.self)
                    stockedCases.append(stockedCase!)
                    group.leave()
                }
            }
        }
        group.notify(queue: DispatchQueue.main) { [self] in
            for index in 0..<casesWithSL.count {
                sl_string.append(String(describing: casesWithSL[index].caseNumber))
                if index < casesWithSL.count - 1 {
                    sl_string.append(", ")
                }
                if index == casesWithSL.count - 2 {
                    sl_string.append("and ")
                }
            }
            if destination.first!.value == "Archive" {
                undoQueue.append((stockedCases, slp, .undoArchive(from: cases[0].location)))
                print(undoQueue)
            }
            else {
                undoQueue.append((stockedCases, slp, .undo(from: cases[0].location, to: destination.first!.value)))
                print(undoQueue[0].0.count)
            }
            completion(.notAtMaxCapacity, sl_string, casesWithSL)
        }
    }
    
    private func stockCase(caseToStock: Case, destination: String, slp: ShelfLifeParameter) {
        let document = db.collection("testData").document(caseToStock.id!)
        
        if slp == .newSL {
            document.updateData(["location" : destination,
                                 "shelfLife" : Timestamp()]) { error in
                if error != nil {
                    print("Error updating data in stockCase() -- .newSL: \(String(describing: error))")
                }
            }
        }
        else if slp == .noNewSL || slp == .doNotEraseSL {
            if destination == "Archive" {
                document.delete()
            }
            else {
                document.updateData(["location" : destination])
            }
            
        }
        else if slp == .eraseSL {
            document.updateData(["location" : destination,
                                 "shelfLife" : FieldValue.delete()]) { error in
                if error != nil {
                    print("Error updating data in stockCase() -- .eraseSL: \(String(describing: error))")
                }
            }
        }
    }
}

