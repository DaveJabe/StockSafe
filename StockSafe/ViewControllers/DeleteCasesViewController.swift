//
//  DeleteCasesViewController.swift
//  Pods
//
//  Created by David Jabech on 4/17/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class DeleteCasesViewController: UIViewController {

    var db: Firestore!
    
    @IBAction func deleteCasesButton(_ sender: UIButton) {
        let areYouSure = UIAlertController(title: "Are you sure you want to delete all cases?", message: "This action cannot be undone.", preferredStyle: .alert)
        let noThanks = UIAlertAction(title: "No thanks.", style: .default, handler: nil)
        let sure = UIAlertAction(title: "Yes, I'm sure.", style: .default, handler: { (action) in
            self.deleteCases()
                                 })
        areYouSure.addAction(noThanks)
        areYouSure.addAction(sure)
        present(areYouSure, animated: true)
    }
    
    func deleteCases() {
        
        let caseRef = db.collection("cases")
            .whereField("userID", isEqualTo: userIDkey)
        
        caseRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("error in deleteCases func: \(err)")
            }
            else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
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

       
    }
    
}
