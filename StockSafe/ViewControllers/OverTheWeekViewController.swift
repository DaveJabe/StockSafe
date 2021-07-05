//
//  OverTheWeekViewController.swift
//  Stocked.
//
//  Created by David Jabech on 4/10/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import Charts
import UIMultiPicker

class OverTheWeekViewController: UIViewController {
    
    let locations = ["Freezer", "Thawing Cabinet", "Breading Table", "Archive"]
    let products = ["Filet", "Spicy", "Nugget", "Strip", "Grilled Filet", "Grilled Nugget", "Breakfast Filet"]
    

    @IBOutlet var filterView: UIView!
    @IBOutlet var productChartView: UIView!
    @IBOutlet var dateRangeTF: UITextField!
    @IBOutlet var dateRangeTF2: UITextField!
    @IBOutlet var locationSelectTF: UITextField!
    
    var db: Firestore!
    var datePicker = UIDatePicker()
    var datePicker2 = UIDatePicker()
    var locationPicker = UIPickerView()
    var chartView = LineChartView()
    var doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonPressed))
    var multiPicker = UIMultiPicker()
   
    @objc func selected(_ sender: UIMultiPicker) {
        
        if multiPicker.selectedIndexes.contains(0) {
            filetCheck = true
        }
        else {
            filetCheck = false
        }
        if multiPicker.selectedIndexes.contains(1) {
            spicyCheck = true
        }
        else {
            spicyCheck = false
        }
        if multiPicker.selectedIndexes.contains(2) {
            nuggetCheck = true
        }
        else {
            nuggetCheck = false
        }
        if multiPicker.selectedIndexes.contains(3) {
            stripCheck = true
        }
        else {
            stripCheck = false
        }
        if multiPicker.selectedIndexes.contains(4) {
            gFiletCheck = true
        }
        else {
            gFiletCheck = false
        }
        if multiPicker.selectedIndexes.contains(5) {
            gNuggetCheck = true
        }
        else {
            gNuggetCheck = false
        }
        if multiPicker.selectedIndexes.contains(6) {
            bFiletCheck = true
        }
        else {
            bFiletCheck = false
        }
        
        updateLineChartData()
}

    var filetEntries = [ChartDataEntry]()
    var spicyEntries = [ChartDataEntry]()
    var nuggetEntries = [ChartDataEntry]()
    var stripEntries = [ChartDataEntry]()
    var gFiletEntries = [ChartDataEntry]()
    var gNuggetEntries = [ChartDataEntry]()
    var bFiletEntries = [ChartDataEntry]()
    
    var filetCheck = true
    var spicyCheck = true
    var nuggetCheck = true
    var stripCheck = true
    var gFiletCheck = true
    var gNuggetCheck = true
    var bFiletCheck = true
    
    @objc func doneButtonPressed() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        dateRangeTF.text = formatter.string(from: datePicker.date)
        dateRangeTF2.text = formatter.string(from: datePicker2.date)
        dateRangeTF.resignFirstResponder()
        dateRangeTF2.resignFirstResponder()
        updateLineChartData()
    }
    
    func createMultiPicker() {
        filterView.addSubview(multiPicker)
        multiPicker.frame = CGRect(x: 0, y: 48, width: 240, height: 100)
        multiPicker.tintColor = .black
        multiPicker.options = products
        multiPicker.selectedIndexes = [0, 1, 2, 3, 4, 5, 6]
        multiPicker.addTarget(self, action: #selector(selected), for: .valueChanged)
    }
    
    func createDatePicker() {
        datePicker.datePickerMode = .date
        datePicker2.datePickerMode = .date
        dateRangeTF?.inputView = datePicker
        dateRangeTF2?.inputView = datePicker2
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.setItems([doneButton], animated: true)
        dateRangeTF?.inputAccessoryView = toolbar
        dateRangeTF2?.inputAccessoryView = toolbar
        datePicker.date = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
        datePicker2.date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        dateRangeTF?.text = formatter.string(from: datePicker.date)
        dateRangeTF2?.text = formatter.string(from: datePicker2.date)
    }
    
    func updateLineChartData() {
        let selectDateAlert = UIAlertController(title: "Please select a valid date range", message: nil, preferredStyle: .alert)
        selectDateAlert.addAction(UIAlertAction(title: "Heard on that.", style: .default, handler: nil))
        if dateRangeTF?.text! == "" || dateRangeTF2?.text! == "" {
           
            self.present(selectDateAlert, animated: true)
        }
        else if datePicker.date > datePicker2.date {
            self.present(selectDateAlert, animated: true)
        }
        else {
        
        filetEntries = []
        spicyEntries = []
        nuggetEntries = []
        stripEntries = []
        gFiletEntries = []
        gNuggetEntries = []
        bFiletEntries = []
        
        var offsetDateOne = Calendar.current.date(bySetting: .hour, value: 20, of: datePicker.date)
        offsetDateOne = Calendar.current.date(bySetting: .minute, value: 0, of: offsetDateOne!)
        offsetDateOne = Calendar.current.date(byAdding: .day, value: -1, to: offsetDateOne!)
        var offsetDateTwo = Calendar.current.date(bySetting: .hour, value: 19, of: datePicker2.date)
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
                var dayRange: [String] = [""]
                var count: Double = 1
                for document in querySnapshot!.documents {
                    filetEntries.append(ChartDataEntry(x: count, y: document.get("product.Filet.\(String(describing: locationSelectTF.text!))") as! Double))
                    spicyEntries.append(ChartDataEntry(x: count, y: document.get("product.Spicy.\(String(describing: locationSelectTF.text!))") as! Double))
                    nuggetEntries.append(ChartDataEntry(x: count, y: document.get("product.Nugget.\(String(describing: locationSelectTF.text!))") as! Double))
                    stripEntries.append(ChartDataEntry(x: count, y: document.get("product.Strip.\(String(describing: locationSelectTF.text!))") as! Double))
                    gFiletEntries.append(ChartDataEntry(x: count, y: document.get("product.Grilled Filet.\(String(describing: locationSelectTF.text!))") as! Double))
                    gNuggetEntries.append(ChartDataEntry(x: count, y: document.get("product.Grilled Nugget.\(String(describing: locationSelectTF.text!))") as! Double))
                    bFiletEntries.append(ChartDataEntry(x: count, y: document.get("product.Breakfast Filet.\(String(describing: locationSelectTF.text!))") as! Double))
                    var timestamp = document.get("date")
                    timestamp = (timestamp as AnyObject).dateValue()
                    let formatter = DateFormatter()
                    formatter.dateStyle = .short
                    dayRange.append(formatter.string(from: timestamp as! Date))
                    count += 1
                }
                productChartView.addSubview(chartView)
                chartView.center = productChartView.center
                chartView.frame = CGRect(x: 0, y: 0, width: productChartView.frame.size.width, height: productChartView.frame.size.height)
                
                print(dayRange)
                chartView.xAxis.labelFont = UIFont(name: "Avenir", size: 15)!
                
                var productSets: [LineChartDataSet] = []
                
                if filetCheck {
                let filetSet = LineChartDataSet(entries: filetEntries, label: "Filet")
                filetSet.colors = [UIColor(red: 0, green: 1, blue: 1, alpha: 1)]
                filetSet.lineWidth = 5
                productSets.append(filetSet)
                }
                if spicyCheck {
                let spicySet = LineChartDataSet(entries: spicyEntries, label: "Spicy")
                spicySet.colors = [UIColor(red: 0.65, green: 0, blue: 1, alpha: 1)]
                spicySet.lineWidth = 5
                productSets.append(spicySet)
                }
                if nuggetCheck {
                let nuggetSet = LineChartDataSet(entries: nuggetEntries, label: "Nugget")
                nuggetSet.colors = [UIColor(red: 1, green: 0.70, blue: 0.70, alpha: 1)]
                nuggetSet.lineWidth = 5
                productSets.append(nuggetSet)
                }
                if stripCheck {
                let stripSet = LineChartDataSet(entries: stripEntries, label: "Strip")
                stripSet.colors = [UIColor(red: 0, green: 1, blue: 0, alpha: 1)]
                stripSet.lineWidth = 5
                productSets.append(stripSet)
                }
                if gFiletCheck {
                let gFiletSet = LineChartDataSet(entries: gFiletEntries, label: "Grilled Filet")
                gFiletSet.colors = [UIColor(red: 0.65, green: 0.65, blue: 0, alpha: 1)]
                gFiletSet.lineWidth = 5
                productSets.append(gFiletSet)
                }
                if gNuggetCheck {
                let gNuggetSet = LineChartDataSet(entries: gNuggetEntries, label: "Grilled Nugget")
                gNuggetSet.colors = [UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 1)]
                gNuggetSet.lineWidth = 5
                productSets.append(gNuggetSet)
                }
                if bFiletCheck {
                let bFiletSet = LineChartDataSet(entries: bFiletEntries, label: "Breakfast Filet")
                bFiletSet.colors = [ UIColor(red: 0.90, green: 1, blue: 0, alpha: 1)]
                bFiletSet.lineWidth = 5
                productSets.append(bFiletSet)
                }
                let data = LineChartData(dataSets: productSets)
                chartView.data = data
                chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dayRange)
                chartView.legend.font = UIFont(name: "Avenir", size: 15)!
                chartView.legend.xEntrySpace = 40
                chartView.legend.neededHeight = 20
                chartView.xAxis.granularity = 1
            }
        }
    }
}
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true

        Firestore.firestore().settings = settings
        // [END setup]
            db = Firestore.firestore()
        
        locationPicker.delegate = self
        locationPicker.dataSource = self
        locationSelectTF?.inputView = locationPicker
        locationSelectTF?.text = "Freezer"
        
        createMultiPicker()
        createDatePicker()
        updateLineChartData()

    }

}

extension OverTheWeekViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return locations.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return locations[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        locationSelectTF.text = locations[row]
        locationSelectTF.resignFirstResponder()
        updateLineChartData()
    }
    
}
