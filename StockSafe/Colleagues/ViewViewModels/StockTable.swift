//
//  StockTable.swift
//  StockSafe
//
//  Created by David Jabech on 7/10/21.
//

import UIKit

class StockTable: CaseTable {
    
    public var selectedCases = [Case]()
    
    override func setMediator(mediator: MediatorProtocol) {
        self.mediator = mediator
        noCasesLabel.frame = bounds
        
        buildHeader()
        
        delegate = self
        dataSource = self
        allowsSelection = true
        allowsMultipleSelection = true
    }

}

extension StockTable {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row was selected")
        selectedCases.append(cases[indexPath.row].0)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedCases.removeAll(where: {$0 == cases[indexPath.row].0} )
    }
}
