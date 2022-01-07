//
//  UserDefault.swift
//  StockSafe
//
//  Created by David Jabech on 8/14/21.
//

import Foundation

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    let container: UserDefaults = .standard
    
    var wrappedValue: Value {
        get {
            container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key)
        }
    }
}

extension UserDefaults {
    public enum Keys {
        static let currentTheme = "CurrentColorTheme"
        
        static let userID = "UserID"
    }
}
