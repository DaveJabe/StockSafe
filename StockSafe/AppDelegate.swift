//
//  AppDelegate.swift
//  Stocked.
//
//  Created by David Jabech on 3/11/21.
//

import UIKit
import Firebase
import FirebaseFirestore

@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configures Firebase for this application
        FirebaseApp.configure()
        
        // Loads the currently set ColorTheme (set using UserDefaults)
        ColorThemes.loadTheme(themeID: ColorThemes.currentThemeID)
        
        // Sets the userID in the Constants file for later retrieval. If there is no current userID, this will signal to SceneDelegate to launch with the LoginViewController
        Constants.userID = Auth.auth().currentUser?.uid ?? ""
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

