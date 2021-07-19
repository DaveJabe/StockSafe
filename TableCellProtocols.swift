//
//  TableCellProtocols.swift
//  StockSafe
//
//  Created by David Jabech on 7/16/21.
//

import UIKit

enum TextFieldCellType {
    case textField
    case pickerTextField
}

protocol TextFieldCellDelegate: AnyObject {
    func returnText(senderTag: Int, text: String)
}

protocol EPTFCDelegate: AnyObject {
    func readyForReload(numOfTextFields: Int, currentSelections: [Int:String])
    
    func updateSelections(selections: [Int:String])
}
