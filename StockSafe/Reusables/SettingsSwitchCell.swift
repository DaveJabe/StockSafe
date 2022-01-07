//
//  SettingsSwitchCell.swift
//  StockSafe
//
//  Created by David Jabech on 8/6/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class SettingsSwitchCell: UITableViewCell {
    static let identifier = "settingsSwitchCell"
    
    var db: Firestore!
    
    @objc func switchWasTapped(_ sender: UISwitch!) -> Bool {
       return true
    }
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let mySwitch: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.tintColor = .blue
        return mySwitch
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        contentView.addSubview(label)
        contentView.clipsToBounds = true
        contentView.addSubview(mySwitch)
        accessoryType = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size: CGFloat = contentView.frame.size.height - 12
        iconContainer.frame = CGRect(x: 15, y: 10, width: size-5, height: size-5)
        iconImageView.frame = CGRect(x: 0.75, y: 0.25, width: iconContainer.frame.size.width-2, height: iconContainer.frame.size.height-2)
        label.frame = CGRect(x: 25+iconContainer.frame.size.width,
                             y: 0,
                             width: contentView.frame.size.width-15-iconContainer.frame.size.width,
                             height: contentView.frame.size.height)
        mySwitch.sizeToFit()
        mySwitch.frame = CGRect(x: (contentView.frame.size.width-mySwitch.frame.size.width)-15,
                                y: (contentView.frame.size.height-mySwitch.frame.size.height)/2,
                                width: mySwitch.frame.size.width,
                                height: mySwitch.frame.size.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        iconContainer.backgroundColor = nil
        mySwitch.isOn = false
    }
    
    public func configure(with model: SettingsSwitchOption) {
        label.text = model.title
        iconImageView.image = model.icon
        iconContainer.backgroundColor = model.backgroundColor
        mySwitch.isOn = model.isOn
        mySwitch.addTarget(self, action: #selector(switchWasTapped), for: UIControl.Event.valueChanged)
    }
}
