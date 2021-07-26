//
//  StockCasesModel.swift
//  StockSafe
//
//  Created by David Jabech on 7/10/21.
//

import UIKit
import Firebase

class StockManager: CaseManager {
    
    public func stockAlgorithm(cases: [Case], slp: ShelfLifeParameter, destination: String, completion: @escaping ((CapacityCheck, String?, [Case]?) -> Void)) {
        UserDefaults.standard.setValue(false, forKey: "SetLimitsKey") // temporary code in place until limits are implemented
        undoQueue.append((cases, cases[0].location))
        var sl_string: String?
        var casesWithSL: [Case]?
        
        if UserDefaults.standard.bool(forKey: "SetLimitsKey") {
            if checkForCapacity(selectedCases: cases) == .atMaxCapacity {
                completion(.atMaxCapacity, nil, nil)
            }
        }
        let group = DispatchGroup()
        for caseToStock in cases {
            group.enter()
            stockCase(caseToStock: caseToStock, destination: destination, slp: slp)
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
            if let casesWithSL = casesWithSL {
                for index in 0..<casesWithSL.count {
                    sl_string?.append(String(describing: casesWithSL[index].caseNumber))
                    if index < casesWithSL.count - 1 {
                        sl_string?.append(", ")
                    }
                    if index == casesWithSL.count - 2 {
                        sl_string?.append("and ")
                    }
                }
            completion(.notAtMaxCapacity, sl_string, casesWithSL)
            }
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
