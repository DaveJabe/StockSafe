//
//  AddButton.swift
//  StockSafe
//
//  Created by David Jabech on 7/14/21.
//

import UIKit

class SFButton: UIButton {

    // Intializer intented for CGRect, SF symbol image, and .systemColor
    init(frame: CGRect, sfImage: UIImage, color: UIColor) {
        super.init(frame: frame)
        self.frame = frame
        self.setImage(sfImage, for: .normal)
        self.tintColor = color
    }
        
        required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
    }
    
}
