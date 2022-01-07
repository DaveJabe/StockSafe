//
//  PickerTextField.swift
//  StockSafe
//
//  Created by David Jabech on 7/15/21.
//

import UIKit

class PickerTextField: UITextField, UIPickerViewDelegate, UIPickerViewDataSource {
    
    public let pickerView = UIPickerView()
    
    private var rowData: [[String]]
    
    private var components: Int
    
    private var header: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 25)
        label.font = boldFont(size: 20)
        label.textAlignment = .center
        return label
    }()
    
    init(frame: CGRect, rowData: [[String]], components: Int, header: String?) {
        self.header.text = header
        self.rowData = rowData
        self.components = components
        
        super.init(frame: frame)
        inputView = pickerView
        configureToolbar()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.addSubview(self.header)
        borderStyle = .roundedRect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return components
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rowData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rowData[component][row]
    }
    
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
        text = rowData[component][row]
    }
}
