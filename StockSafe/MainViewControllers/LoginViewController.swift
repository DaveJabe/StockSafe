//
//  LoginViewController.swift
//  Stocked.
//
//  Created by David Jabech on 4/20/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class LoginViewController: UIViewController {
    
    var db: Firestore!
    
    @IBAction func tappedOutside(_ sender: UITapGestureRecognizer) {
        emailTF.resignFirstResponder()
        passwordTF.resignFirstResponder()
    }
    @IBOutlet var debuggerLabel: UILabel!
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    
    @IBAction func loginButton(_ sender: UIButton) {
        if emailTF.text == "" {
            debuggerLabel.text = "Please enter a valid email."
        }
        else if passwordTF.text == "" {
            debuggerLabel.text = "Please enter a password."
        }
        else {
            Login { [self] () -> () in
                if Auth.auth().currentUser?.uid != nil {
                    setDefaults { () -> () in
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
                else {
                    debuggerLabel.text = "Login Failed."
                }
            }
        }
    }
    
    func Login(completion: @escaping () -> Void) {
        
        if emailTF.text! != "" && passwordTF.text! != "" {
            Auth.auth().signIn(withEmail: emailTF.text!, password: passwordTF.text!) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    print("Error logging in: \(error)")
                    self!.debuggerLabel.text = "Login Failed"
                }
                else {
                    completion()
                }
            }
        }
    }
    
    func setDefaults(completion: @escaping () -> Void) {
        print("setDefaults works")
            UserDefaults.standard.setValue(true, forKey: "LoginKey")
            userIDkey = Auth.auth().currentUser!.uid as String
            UserDefaults.standard.setValue(userIDkey, forKey: "UserID")
            print("UserIDkey: \(String(describing: userIDkey))")
            
            let reference = db.collection("userInfo").whereField("userID", isEqualTo: userIDkey)
            
            reference.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error in setDefaults: \(err)")
                }
                else {
                    for document in querySnapshot!.documents {
                        let name = document.get("userName") ?? ""
                        let email = String((Auth.auth().currentUser?.email!)!)
                        let storeNumber = document.get("storeNumber") ?? ""
                        let autoArchive = document.get("autoArchive")
                        
                        let formatter = DateFormatter()
                        formatter.dateStyle = .short
                        var dateJoined = document.get("dateJoined")
                        dateJoined = (dateJoined as AnyObject).dateValue()
                        dateJoined = formatter.string(from: dateJoined as! Date)
                        
                        let limitsOn = document.get("limitsOn")
                        let filetTC = document.get("limits.filetTC")
                        let spicyTC = document.get("limits.spicyTC")
                        let nuggetTC = document.get("limits.nuggetTC")
                        let stripTC = document.get("limits.stripTC")
                        let gfiletTC = document.get("limits.gfiletTC")
                        let gnuggetTC = document.get("limits.gnuggetTC")
                        let bfiletTC = document.get("limits.bfiletTC")
                        let filetBT = document.get("limits.filetBT")
                        let spicyBT = document.get("limits.spicyBT")
                        let nuggetBT = document.get("limits.nuggetBT")
                        let stripBT = document.get("limits.stripBT")
                        let gfiletBT = document.get("limits.gfiletBT")
                        let gnuggetBT = document.get("limits.gnuggetBT")
                        let bfiletBT = document.get("limits.bfiletBT")
                        
                        UserDefaults.standard.setValue(name, forKey: "UserNameKey")
                        UserDefaults.standard.setValue(email, forKey: "UserEmailKey")
                        UserDefaults.standard.setValue(storeNumber, forKey: "StoreNumberKey")
                        UserDefaults.standard.setValue(dateJoined, forKey: "DateJoinedKey")
                        UserDefaults.standard.setValue(autoArchive, forKey:"AutoArchiveKey")
                        
                        UserDefaults.standard.setValue(limitsOn, forKey: "SetLimitsKey")
                        UserDefaults.standard.setValue(filetTC, forKey: "tc_filet")
                        UserDefaults.standard.setValue(spicyTC, forKey: "tc_spicy")
                        UserDefaults.standard.setValue(nuggetTC, forKey: "tc_nugget")
                        UserDefaults.standard.setValue(stripTC, forKey: "tc_strip")
                        UserDefaults.standard.setValue(gfiletTC, forKey: "tc_gfilet")
                        UserDefaults.standard.setValue(gnuggetTC, forKey: "tc_gnugget")
                        UserDefaults.standard.setValue(bfiletTC, forKey: "tc_bfilet")
                        UserDefaults.standard.setValue(filetBT, forKey: "bt_filet")
                        UserDefaults.standard.setValue(spicyBT, forKey: "bt_spicy")
                        UserDefaults.standard.setValue(nuggetBT, forKey: "bt_nugget")
                        UserDefaults.standard.setValue(stripBT, forKey: "bt_strip")
                        UserDefaults.standard.setValue(gfiletBT, forKey: "bt_gfilet")
                        UserDefaults.standard.setValue(gnuggetBT, forKey: "bt_gnugget")
                        UserDefaults.standard.setValue(bfiletBT, forKey: "bt_bfilet")
                        
                    }
                }
            }
            completion()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if
            view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            NotificationCenter.default.post(name: Notification.Name(rawValue: vckey), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: loggedIn), object: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true

        Firestore.firestore().settings = settings
        // [END setup]
            db = Firestore.firestore()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        emailTF.placeholder = "Email"
        passwordTF.placeholder = "Password"
        debuggerLabel.text = ""
        debuggerLabel.textColor = .systemRed
        
    }
}
