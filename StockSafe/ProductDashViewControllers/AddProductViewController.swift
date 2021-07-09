//
//  AddProductViewController.swift
//  StockSafe
//
//  Created by David Jabech on 7/7/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class AddProductViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    private var db: Firestore!
    
    private var productName: String = ""
    private var productLocations: [String] = ["", ""]
    private var shelfLifeBegins: String = ""
    private var shelfLife: (Int, String) = (0, "")
    public var selectedColor = HexColor("#D32F2F")
    
    private var shelfLifeBeginsHeader = UILabel()
    private var shelfLifeHeader = UILabel()
    
    @IBOutlet weak var addProductTable: UITableView!
    
    @IBAction func addNewProduct(_sender: UIButton) {
        let sl: Int
        if shelfLife.1 != "Hours" {
            sl = 24 * shelfLife.0
        }
        else {
            sl = shelfLife.0
        }
        do {
            let _ = try db.collection("products").addDocument(from: Product(name: productName,
                                                                locations: productLocations,
                                                                shelfLifeBegins: shelfLifeBegins,
                                                                maxShelfLife: sl,
                                                                color: selectedColor!.hex,
                                                                userID: userIDkey))
            print("New Product successfully written to Firestore!")
            let pdvc = presentingViewController?.children.first(where: { $0.restorationIdentifier == "productDashboard" }) as? ProductDashboardViewController
            pdvc!.viewDidLoad()
            dismiss(animated: true)
        }
        catch {
            print("Error writing Product to Firestore...")
        }
    }
    
    @objc private func textFieldWasEdited(_ sender: UITextField) {
        switch sender.tag {
        // Name TF
        case 1:
            productName = sender.text!
            addProductTable.reloadRows(at: [IndexPath(row: 2, section: 0)], with: UITableView.RowAnimation.none)
            addProductTable.reloadRows(at: [IndexPath(row: 3, section: 0)], with: UITableView.RowAnimation.none)
        // Location 1 TF
        case 2:
            productLocations[0] = sender.text!
            addProductTable.reloadRows(at: [IndexPath(row: 2, section: 0)], with: UITableView.RowAnimation.none)
            addProductTable.reloadRows(at: [IndexPath(row: 3, section: 0)], with: UITableView.RowAnimation.none)
        // Location 2 TF
        case 3:
            productLocations[1] = sender.text!
            addProductTable.reloadRows(at: [IndexPath(row: 2, section: 0)], with: UITableView.RowAnimation.none)
            addProductTable.reloadRows(at: [IndexPath(row: 3, section: 0)], with: UITableView.RowAnimation.none)
        // ShelfLifeBegins TF
        case 4:
            shelfLifeBegins = sender.text!
            print(shelfLifeBegins)
        // ShelfLife TF
        case 5:
            if sender.text != "" {
                let subStrings = sender.text?.split(separator: " ")
                shelfLife.0 = Int(subStrings![0])!
                shelfLife.1 = String(subStrings![1])
                print(shelfLife)
            }
        default:
            print("Error in textFieldWasEdited()")
        }
    }
    
    private func configurePickerViewHeaders() {
        shelfLifeBeginsHeader.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25)
        shelfLifeBeginsHeader.textAlignment = .center
        shelfLifeBeginsHeader.font = UIFont(name: "Avenir Heavy", size: 20)
        
        shelfLifeHeader.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25)
        shelfLifeHeader.textAlignment = .center
        shelfLifeHeader.font = UIFont(name: "Avenir Heavy", size: 20)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        addProductTable.delegate = self
        addProductTable.dataSource = self
        addProductTable.allowsSelection = false
        configurePickerViewHeaders()
    }
}

extension AddProductViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = .systemGray5
        return footer
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row != 1 {
            return 88
        }
        else {
            return 264
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "productNameCell", for: indexPath) as? ProductNameCell else {
                return UITableViewCell()
            }
            cell.nameLabel.tag = 1
            cell.nameLabel.addTarget(self, action: #selector(textFieldWasEdited(_:)), for: .editingChanged)
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "productLocationsCell", for: indexPath) as? ProductLocationsCell else {
                return UITableViewCell()
            }
            cell.locationOneTF.tag = 2
            cell.locationOneTF.addTarget(self, action: #selector(textFieldWasEdited(_:)), for: .editingChanged)
            
            cell.locationTwoTF.tag = 3
            cell.locationTwoTF.addTarget(self, action: #selector(textFieldWasEdited(_:)), for: .editingChanged)

            cell.archiveInfoButton.addAction(UIAction(handler: { [self] _ in
                let aivc = storyboard?.instantiateViewController(withIdentifier: "archiveInfoVC")
                present(aivc!, animated: true)
            }),
            for: .touchUpInside)
            cell.archiveTF.isEnabled = false
            
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "productShelfLifeBeginsCell", for: indexPath) as? ProductShelfLifeBeginsCell else {
                return UITableViewCell()
            }
            
            if (productName != "") && !productLocations.contains("") {
                cell.shelfLifeBeginsTF.isEnabled = true
                cell.shelfLifeBeginsTF.backgroundColor = .white
            }
            else {
                shelfLifeBegins = ""
                cell.shelfLifeBeginsTF.text! = shelfLifeBegins
                cell.shelfLifeBeginsTF.isEnabled = false
                cell.shelfLifeBeginsTF.backgroundColor = .systemGray3
            }
            
            cell.shelfLifeBeginsTF.tag = 4
            cell.shelfLifeBeginsTF.addTarget(self, action: #selector(textFieldWasEdited(_:)), for: .allEditingEvents)
            
            shelfLifeBeginsHeader.text = "Where does the shelf life for \(productName) begin?"
            cell.shelfLifeBeginsTF.inputView = cell.locationPicker
            cell.pickerLocations = productLocations
            cell.locationPicker.addSubview(shelfLifeBeginsHeader)
            cell.locationPicker.delegate = cell
            cell.locationPicker.dataSource = cell
            
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "productShelfLifeCell", for: indexPath) as? ProductShelfLifeCell else {
                return UITableViewCell()
            }
            
            if (productName != "") && !productLocations.contains("") {
                cell.shelfLifeTF.isEnabled = true
                cell.shelfLifeTF.backgroundColor = .white
            }
            else {
                shelfLife = (0, "")
                cell.shelfLifeTF.isEnabled = false
                cell.shelfLifeTF.backgroundColor = .systemGray3
            }
            
            if shelfLife.0 == 0 || !productLocations.contains("") {
                cell.shelfLifeTF.text = ""
            }
            
            cell.shelfLifeTF.tag = 5
            cell.shelfLifeTF.addTarget(self, action: #selector(textFieldWasEdited(_:)), for: .allEditingEvents)
            
            shelfLifeHeader.text = "How long is the shelf life for \(productName)?"
            cell.shelfLifeTF.inputView = cell.shelfLifePicker
            cell.shelfLifePicker.addSubview(shelfLifeHeader)
            cell.shelfLifePicker.delegate = cell
            cell.shelfLifePicker.dataSource = cell
            return cell
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "productColorCell", for: indexPath) as? ProductColorCell else {
                return UITableViewCell()
            }
            cell.colorSelectButton.backgroundColor = selectedColor
            cell.colorSelectButton.addAction(UIAction(handler: { [self] _ in
                let csvc = storyboard?.instantiateViewController(withIdentifier: "colorSelect") as? ColorSelectViewController
                csvc!.modalPresentationStyle = .overCurrentContext
                present(csvc!, animated: true)
            }),
            for: .touchUpInside)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// Classes for protoype cells (for AddProductTable)

class ProductNameCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UITextField!
}

class ProductLocationsCell: UITableViewCell {
    @IBOutlet weak var locationOneTF: UITextField!
    @IBOutlet weak var locationTwoTF: UITextField!
    @IBOutlet weak var archiveTF: UITextField!
    @IBOutlet weak var archiveInfoButton: UIButton!
}

class ProductShelfLifeBeginsCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
   
    public var pickerLocations = [String]()
    public let locationPicker = UIPickerView()
    @IBOutlet var shelfLifeBeginsTF: UITextField!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerLocations.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerLocations[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        shelfLifeBeginsTF.text = pickerLocations[row]
        shelfLifeBeginsTF.resignFirstResponder()
    }
    
}

class ProductShelfLifeCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    private let shelfLifeArray = Array(1...100)
    private let timeStyle = ["Hours", "Days"]
    public let shelfLifePicker = UIPickerView()
    @IBOutlet weak var shelfLifeTF: UITextField!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return shelfLifeArray.count
        }
        else {
            return timeStyle.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(shelfLifeArray[row])
        }
        else {
            return timeStyle[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
            
        shelfLifeTF.text = "\(shelfLifeArray[pickerView.selectedRow(inComponent: 0)]) \(dayOrDays)"
        shelfLifeTF.resignFirstResponder()
    }
}

class ProductColorCell: UITableViewCell {
    @IBOutlet var colorSelectButton: UIButton!
}
