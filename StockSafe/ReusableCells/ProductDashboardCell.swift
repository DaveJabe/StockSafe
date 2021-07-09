//
//  ProductDashboardCell.swift
//  StockSafe
//
//  Created by David Jabech on 7/7/21.
//

import UIKit

class ProductDashboardCell: UICollectionViewCell {
    
    static let identifier = "productDashboardCell"

    public var productTextView: UITextView = {
        let textView = UITextView()
        return textView
    }()
    
    public var addProductButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(productTextView)
        contentView.addSubview(addProductButton)
        addProductButton.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureCell()
    }
    private func configureCell() {
        layer.masksToBounds = true
        layer.borderColor = UIColor.green.cgColor
        layer.cornerRadius = 6.0
        contentView.layer.cornerRadius = 6.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOpacity = 0.5
        let shadowPath = CGPath(ellipseIn: CGRect(x: 0,
                                                    y: contentView.frame.maxY,
                                                    width: contentView.layer.bounds.width + 20 * 2,
                                                    height: 20),
                                transform: nil)
                
        contentView.layer.shadowPath = shadowPath
        productTextView.font = UIFont(name: "Avenir Heavy", size: 25)
        productTextView.backgroundColor = .clear
        productTextView.textColor = .darkText
        productTextView.textAlignment = .center
        productTextView.centerVerticalText()
        productTextView.isEditable = false
        productTextView.isSelectable = false
        
        addProductButton.imageView?.image = UIImage(systemName: "plus.app.fill")
        addProductButton.imageView?.image?.withTintColor(.green)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
