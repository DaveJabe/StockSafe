//
//  Constants.swift
//  StockSafe
//
//  Created by David Jabech on 8/14/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

// This struct holds and will continue to add constants relevant to the app
struct Constants {
    
    @UserDefault(key: UserDefaults.Keys.userID, defaultValue: "")
    static var userID: String
    
    struct AlertComponents {
        static let heard = UIAlertAction(title: "Heard on that.",
                                  style: .default,
                                  handler: nil)
        
    }
    
    struct SymbolConfigs {
        static let largeSymbolConfig = UIImage.SymbolConfiguration.init(scale: .large)
        
        static let toolbarSymbolConfig = UIImage.SymbolConfiguration(pointSize: 60)
    }
    
    struct StoryboardIdentifiers {
        static let mainVC = "MainViewController"
        
        static let loginVC = "LoginViewController"
        
        static let createAccountVC = "CreateAccountViewController"
        
        static let addProductVC = "AddProductViewController"
        
        static let addLocationVC = "AddLocationViewController"
        
        static let colorSelectVC = "ColorSelectViewController"
    }
    
    // `db` variable used to interact with Firestore
    // var db: Firestore!
    
}
