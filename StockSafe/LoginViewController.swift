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
            Login { [self] in
                if Auth.auth().currentUser?.uid != nil {
                    print("Login Successful")
                    print("UserID = \(Constants.userID)")
                    setDefaults {
                        guard let sceneDel = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
                        guard let mainVC = storyboard?.instantiateViewController(withIdentifier: Constants.StoryboardIdentifiers.mainVC) as? MainViewController else { return }
                        sceneDel.window?.setRootViewController(viewController: mainVC)
                    }
                }
                else {
                    debuggerLabel.text = "Login Failed."
                }
            }
        }
    }
    
    func Login(completion: @escaping () -> Void) {
        
        if emailTF.text != "" && passwordTF.text != "" {
            Auth.auth().signIn(withEmail: emailTF.text!, password: passwordTF.text!) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    print("Error logging in: \(error)")
                    strongSelf.debuggerLabel.text = "Login Failed"
                }
                else {
                    completion()
                }
            }
        }
    }
    
    func setDefaults(completion: @escaping () -> Void) {
        Constants.userID = Auth.auth().currentUser!.uid
        print("UserIDkey: \(String(describing: Constants.userID))")
        
        let reference = db.collection("userInfo").whereField("userID", isEqualTo: Constants.userID)
        
        reference.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error in setDefaults: \(err)")
            }
            else {
                for document in querySnapshot!.documents {
                    let name = document.get("userName") ?? ""
                    let email = String((Auth.auth().currentUser?.email!)!)
                    
                    let formatter = DateFormatter()
                    formatter.dateStyle = .short
                    var dateJoined = document.get("dateJoined")
                    dateJoined = (dateJoined as AnyObject).dateValue()
                    dateJoined = formatter.string(from: dateJoined as! Date)
                    
                    UserDefaults.standard.setValue(name, forKey: "UserNameKey")
                    UserDefaults.standard.setValue(email, forKey: "UserEmailKey")
                    UserDefaults.standard.setValue(dateJoined, forKey: "DateJoinedKey")
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
        debuggerLabel.text = ""
        debuggerLabel.textColor = .systemRed
        
    }
}
