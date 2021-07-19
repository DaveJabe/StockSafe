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
        allowsSelection = true
        allowsMultipleSelection = true
    }
}

extension StockTable {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCases.append(sortedCases[indexPath.row])
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedCases.removeAll(where: {$0 == sortedCases[indexPath.row]} )
    }
}
