//
//  CasesByDayViewController.swift
//  Stocked.
//
//  Created by David Jabech on 4/5/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import Charts

class CasesByDayViewController: UIViewController, ChartViewDelegate {
    
    var db: Firestore!
    let sv = StockCasesViewController()
    let barChart = BarChartView()
    var entries = [BarChartDataEntry]()
    
    @IBOutlet var selectDateTF: UITextField!
    @IBOutlet var selectLocationTF: UITextField!
    @IBOutlet var chartView: UIView!
    
    var locationPicker = UIPickerView()
    var datePicker = UIDatePicker()
    var doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
    
    @objc func donePressed() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        selectDateTF.text = formatter.string(from: datePicker.date)
        selectDateTF.resignFirstResponder()
        
        updateChartData()
    }

    
    func updateChartData() {
        
        entries = []
        
        let dateDataRef = db.collection("dateData")
        dateDataRef.getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("error retrieving docs: \(err)")
            }
            else {
                for document in querySnapshot!.documents {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .short
                    var timestamp = document.get("date")
                    timestamp = (timestamp as AnyObject).dateValue()
                    let timestampString = formatter.string(from: timestamp as! Date)
                    let selectedDateString = formatter.string(from: datePicker.date)
                    if timestampString == selectedDateString {
                        entries.append((BarChartDataEntry(x: 1, y: document.get("product.Filet.\(String(describing: selectLocationTF.text!))") as! Double)))
                        entries.append((BarChartDataEntry(x: 2, y: document.get("product.Spicy.\(String(describing: selectLocationTF.text!))") as! Double)))
                        entries.append((BarChartDataEntry(x: 3, y: document.get("product.Nugget.\(String(describing: selectLocationTF.text!))") as! Double)))
                        entries.append((BarChartDataEntry(x: 4, y: document.get("product.Strip.\(String(describing: selectLocationTF.text!))") as! Double)))
                        entries.append((BarChartDataEntry(x: 5, y: document.get("product.Grilled Filet.\(String(describing: selectLocationTF.text!))") as! Double)))
                        entries.append((BarChartDataEntry(x: 6, y: document.get("product.Grilled Nugget.\(String(describing: selectLocationTF.text!))") as! Double)))
                        entries.append((BarChartDataEntry(x: 7, y: document.get("product.Breakfast Filet.\(String(describing: selectLocationTF.text!))") as! Double)))
                    }
                }
                
                chartView.addSubview(barChart)
                barChart.center = chartView.center
                barChart.frame = CGRect(x: 0, y: 0, width: chartView.frame.size.width, height: chartView.frame.size.height)
                barChart.delegate = self
                barChart.legend.enabled = false
                let productArray = ["", "Filet", "Spicy", "Nugget", "Strip", "G Filet", "G Nugget", "B Filet"]
                barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: productArray)
                barChart.xAxis.labelFont = UIFont(name: "Avenir", size: 15)!
                barChart.drawGridBackgroundEnabled = false
                let set = BarChartDataSet(entries: entries)
                set.colors = [UIColor(red: 0, green: 1, blue: 1, alpha: 1), UIColor(red: 0.65, green: 0, blue: 1, alpha: 1), UIColor(red: 1, green: 0.70, blue: 0.70, alpha: 1), UIColor(red: 0, green: 1, blue: 0, alpha: 1), UIColor(red: 0.65, green: 0.65, blue: 0, alpha: 1), UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 1), UIColor(red: 0.90, green: 1, blue: 0, alpha: 1)]
                let data = BarChartData(dataSet: set)
                barChart.data = data
                
            
                
            }
        }
    }
    
    func createDatePicker() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        selectDateTF.font = UIFont(name: "Avenir", size: 15)
        selectDateTF.text = formatter.string(from: datePicker.date)
        selectDateTF.inputView = datePicker
        datePicker.datePickerMode = .date
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        selectDateTF.inputAccessoryView = toolbar
        
        toolbar.setItems([doneButton], animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true

        Firestore.firestore().settings = settings
        // [END setup]
            db = Firestore.firestore()
       
        selectLocationTF.font = UIFont(name: "Avenir", size: 15)
        selectLocationTF.text = "Freezer"
        selectLocationTF.inputView = locationPicker
        
        
        locationPicker.delegate = self
        locationPicker.dataSource = self
        
        chartView.layer.masksToBounds = true
        chartView.layer.cornerRadius = 10
        
        createDatePicker()
        updateChartData()
        
    }
    
}

extension CasesByDayViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sv.destinations.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sv.destinations[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectLocationTF.text = sv.destinations[row]
        selectLocationTF.resignFirstResponder()
        updateChartData()
    }
}


