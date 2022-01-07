//
//  HistoryManager.swift
//  StockSafe
//
//  Created by David Jabech on 8/15/21.
//

import Foundation
import Firebase
import FirebaseFirestore

class HistoryManager: ColleagueProtocol {
    var mediator: MediatorProtocol?
    
    var db: Firestore!
    
    init() {
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
    }
    
    func setMediator(mediator: MediatorProtocol) {
        self.mediator = mediator
    }
    
    func addHistory(type: HistoryType, name: String, option: HistoryOption, quantity: Int?) {
        db.collection("")
    }
    
    
}
