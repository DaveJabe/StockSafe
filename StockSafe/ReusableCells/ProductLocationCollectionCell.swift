//
//  ProductCollectionCell.swift
//  Stocked.
//
//  Created by David Jabech on 5/29/21.
//

import UIKit

class ProductLocationCollectionCell: UICollectionViewCell {
    
    static let identifier = "ProductLocationCollectionCell"
    
    public let selectionLabel = UITextView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        contentView.addSubview(selectionLabel)
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
        selectionLabel.font = UIFont(name: "Avenir Heavy", size: 25)
        selectionLabel.backgroundColor = .clear
        selectionLabel.textColor = .darkText
        selectionLabel.textAlignment = .center
        selectionLabel.isEditable = false
        selectionLabel.isSelectable = false
    }
    
    public func configureCellColor() {
        switch selectionLabel.text! {
        case "Filet":
            contentView.backgroundColor = UIColor(red: 0, green: 1, blue: 1, alpha: 0.6)
        case "Spicy":
            contentView.backgroundColor = UIColor(red: 0.65, green: 0, blue: 1, alpha: 0.6)
        case "Nugget":
            contentView.backgroundColor = UIColor(red: 1, green: 0.70, blue: 0.70, alpha: 0.6)
        case "Strip":
            contentView.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.6)
        case "Grilled Filet":
            contentView.backgroundColor = UIColor(red: 0.65, green: 0.65, blue: 0, alpha: 0.6)
        case "Grilled Nugget":
            contentView.backgroundColor = UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 0.6)
        case "Breakfast Filet":
            contentView.backgroundColor = UIColor(red: 0.90, green: 1, blue: 0, alpha: 0.6)
        case "Freezer":
            contentView.backgroundColor = HexColor("126e82", alpha: 0.6)
        case "Thawing Cabinet":
            contentView.backgroundColor = HexColor("7eca9c", alpha: 0.6)
        case "Breading Table":
            contentView.backgroundColor = HexColor("f0c929", alpha: 0.6)
        case "Archive":
            contentView.backgroundColor = HexColor("c15050", alpha: 0.6)
        default:
            print("Error in configureCellColor: ProductLocationCollectionViewCell")
        }
    }
}

extension UITextView {

    func centerVerticalText() {
        self.textAlignment = .center
        let fitSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fitSize)
        let calculate = (bounds.size.height - size.height * zoomScale) / 2
        let offset = max(1, calculate)
        contentOffset.y = -offset
    }
}
