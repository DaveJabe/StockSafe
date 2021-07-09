//
//  CreateAccountViewController.swift
//  Stocked.
//
//  Created by David Jabech on 4/21/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class CreateAccountViewController: UIViewController {
    
    var db: Firestore!
    
    @IBOutlet var lengthLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var uppercaseLabel: UILabel!
    @IBOutlet var debuggerLabel: UILabel!
    
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var reenterPasswordTF: UITextField!
    
    @IBAction func createAccountButton(_ sender: UIButton) {
        
        let matchCheck = checkMatching(password1: passwordTF.text!, password2: reenterPasswordTF.text!)
        let upperCaseCheck = checkForUpperCase(password: passwordTF.text!)
        let numberCheck = checkForNumber(password: passwordTF.text!)
        let lengthCheck = checkLength(password: passwordTF.text!)
        
        if !matchCheck {
            debuggerLabel.text = "Passwords do not match."
        }
        else if !upperCaseCheck {
            debuggerLabel.text = "Password must include an uppercase letter."
        }
        else if !numberCheck {
            debuggerLabel.text = "Password must contain one number."
        }
        else if !lengthCheck {
            debuggerLabel.text = "Password must be at least 8 characters long."
        }
        if matchCheck && numberCheck && upperCaseCheck && lengthCheck {
            let accountCreation = UIAlertController(title: "Account Created!",
                                                    message: nil,
                                                    preferredStyle: .alert)
            accountCreation.addAction(UIAlertAction(title: "Heard on that.",
                                                    style: .default,
                                                    handler: {
                                                        [self] (action) in self.navigationController?.popToRootViewController(animated: true)
                                                    } ))
            createUser { [self] () -> () in
                Auth.auth().signIn(withEmail: emailTF.text!, password: passwordTF.text!) { [weak self] authResult, error in
                    guard let strongSelf = self else { return }
                    if let error = error {
                        print("Error signing in: \(error)")
                        debuggerLabel.text = "Account Creation Failed"
                    }
                    else {
                        userIDkey = Auth.auth().currentUser!.uid as String
                        UserDefaults.standard.setValue(true, forKey: "LoginKey")
                        createUserInfo()
                        present(accountCreation, animated: true)
                    }
                }
            }
        }
    }
    
    func checkMatching(password1: String, password2: String) -> Bool {
        if password1 == password2 {
            return true
        }
        else {
            return false
        }
    }
    
    func checkForUpperCase(password: String) -> Bool {
        var strength: Bool = false
        let upperCaseRegEx = ".*[A-Z]+.*"
        let upperCaseTest = NSPredicate(format: "SELF MATCHES %@", upperCaseRegEx)
        strength = upperCaseTest.evaluate(with: password)
        return strength
    }
    
    func checkForNumber(password: String) -> Bool {
        var numberCheck: Bool = false
        let numberRegEx = ".*[0-9]+.*"
        let numberTest = NSPredicate(format: "SELF MATCHES %@", numberRegEx)
        numberCheck = numberTest.evaluate(with: password)
        return numberCheck
    }
    
    func checkLength(password: String) -> Bool {
        var lengthCheck: Bool = false
        if password.count >= 8 {
            lengthCheck = true
        }
        else {
            lengthCheck = false
        }
        return lengthCheck
    }
    
    func createUser(completion: @escaping () -> Void) {
        Auth.auth().createUser(withEmail: emailTF.text!, password: passwordTF.text!) { authResult, error in
            if let error = error {
                print("Error creating account \(error)")
            }
            else {
                completion()
            }
        }
    }
    
    
    func createUserInfo() {
        
        let limitsDictionary: [String:Int] = ["filetTC" : 0,
                                              "spicyTC" : 0,
                                              "nuggetTC" : 0,
                                              "stripTC" : 0,
                                              "gfiletTC" : 0,
                                              "gnuggetTC" : 0,
                                              "bfiletTC" : 0,
                                              "filetBT" : 0,
                                              "spicyBT" : 0,
                                              "nuggetBT" : 0,
                                              "stripBT" : 0,
                                              "gfiletBT" : 0,
                                              "gnuggetBT" : 0,
                                              "bfiletBT" : 0]
        
        db.collection("userInfo").addDocument(data: ["autoArchive" : false,
                                                     "dateJoined" : Timestamp.init(),
                                                     "limitsOn" : false,
                                                     "limits" : limitsDictionary,
                                                     "userEmail" : Auth.auth().currentUser!.email! as String,
                                                     "userName" : "",
                                                     "userID" : Auth.auth().currentUser!.uid as String
                                                    
        ])
    }
    
    func changeTextColor() {
        if checkForUpperCase(password: passwordTF.text!) {
            uppercaseLabel.textColor = .green
        }
        else {
            uppercaseLabel.textColor = .red
        }
        if checkLength(password: passwordTF.text!) {
            lengthLabel.textColor = .green
        }
        else {
            lengthLabel.textColor = .red
        }
        if checkForNumber(password: passwordTF.text!) {
            numberLabel.textColor = .green
        }
        else {
            numberLabel.textColor = .red
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if
            view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height/2)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
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
        
        emailTF.placeholder = "Email"
        passwordTF.placeholder = "Password"
        reenterPasswordTF.placeholder = "Confirm Password"
        
        passwordTF.addAction(UIAction(handler: { [self] (action) in changeTextColor() } ), for: .allEditingEvents)
        
        debuggerLabel.textColor = .systemRed
        debuggerLabel.text = ""
    }

}
