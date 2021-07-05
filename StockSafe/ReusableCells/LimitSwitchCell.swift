//
//  LimitSwitchCell.swift
//  Stocked.
//
//  Created by David Jabech on 4/19/21.
//

import UIKit

class LimitSwitchCell: UITableViewCell {
    
    static let identifier = "limitSwitchCellidentifier"
    
    @objc func switchWasTapped() {
        if mySwitch.isOn {
            UserDefaults.standard.setValue(true, forKey: "SetLimitsKey")
        }
        else {
            UserDefaults.standard.setValue(false, forKey: "SetLimitsKey")
        }
    }
    
    private var switchLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 15)
        label.text = "Turn limits on/off"
        return label
    }()
    
    private var mySwitch: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.isOn = false
        return mySwitch
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(switchLabel)
        contentView.addSubview(mySwitch)
        accessoryType = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switchLabel.frame = CGRect(x: 15, y: 0, width: 150, height: contentView.frame.size.height)
        mySwitch.sizeToFit()
        mySwitch.frame = CGRect(x: 150, y: 7, width: mySwitch.frame.size.width, height: mySwitch.frame.size.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        switchLabel.text = nil
        mySwitch.isOn = false
    }
    
    public func configure(with model: LimitSwitchOption) {
        switchLabel.text = model.title
        mySwitch.isOn = model.isOn
        mySwitch.addTarget(self, action: #selector(switchWasTapped), for: UIControl.Event.valueChanged)
    }
}
