//
//  ProductCell.swift
//  Stocked.
//
//  Created by David Jabech on 4/19/21.
//

import UIKit

class ProductCell: UITableViewCell {
    
    static let identifier = "productCellIdentifier"
    
    private var label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 15)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        accessoryType = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 15, y: 0, width: 200, height: contentView.frame.size.height)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    public func configure(with model: SetLimitsProductOption) {
        label.text = model.title
    }
}
