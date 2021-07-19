//
//  HomeViewController.swift
//  Stocked.
//
//  Created by David Jabech on 3/11/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import Lottie

let vckey = "vckey"
let loggedIn = "loggedIn"
var userIDkey = UserDefaults.standard.value(forKey: "UserID") as? String ?? ""

class HomeViewController: UIViewController {
    
    var db = Firestore.firestore()
    
    @IBOutlet var newCasesButton: UIButton!
    
    @IBOutlet var stockCasesButton: UIButton!
    
    @IBOutlet var yourLocationsButton: UIButton!
    
    @IBOutlet var yourProductsButton: UIButton!
    
    private func autoArchive() {
        let weekday = Calendar.current.dateComponents([.weekday], from: Date()).weekday
        
        if weekday != 1 {
            db.collection("cases")
                .whereField("userID", isEqualTo: userIDkey)
                .whereField("location", isEqualTo: "Breading Table")
                .getDocuments() { querySnapshot, err in
                    if err != nil {
                        print("Error in autoarchive (1): \(String(describing: err))")
                    }
                    else {
                        for document in querySnapshot!.documents {
                            var breadingStamp = document.get("breadingStamp")
                            breadingStamp = (breadingStamp as AnyObject).dateValue()
                            if (breadingStamp as! Date) < Calendar.current.date(byAdding: .day, value: -1, to: Date())! {
                                document.reference.delete()
                                print("document successfully deleted")
                            }
                        }
                    }
                }
        }
    }
    
    @objc private func pushLogInScreen() {
        let loginvc = storyboard?.instantiateViewController(withIdentifier: "login") as? LoginViewController
        self.navigationController?.pushViewController(loginvc!, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        VD.addShadow(view: newCasesButton)
        VD.addShadow(view: stockCasesButton)
        VD.addShadow(view: yourLocationsButton)
        VD.addShadow(view: yourProductsButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        let loginKey = UserDefaults.standard.bool(forKey: "LoginKey")
        
        if !loginKey || userIDkey == "" {
            pushLogInScreen()
        }
        else {
            let autoArchiveCheck = UserDefaults.standard.bool(forKey: "AutoArchiveKey")
            if autoArchiveCheck {
                autoArchive()
                print("autoArchiving...")
            }
        }
    }
}


