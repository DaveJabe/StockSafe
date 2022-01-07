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
        
        let matchCheck = passwordTF.checkIfMatches(string: reenterPasswordTF.text)
        let upperCaseCheck = passwordTF.checkForUpperCase()
        let numberCheck = passwordTF.checkForNumber()
        let lengthCheck = passwordTF.checkLength(minimum: 8)
        
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
                        Constants.userID = Auth.auth().currentUser!.uid as String
                        createUserInfo()
                        present(accountCreation, animated: true)
                    }
                }
            }
        }
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
        
        db.collection("userInfo").addDocument(data: ["autoArchive" : false,
                                                     "dateJoined" : Timestamp.init(),
                                                     "limitsOn" : false,
                                                     "userEmail" : Auth.auth().currentUser!.email! as String,
                                                     "userName" : "",
                                                     "userID" : Auth.auth().currentUser!.uid as String
                                                    
        ])
    }
    
    func changeTextColor() {
        if passwordTF.checkForUpperCase() {
            uppercaseLabel.textColor = .green
        }
        else {
            uppercaseLabel.textColor = .red
        }
        if passwordTF.checkLength(minimum: 8) {
            lengthLabel.textColor = .green
        }
        else {
            lengthLabel.textColor = .red
        }
        if passwordTF.checkForNumber() {
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
