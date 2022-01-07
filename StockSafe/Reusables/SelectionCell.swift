//
//  ProductDashboardCell.swift
//  StockSafe
//
//  Created by David Jabech on 7/7/21.
//

import UIKit

class SelectionCell: UICollectionViewCell {
    
    static let identifier = "selectionCell"

    public var itemTitle: UITextView = {
        let textView = UITextView()
        return textView
    }()
    
    public var addProductButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(itemTitle)
        contentView.addSubview(addProductButton)
        addProductButton.isHidden = true
        configureCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    private func configureCell() {
        layer.borderColor = UIColor.green.cgColor
        layer.cornerRadius = 6.0
        contentView.configureItemView()
        
        itemTitle.font = boldFont(size: 25)
        itemTitle.backgroundColor = .clear
        itemTitle.textColor = .darkText
        itemTitle.textAlignment = .center
        itemTitle.isEditable = false
        itemTitle.isSelectable = false
        
        addProductButton.imageView?.image = UIImage(systemName: "plus.app.fill")
        addProductButton.imageView?.image?.withTintColor(.green)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
