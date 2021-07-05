//
//  LimitCell.swift
//  Stocked.
//
//  Created by David Jabech on 4/19/21.
//

import UIKit
import Firebase

class LimitCell: UITableViewCell, UITextFieldDelegate {
    
    var db: Firestore!
    
    static let identifier = "limitCellIdentifier"
    
    private var TFtag: String = ""
    
    @objc func setLimitKey() {
        if limitTextField.text! != "" {
        db.collection("userInfo").whereField("userID", isEqualTo: userIDkey)
            .getDocuments() { [self] (querySnapshot, err) in
                if let err = err {
                    print("error in setLimitKey: \(err)")
                }
                else {
                    for document in querySnapshot!.documents {
                        
                        switch TFtag {
                        case "textFieldFilet":
                            UserDefaults.standard.setValue(Int(limitTextField.text!), forKey: "tc_filet")
                            document.reference.updateData(["limits.filetTC" : Int(limitTextField.text!)!])
                        case "textFieldSpicy":
                            UserDefaults.standard.setValue(Int(limitTextField.text!), forKey: "tc_spicy")
                            document.reference.updateData(["limits.spicyTC":Int(limitTextField.text!)!])
                        case "textFieldNugget":
                            UserDefaults.standard.setValue(Int(limitTextField.text!), forKey: "tc_nugget")
                            document.reference.updateData(["limits.nuggetTC":Int(limitTextField.text!)!])
                        case "textFieldStrip":
                            UserDefaults.standard.setValue(Int(limitTextField.text!), forKey: "tc_strip")
                            document.reference.updateData(["limits.stripTC":Int(limitTextField.text!)!])
                        case "textFieldGFilet":
                            UserDefaults.standard.setValue(Int(limitTextField.text!), forKey: "tc_gfilet")
                            document.reference.updateData(["limits.gfiletTC":Int(limitTextField.text!)!])
                        case "textFieldGNugget":
                            UserDefaults.standard.setValue(Int(limitTextField.text!), forKey: "tc_gnugget")
                            document.reference.updateData(["limits.gnuggetTC":Int(limitTextField.text!)!])
                        case "textFieldBFilet":
                            UserDefaults.standard.setValue(Int(limitTextField.text!), forKey: "tc_bfilet")
                            document.reference.updateData(["limits.bfiletTC":Int(limitTextField.text!)!])
                        case "textFieldFilet2":
                            UserDefaults.standard.setValue(Int(limitTextField.text!), forKey: "bt_filet")
                            document.reference.updateData(["limits.filetBT":Int(limitTextField.text!)!])
                        case "textFieldSpicy2":
                            UserDefaults.standard.setValue(Int(limitTextField.text!), forKey: "bt_spicy")
                            document.reference.updateData(["limits.spicyBT":Int(limitTextField.text!)!])
                        case "textFieldNugget2":
                            UserDefaults.standard.setValue(Int(limitTextField.text!), forKey: "bt_nugget")
                            document.reference.updateData(["limits.nuggetBT":Int(limitTextField.text!)!])
                        case "textFieldStrip2":
                            UserDefaults.standard.setValue(Int(limitTextField.text!), forKey: "bt_strip")
                            document.reference.updateData(["limits.stripBT":Int(limitTextField.text!)!])
                        case "textFieldGFilet2":
                            UserDefaults.standard.setValue(Int(limitTextField.text!), forKey: "bt_gfilet")
                            document.reference.updateData(["limits.gfiletBT":Int(limitTextField.text!)!])
                        case "textFieldGNugget2":
                            UserDefaults.standard.setValue(Int(limitTextField.text!), forKey: "bt_gnugget")
                            document.reference.updateData(["limits.gnuggetBT":Int(limitTextField.text!)!])
                        case "textFieldBFilet2":
                            UserDefaults.standard.setValue(Int(limitTextField.text!), forKey: "bt_bfilet")
                            document.reference.updateData(["limits.bfiletBT":Int(limitTextField.text!)!])
                        default: print("error in setlimitkey switch")
                        }
                    }
                }
            }
        }
    }
    
    private var limitTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private var limitIndicator: UILabel = {
        let label = UILabel()
        label.text = "Limit: "
        label.font = UIFont(name: "Avenir", size: 15)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        contentView.addSubview(limitIndicator)
        contentView.addSubview(limitTextField)
        limitTextField.delegate = self
        limitTextField.addTarget(self, action: #selector(setLimitKey), for: UIControl.Event.editingChanged)
        accessoryType = .none
     
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        limitIndicator.frame = CGRect(x: 15, y: 0, width: 100, height: contentView.frame.size.height)
        limitTextField.frame = CGRect(x: 100, y: 7, width: 200, height: contentView.frame.size.height - 15)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return (string.rangeOfCharacter(from: CharacterSet.letters) == nil)
    }
    
    public func configure(with model: SetLimitsOption) {
        limitTextField.text = model.textfield.text
        TFtag = model.textfieldTag
    }
}
