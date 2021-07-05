//
//  CasesByWeekViewController.swift
//  Stocked.
//
//  Created by David Jabech on 4/9/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import Charts

class CasesByWeekViewController: UIViewController {

    @IBOutlet var weekChartView: UIView!
    @IBOutlet var weekSelectTF: UITextField!
    @IBOutlet var weekSelectTF2: UITextField!
    @IBOutlet var locationSelectTF: UITextField!
    
    var weekBarChart = BarChartView()
    var entries = [BarChartDataEntry]()
    var locationPicker = UIPickerView()
    var weekPicker = UIDatePicker()
    var weekPicker2 = UIDatePicker()
    var doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonPressed) )
    var db: Firestore!
    
    let locations = ["Freezer", "Thawing Cabinet", "Breading Table", "Archive"]
    
    @objc func doneButtonPressed() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        weekSelectTF.text = formatter.string(from: weekPicker.date)
        weekSelectTF2.text = formatter.string(from: weekPicker2.date)
        weekSelectTF.resignFirstResponder()
        weekSelectTF2.resignFirstResponder()
        updateWeekChartData()
    }
    
    func updateWeekChartData() {
        
        entries = [(BarChartDataEntry(x: 1, y: 0)), (BarChartDataEntry(x: 2, y: 0)), (BarChartDataEntry(x: 3, y: 0)), (BarChartDataEntry(x: 4, y: 0)), (BarChartDataEntry(x: 5, y: 0)), (BarChartDataEntry(x: 6, y: 0)), (BarChartDataEntry(x: 7, y: 0))]
        
        var offsetDateOne = Calendar.current.date(bySetting: .hour, value: 20, of: weekPicker.date)
        offsetDateOne = Calendar.current.date(bySetting: .minute, value: 0, of: offsetDateOne!)
        offsetDateOne = Calendar.current.date(byAdding: .day, value: -1, to: offsetDateOne!)
        var offsetDateTwo = Calendar.current.date(bySetting: .hour, value: 19, of: weekPicker2.date)
        offsetDateTwo = Calendar.current.date(bySetting: .minute, value: 59, of: offsetDateTwo!)
        
        let dateDataRef = db.collection("dateData")
            .whereField("date", isGreaterThanOrEqualTo: offsetDateOne!)
            .whereField("date", isLessThanOrEqualTo: offsetDateTwo!)
            .order(by: "date")
        
       dateDataRef.getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("error occurred: \(err)")
            }
            else {
                var filetCount: Double = 0
                var spicyCount: Double = 0
                var nuggetCount: Double = 0
                var stripCount: Double = 0
                var gFiletCount: Double = 0
                var gNuggetCount: Double = 0
                var bFiletCount: Double = 0
            
                for document in querySnapshot!.documents {
            
                    filetCount += document.get("product.Filet.\(String(describing:locationSelectTF.text!))") as! Double
                    entries[0] = (BarChartDataEntry(x: 1, y: filetCount))
                    
                    spicyCount += document.get("product.Spicy.\(String(describing:locationSelectTF.text!))") as! Double
                    entries[1] = (BarChartDataEntry(x: 2, y: spicyCount))
                    
                    nuggetCount += document.get("product.Nugget.\(String(describing:locationSelectTF.text!))") as! Double
                    entries[2] = (BarChartDataEntry(x: 3, y: nuggetCount))
                    
                    stripCount += document.get("product.Strip.\(String(describing:locationSelectTF.text!))") as! Double
                    entries[3] = (BarChartDataEntry(x: 4, y: stripCount))
                    
                    gFiletCount += document.get("product.Grilled Filet.\(String(describing:locationSelectTF.text!))") as! Double
                    entries[4] = (BarChartDataEntry(x: 5, y: gFiletCount))
                    
                    gNuggetCount += document.get("product.Grilled Nugget.\(String(describing:locationSelectTF.text!))") as! Double
                    entries[5] = (BarChartDataEntry(x: 6, y: gNuggetCount))
                    
                    bFiletCount += document.get("product.Breakfast Filet.\(String(describing:locationSelectTF.text!))") as! Double
                    entries[6] = (BarChartDataEntry(x: 7, y: bFiletCount))
                    
                    var timestamp = document.get("date")
                    timestamp = (timestamp as AnyObject).dateValue()
                    print(timestamp!)
                }
                
                weekChartView.addSubview(weekBarChart)
                weekBarChart.center = weekChartView.center
                weekBarChart.frame = CGRect(x: 0, y: 0, width: Int(weekChartView.frame.size.width), height: Int(weekChartView.frame.size.height))
                weekBarChart.legend.enabled = false
                let productArray =  ["", "Filet", "Spicy", "Nugget", "Strip", "G Filet", "G Nugget", "B Filet"]
                weekBarChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: productArray)
                weekBarChart.xAxis.labelFont = UIFont(name: "Avenir", size: 15)!
                weekBarChart.drawGridBackgroundEnabled = false
                let set = BarChartDataSet(entries: entries)
                set.colors = [UIColor(red: 0, green: 1, blue: 1, alpha: 1), UIColor(red: 0.65, green: 0, blue: 1, alpha: 1), UIColor(red: 1, green: 0.70, blue: 0.70, alpha: 1), UIColor(red: 0, green: 1, blue: 0, alpha: 1), UIColor(red: 0.65, green: 0.65, blue: 0, alpha: 1), UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 1), UIColor(red: 0.90, green: 1, blue: 0, alpha: 1)]
                let data = BarChartData(dataSet: set)
                weekBarChart.data = data
                
            }
        }
    }
    
    func createDatePicker() {
        weekPicker.datePickerMode = .date
        weekPicker2.datePickerMode = .date
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        weekSelectTF.inputAccessoryView = toolbar
        weekSelectTF2.inputAccessoryView = toolbar
        toolbar.setItems([doneButton], animated: true)
        weekSelectTF.inputView = weekPicker
        weekSelectTF2.inputView = weekPicker2
        weekPicker.date = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
        weekPicker2.date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        weekSelectTF.text = formatter.string(from: weekPicker.date)
        weekSelectTF2.text = formatter.string(from: weekPicker2.date)
        weekSelectTF.font = UIFont(name: "Avenir", size: 15)
        weekSelectTF2.font = UIFont(name: "Avenir", size: 15)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true

        Firestore.firestore().settings = settings
        // [END setup]
            db = Firestore.firestore()

        locationSelectTF.font = UIFont(name: "Avenir", size: 15)
        locationSelectTF.inputView = locationPicker
        locationSelectTF.text = "Freezer"
    
        locationPicker.delegate = self
        locationPicker.dataSource = self
        
        createDatePicker()
        updateWeekChartData()
        }
}

extension CasesByWeekViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return locations.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        locationSelectTF.text = locations[row]
        locationSelectTF.resignFirstResponder()
        updateWeekChartData()
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return locations[row]
    }
}
    

