//
//  PickerTextField.swift
//  StockSafe
//
//  Created by David Jabech on 7/15/21.
//

import UIKit

protocol ToolbarPickerViewDelegate {
    func didTapDone()
    func didTapCancel()
}

class PickerTextField: UITextField, UIPickerViewDelegate, UIPickerViewDataSource {
    
    public let pickerView = UIPickerView()
    
    public var toolbarDelegate: ToolbarPickerViewDelegate?
    
    private var rowData: [[String]]
    
    private var components: Int
    
//this creates the picker views header. It is in bold.
    private var header: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 25)
        label.font = VD.boldFont(size: 20)
        label.textAlignment = .center
        return label
    }()
//configures toolbar and then returns toolbar.
    private func configureToolbar() -> UIToolbar {
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
        return toolBar
    }
//initializing the values so that they dont stay in an intermediate state.
    init(frame: CGRect, rowData: [[String]], components: Int, header: String?) {
        self.header.text = header
        self.rowData = rowData
        self.components = components
    //creating delegate and also changing font/header.
        super.init(frame: frame)
    //what shows up when you press the textfield
        inputView = pickerView
    //what shows up on the the top of the pickerview
        inputAccessoryView = configureToolbar()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.addSubview(self.header)
        font = VD.standardFont(size: 20)
        borderStyle = .roundedRect
    }
//to catch error just in case
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//returns number of components
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return components
    }
//creates rows depending on numbrt of components
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rowData[component].count
    }
//creates titles for rows
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rowData[component][row]
    }
//This code is executed when a row is selected.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if components == 2 {
                var dayOrDays = ""
                if pickerView.selectedRow(inComponent: 0) == 0 {
                    switch pickerView.selectedRow(inComponent: 1) {
                    case 0:
                        dayOrDays = "Hour"
                    case 1:
                        dayOrDays = "Day"
                    default:
                        print("Error")
                    }
                }
                else {
                    switch pickerView.selectedRow(inComponent: 1) {
                    case 0:
                        dayOrDays = "Hours"
                    case 1:
                        dayOrDays = "Days"
                    default:
                        print("Error")
                    }
                }
                text = "\(rowData[0][pickerView.selectedRow(inComponent: 0)]) \(dayOrDays)"
            }
            else {
                text = rowData[component][row]
            }
    }
//dismisses pickerView when pressing DONE
   @objc func doneTapped() {
        resignFirstResponder()
    }
//dismisses pickerview when pressing CANCEL
    @objc func cancelTapped() {
        text = nil
        resignFirstResponder()
    }
}



