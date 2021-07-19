//
//  StockCasesModel.swift
//  StockSafe
//
//  Created by David Jabech on 7/10/21.
//

import UIKit

class StockManager: CaseManager {
    
    public func stockAlgorithm(cases: [Case], slp: ShelfLifeParameter, destination: String, completion: @escaping ((CapacityCheck, String?, [Case]?) -> Void)) {
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
            switch slp {
            case .replace:
                stockCase(caseID: caseToStock.id!, destination: destination, newShelfLife: true)
            case .doNotReplace:
                stockCase(caseID: caseToStock.id!, destination: destination, newShelfLife: false)
            default:
                casesWithSL?.append(caseToStock)
            }
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
            }
            completion(.notAtMaxCapacity, sl_string, casesWithSL)
        }
    }
    
    private func stockCase(caseID: String, destination: String, newShelfLife: Bool) {
        let document = db.collection("testData").document(caseID)
        if newShelfLife {
            document.updateData(["location" : destination,
                                 "shelfLife" : Date()])
        }
        else if destination == "Archive" {
            document.delete()
        }
        else {
            document.updateData(["location" : destination])
        }
    }
}
