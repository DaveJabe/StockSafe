//
//  ColorThemes.swift
//  StockSafe
//
//  Created by David Jabech on 8/12/21.
//

import Foundation

struct ColorThemes {
    
    static let greenThemeID = "Green Theme "
    
    static let blueThemeID = "Blue Theme"
    
    static let themeTitles = [greenThemeID, blueThemeID]
    
    static let themeColors = [HexColor("1E6F5C")!, HexColor("001E6C")!]
    
    @UserDefault(key: UserDefaults.Keys.currentTheme, defaultValue: greenThemeID)
    static var currentThemeID: String
    
    static var backgroundColor: HexColor = .systemGray6
    static var textColor: HexColor = .systemGray6
    static var foregroundColor1: HexColor = HexColor("1E6F5C")!
    static var foregroundColor2: HexColor = HexColor("289672")!
    static var foregroundColor3: HexColor = HexColor("29BB89")!
    
    static func greenTheme() {
        UserDefaults.standard.setValue(greenThemeID, forKey: "CurrentColorTheme")
        backgroundColor = .systemGray6
        textColor = .systemGray6
        foregroundColor1 = HexColor("1E6F5C")!
        foregroundColor2 = HexColor("289672")!
        foregroundColor3 = HexColor("29BB89")!
    }
    
    static func blueTheme() {
        UserDefaults.standard.setValue(blueThemeID, forKey: "CurrentColorTheme")
        backgroundColor = .systemGray6
        textColor = .systemGray6
        foregroundColor1 = HexColor("001E6C")!
        foregroundColor2 = HexColor("035397")!
        foregroundColor3 = HexColor("5089C6")!
    }
    
    static func loadTheme(themeID: String?) {
        if let themeID = themeID {
            switch themeID {
            case greenThemeID:
                greenTheme()
            case blueThemeID:
                blueTheme()
            default:
                print("Error in ColorThemes")
            }
        }
        else {
            greenTheme()
        }
    }
}
