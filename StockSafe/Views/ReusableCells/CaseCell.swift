//
//  CaseCell.swift
//  StockSafe
//
//  Created by David Jabech on 7/18/21.
//

import UIKit

class CaseCell: UITableViewCell {

    static let identifier = "CaseCellIdentifier"
        
    public var numberLabel: UILabel = {
        let label = UILabel()
        label.font = VD.standardFont(size: 20)
        VD.addSubtleShadow(view: label)
        label.textAlignment = .center
        return label
    }()
    
    public var productLabel: UILabel = {
        let label = UILabel()
        label.font = VD.standardFont(size: 20)
        VD.addSubtleShadow(view: label)
        label.textAlignment = .left
        return label
    }()
    
    public var shelfLifeLabel: UILabel = {
        let label = UILabel()
        label.font = VD.standardFont(size: 20)
        VD.addSubtleShadow(view: label)
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(numberLabel)
        contentView.addSubview(productLabel)
        contentView.addSubview(shelfLifeLabel)
        
        accessoryType = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        numberLabel.frame = CGRect(x: 0, y: 0, width: 50, height: contentView.frame.size.height)
        productLabel.frame = CGRect(x: 70, y: 0, width: 257, height: contentView.frame.size.height)
        shelfLifeLabel.frame = CGRect(x: 470, y: 0, width: 193, height: contentView.frame.size.height)
    }
}
