//
//  CasesModel.swift
//  StockSafe
//
//  Created by David Jabech on 7/10/21.
//

import UIKit
import Firebase

enum ShelfLifeParameter {
    case newSL
    case noNewSL
    case eraseSL
    case doNotEraseSL
}

enum CaseExistsCheck {
    case alreadyExists
    case doesNotExist
}

enum CapacityCheck {
    case atMaxCapacity
    case notAtMaxCapacity
}

class CaseManager: ProductManager {
    
    // Variable representing the case limit for a given product's location
    public var limit: Int = 0
    
    // Variable representing the current number of cases in a given product's location
    public var currentCount: Int = 0
    
    // Array of tuples, each representing both an array of cases and their previous location
    public var undoQueue: [([Case], String)] = []
    
    // (Case to replace, slp, and location)
    private var casesQueue: ([Case], ShelfLifeParameter, String)?
    
    // Query firestore for data (cases)
    public func queryFirestore(parameters: (productName: String, location: String), completion: @escaping ([(Case, String)]) -> Void) {
        // Creating the array and dictionary for storing case information
        var cases: [(Case, String)] = []
        // Setting search parameters
        let searchRef = db.collection("testData")
            .whereField("product", isEqualTo: parameters.0)
            .whereField("location", isEqualTo: parameters.1)
            .whereField("userID", isEqualTo: userIDkey)
        
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
                    cases.sort(by: { $0.0 < $1.0 })
                    completion(cases)
                }
            }
        }
    }
    
    public func singleNewCaseAlgo(caseAttributes: (number: Int, productName: String, location: String), slp: ShelfLifeParameter, completion: @escaping (CaseExistsCheck, String?) -> Void) {
        casesQueue = ([], slp, caseAttributes.2)
        checkIfCaseExists(caseNumber: caseAttributes.0, productName: caseAttributes.1) { [self] existCheck, existingCase in
            switch existCheck {
            case .alreadyExists:
                casesQueue!.0.append(existingCase!)
                completion(existCheck, "Case \(String(describing: existingCase!.caseNumber)) already exists")
            case .doesNotExist:
                addCase(caseAttributes: caseAttributes, slp: slp) {
                    completion(existCheck, nil)
                }
            }
        }
    }
    
    public func multipleNewCasesAlgo(caseAttributes: (caseRange: [Int], name: String, location: String), slp: ShelfLifeParameter, completion: @escaping (String) -> Void) {
        casesQueue = ([], slp, caseAttributes.2)
        let group = DispatchGroup()
        for number in caseAttributes.0 {
            group.enter()
            checkIfCaseExists(caseNumber: number, productName: caseAttributes.1) { [self] existCheck, existingCase in
                switch existCheck {
                case .alreadyExists:
                    casesQueue!.0.append(existingCase!)
                    group.leave()
                case .doesNotExist:
                    addCase(caseAttributes: (number, caseAttributes.1, caseAttributes.2), slp: slp) {
                    group.leave()
                    }
                }
            }
        }
        group.notify(queue: DispatchQueue.main) { [self] in
            let aec_string = buildAECString()
            completion(aec_string)
        }
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
            for number in 0..<casesQueue!.0.count {
                group.enter()
                aec_string.append(String(describing: casesQueue!.0[number].caseNumber))
                if number < casesQueue!.0.count - 1 {
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

    public func addCase(caseAttributes: (number: Int, productName: String, location: String), slp: ShelfLifeParameter, completion: (() -> Void)?) {
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
                             userID: userIDkey)
        let _ = try? db.collection("testData").addDocument(from: caseToAdd) { error in
            if error != nil {
                print("Error writing document to Firestore: \(String(describing: error))")
            }
            else if let completion = completion {
                    completion()
                }
            }
        }

    
    public func checkIfCaseExists(caseNumber: Int, productName: String, completion: @escaping (CaseExistsCheck, Case?) -> Void) {
            db.collection("testData")
                .whereField("product", isEqualTo: productName)
                .whereField("caseNumber", isEqualTo: caseNumber)
                .whereField("userID", isEqualTo: userIDkey)
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
    
    public func archiveAndReplaceCase(caseToArchive: Case, slp: ShelfLifeParameter, location: String) {
        archiveCase(caseID: caseToArchive.id!) { [self] in
            addCase(caseAttributes: (number: caseToArchive.caseNumber, productName: caseToArchive.product, location: location), slp: slp, completion: nil)
        }
    }
    
    public func archiveAndReplaceMultipleCases(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        for caseToReplace in casesQueue!.0 {
            group.enter()
            archiveAndReplaceCase(caseToArchive: caseToReplace, slp: casesQueue!.1, location: casesQueue!.2)
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
    
    
    private func getExpirationDate(timestamp: Timestamp?) -> String {
        var expirationDate = ""
        if timestamp != nil {
            let timeStamp = (timestamp as AnyObject).dateValue()
            print("this is timestamp: \(timeStamp)")
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
        print("This is expirationDate: \(expirationDate)")
        return expirationDate
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
        let casesToUndo = undoQueue.last
        let group = DispatchGroup()
        for var caseIndex in casesToUndo!.0 {
            group.enter()
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) { [self] in
            undoQueue.removeLast()
            completion()
        }
    }
}

