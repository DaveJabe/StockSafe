//
//  ButtonExtensions.swift
//  StockSafe
//
//  Created by David Jabech on 8/14/21.
//

import UIKit

extension UIButton {
    
    // This func will enable/disable basic buttons depending on a Bool
    func toggle(on: Bool) {
        if on {
            isEnabled = true
            tintColor = .systemGray6
        }
        else {
            isEnabled = false
            tintColor = .darkGray
        }
    }
    
    // (SelectionView Button) This func will configure buttons for location and product selection on the CasesViewController (the buttons that animate the SelectionViews)
    func makeSVButton() {
        titleLabel!.font = boldFont(size: 20)
        setTitleColor(.black, for: .normal)
        
        addShadow()
        
        layer.masksToBounds = false
        layer.cornerRadius = 4.0
    }
    
    // This func provides a simple method for formatting a button with an SF Symbol
    func makeSFButton(symbolName: String, tintColor: HexColor, configuration: UIImage.SymbolConfiguration?) {
        if let configuration = configuration {
            setImage(UIImage(systemName: symbolName, withConfiguration: configuration), for: .normal)
        }
        else {
            setImage(UIImage(systemName: symbolName), for: .normal)
        }
        self.tintColor = tintColor
    }
}
