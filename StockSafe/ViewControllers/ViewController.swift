//
//  ViewController.swift
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

class ViewController: UIViewController {
    
    var db = Firestore.firestore()
    
    private let animationView = AnimationView(animation: Animation.named("orangeAlert"))
           
    @IBOutlet var expiredCasesButtonView: UIView!
    
    @objc private func setUpAnimation() {
        animationView.loopMode = .loop
        animationView.contentMode = .scaleToFill
        animationView.isHidden = true
        expiredCasesButtonView.addSubview(animationView)
        expiredCasesButtonView.bringSubviewToFront(animationView)
        animationView.frame = CGRect(x: expiredCasesButtonView.frame.size.width-70, y: -30, width: 100, height: 100)

        let offsetDate = Calendar.current.date(byAdding: .day, value: -4, to: Date())
        let expiredCasesRef = db.collection("cases")
            .whereField("shelfLife", isLessThanOrEqualTo: offsetDate!)
            .whereField("userID", isEqualTo: userIDkey)
        
        expiredCasesRef.getDocuments() { [self] querySnapshot, err in
            if err != nil {
                print("Error in expiredCasesRef: \(String(describing: err))")
            }
            else {
                if querySnapshot!.isEmpty {
                    animationView.isHidden = true
                }
                else {
                    animationView.isHidden = false
                    animationView.play()
                    print("not empty snapshot")
                }
            }
        }
}
    
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
    
    private func newStockingData() {
        db.collection("stockingData")
            .whereField("userID", isEqualTo: userIDkey)
            .whereField("date", isEqualTo: Date())
            .getDocuments() { [self] querySnapshot, err in
                if err != nil {
                    print("Error getting documents in newStockingData: \(String(describing: err))")
                }
                else {
                    if querySnapshot!.documents.count == 0 {
                        let stockingHistory = StockingData(date: Date(), history: [], userID: userIDkey)
                        do {
                            let _ = try db.collection("stockingData").addDocument(from: stockingHistory)
                        }
                        catch {
                            print("Error adding document to Firestore in newStockingData")
                        }
                    }
                }
            }
    }
    
    @objc private func pushLogInScreen() {
        let loginvc = storyboard?.instantiateViewController(withIdentifier: "login") as? LoginViewController
        self.navigationController?.pushViewController(loginvc!, animated: true)
    }
    
    @objc private func reloadViewController() {
        print("reloading ViewController")
        viewDidLoad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setUpAnimation), name: NSNotification.Name(vckey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadViewController), name: NSNotification.Name(loggedIn), object: nil)
    
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
            newStockingData()
            setUpAnimation()
            let autoArchiveCheck = UserDefaults.standard.bool(forKey: "AutoArchiveKey")
            if autoArchiveCheck {
                autoArchive()
                print("autoArchiving...")
            }
        }
    }
}


