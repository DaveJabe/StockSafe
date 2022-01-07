//
//  InputRestrictions.swift
//  StockSafe
//
//  Created by David Jabech on 8/14/21.
//

import UIKit

enum TextFieldType {
    case textField
    case pickerTextField
}

/* The extension below encompasses all necessary textField extensions for this app. */

extension UITextField {
    
    func checkIfMatches(string: String?) -> Bool {
        if text == string {
            return true
        }
        else {
            return false
        }
    }
    
    func checkForUpperCase() -> Bool {
        var strength: Bool = false
        let upperCaseRegEx = ".*[A-Z]+.*"
        let upperCaseTest = NSPredicate(format: "SELF MATCHES %@", upperCaseRegEx)
        strength = upperCaseTest.evaluate(with: text)
        return strength
    }
    
    func checkForNumber() -> Bool {
        var numberCheck: Bool = false
        let numberRegEx = ".*[0-9]+.*"
        let numberTest = NSPredicate(format: "SELF MATCHES %@", numberRegEx)
        numberCheck = numberTest.evaluate(with: text)
        return numberCheck
    }
    
    func checkLength(minimum: Int) -> Bool {
        var lengthCheck: Bool = false
        if let text = text {
            if text.count >= minimum {
                lengthCheck = true
            }
            else {
                lengthCheck = false
            }
        }
        return lengthCheck
    }
    
    func checkIfBlank() -> Bool {
        var blankCheck = false
        if self.text == "" {
            blankCheck = true
        }
        else {
            blankCheck = false
        }
        return blankCheck
    }
    
    func makeSecureEntry() {
        isSecureTextEntry = true
        let eyeButton = UIButton()
        eyeButton.makeSFButton(symbolName: "eye", tintColor: .darkGray, configuration: nil)
        eyeButton.frame = CGRect(x: frame.size.width-30, y: frame.midY-10, width: 20, height: 20)
        addSubview(eyeButton)
    }
    
    func makeRequiredField() {
        let asterick = UILabel()
        asterick.text = "*"
        asterick.font = boldFont(size: 15)
        asterick.textColor = .systemRed
        asterick.frame = CGRect(x: 5, y: 5, width: 10, height: 15)
        addSubview(asterick)
    }
    
    func configureToolbar() {
        let toolBar = UIToolbar()
        //the style of the toolbar and color of the fonts
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        toolBar.tintColor = .systemBlue
        toolBar.sizeToFit()
        //creates barbutton item for DONE, CANCEL, and also creates a SPACE button to seperate the DONE and CANCEL.
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelTapped))
        //sets the items created above on the toolbar
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        //determines if user interaction is ignored or not.
        toolBar.isUserInteractionEnabled = true
        inputAccessoryView = toolBar
    }
    
    // dismisses inputView when pressing DONE
    @objc func doneTapped() {
        resignFirstResponder()
    }
    // dismisses inputView when pressing CANCEL
    @objc func cancelTapped() {
        text = nil
        resignFirstResponder()
    }
    
    func toggle(enable: Bool) {
        if enable {
            backgroundColor = .white.withAlphaComponent(0.5)
            isEnabled = true
        }
        else {
            backgroundColor = .systemGray3.withAlphaComponent(0.5)
            text = ""
            isEnabled = false
        }
    }
}

