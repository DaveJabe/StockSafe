//
//  SignOutCell.swift
//  Stocked.
//
//  Created by David Jabech on 4/22/21.
//

import UIKit
import Firebase

class SignOutCell: UITableViewCell {

    static let identifier = "signoutcellidentifier"
    
    @objc public func signOut(_ sender: UIButton!) {
        do { try Auth.auth().signOut() }
        catch { print("error") }
        UserDefaults.standard.setValue(false, forKey: "LoginKey")
        UserDefaults.standard.setValue("", forKey: "UserID")
        userIDkey = ""
        print("signedOut")
   }
    
    var signOutButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(signOutButton)
        contentView.bringSubviewToFront(signOutButton)
        signOutButton.isHidden = false
        signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        signOutButton.frame = CGRect(x: contentView.bounds.width - 230,
                                     y: contentView.bounds.height - 40,
                                     width: 200,
                                     height: 35)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.setTitleColor(.systemBlue, for: .normal)
        signOutButton.titleLabel?.font = UIFont(name: "Avenir", size: 20)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
