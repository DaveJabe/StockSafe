//
//  FieldCell.swift
//  Stocked.
//
//  Created by David Jabech on 4/23/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class FieldCell: UITableViewCell {
    
    var db: Firestore!
    
    static let identifier = "fieldCellidentifier"
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 15)
        return label
    }()
    
    private var textField: UITextField = {
        let textfield = UITextField()
        textfield.font = UIFont(name: "Avenir", size: 15)
        textfield.borderStyle = .roundedRect
        return textfield
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier:  reuseIdentifier)
        
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        contentView.addSubview(label)
        contentView.addSubview(textField)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 15, y: 0, width: 200, height: contentView.frame.size.height)
        textField.frame = CGRect(x: 100, y: 7, width: 200, height: contentView.frame.size.height - 15)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textField.tag = 0
        textField.text = ""
        
    }
    
    @objc func setDefaults() {
        let uid = Auth.auth().currentUser?.uid
        switch textField.tag {
        case 1: UserDefaults.standard.setValue(textField.text!, forKey: "UserNameKey")
            db.collection("userInfo").whereField("userID", isEqualTo: uid!)
                .getDocuments() { [self] (querySnapshot, err) in
                    if let err = err {
                        print("error in setDefaults: \(err)")
                    }
                    else {
                        for document in querySnapshot!.documents {
                            document.reference.updateData(["userName" : textField.text!])
                        }
                    }
                    
                }
            print("default set")
        case 2: UserDefaults.standard.setValue(textField.text!, forKey: "StoreNumberKey")
            db.collection("userInfo").whereField("userID", isEqualTo: uid!)
                .getDocuments() { [self] (querySnapshot, err) in
                    if let err = err {
                        print("error in setDefaults: \(err)")
                    }
                    else {
                        for document in querySnapshot!.documents {
                            document.reference.updateData(["storeNumber" : textField.text!])
                        }
                    }
                    
                }
        default: print("error")
            
        }
    }
    
    public func configure(with model: AccountInfoFieldOption) {
        textField.tag = model.tfTag
        textField.text = model.textField.text
        textField.addTarget(self, action: #selector(setDefaults), for: .editingChanged)
        label.text = model.title
        
    }
}
