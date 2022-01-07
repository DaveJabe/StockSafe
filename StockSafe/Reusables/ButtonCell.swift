//
//  ButtonCell.swift
//  StockSafe
//
//  Created by David Jabech on 7/16/21.
//

import UIKit

class ButtonCell: UITableViewCell {
    
    static let identifier = "ButtonCellIdentifier"
    
    public let button = UIButton()
    
    public let title: UILabel = {
        let label = UILabel()
        label.font = standardFont(size: 30)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(title)
        contentView.addSubview(button)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .systemGray5
        title.frame = CGRect(x: 15,
                             y: 0,
                             width: title.intrinsicContentSize.width,
                             height: contentView.frame.size.height)
        title.addSubtleShadow()
        button.frame = CGRect(x: (contentView.frame.size.width)-((contentView.bounds.width/7)*1.7),
                              y: (contentView.frame.size.height/3)-((contentView.bounds.height-20)/5),
                              width: contentView.bounds.width/7,
                              height: contentView.bounds.height-20)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 10
    }
    
    public func configureButton(title: String?, backgroundColor: HexColor?, action: UIAction?) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        if let action = action {
            button.addAction(action, for: .touchUpInside)
        }
    }
}
