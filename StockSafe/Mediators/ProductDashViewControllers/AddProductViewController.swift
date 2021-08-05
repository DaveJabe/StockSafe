//
//  AddProductViewController.swift
//  StockSafe
//
//  Created by David Jabech on 7/7/21.
//

import UIKit

class AddProductViewController: UIViewController {
    
    private var manager = ProductManager.init()
    
    private var productName: String = ""
    private var shelfLifeBegins: [Int:String]?
    private var shelfLife: (Int, String) = (0, "")
    public var selectedColor = "#D32F2F"
    
    private var numOfTextFields = 2 // This number cannot exceed 3
    private var currentSelections = [0:""]
    
    
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet weak var addProductTable: UITableView!
    
    @IBOutlet var addNewProductLabel: UILabel!
        
    @IBOutlet var addNewProductButton: UIButton!
    
    @IBAction func addNewProduct(_sender: UIButton) {
        let pdvc = presentingViewController?.children.first(where: { $0.restorationIdentifier == "productDashboard" }) as? ProductDashboardViewController
        var sl: ShelfLife?
        if let shelfLifeBegins = shelfLifeBegins {
            sl = manager.newShelfLife(shelfLife: shelfLife.0, hoursOrDays: shelfLife.1, startingPoint: shelfLifeBegins)
        }
        currentSelections[currentSelections.count] = "Archive"
        manager.addNewProduct(name: productName, locations: currentSelections, shelfLife: sl, color: selectedColor) {
            manager.configureProducts()
            pdvc!.viewDidLoad()
        }
        dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        VD.addShadow(view: backgroundView)
        VD.addShadow(view: addNewProductButton)
        VD.addSubtleShadow(view: addNewProductLabel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addProductTable.delegate = self
        addProductTable.dataSource = self
        addProductTable.allowsSelection = false
        addProductTable.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.identifier)
        addProductTable.register(ExpandingTFCell.self, forCellReuseIdentifier: ExpandingTFCell.identifier)
        addProductTable.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.identifier)
        manager.configureProducts()
        manager.setMediator(mediator: self)
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
            return CGFloat(88*(numOfTextFields))+88
        }
    }
        //Add new products functionalities
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        //code for cell that stores user inputed product name.
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.identifier, for: indexPath) as? TextFieldCell else {
                return UITableViewCell()
            }
            cell.title.text = "Name"
            cell.textField.placeholder = "Strawberries"
            cell.textField.text = productName
            cell.setDelegate(delegate: self)
            cell.tag = 0
            return cell
        //Allows the user to choose what locations this product can belong in.
        case 1:
            let cell = ExpandingTFCell.init(numOfTextFields: numOfTextFields, locations: manager.getLocationStrings(for: .locations), currentSelections: currentSelections, type: .pickerTextField, delegate: self)
            cell.title.text = "Locations"
            cell.setDelegate(delegate: self)
            
            return cell
            
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.identifier, for: indexPath) as? TextFieldCell else {
                return UITableViewCell()
            }
            var rowTitles: [String] = []
            if currentSelections == [0:""] {
                for selection in currentSelections.values {
                    rowTitles.append(selection)
                }
            }
            cell.changeToPTF(rowData: [rowTitles], components: 1, header: "Where does the shelf life for \(productName) begin?", tag: 2)
            cell.title.text = "Shelf Life Start Location"
            cell.textField.placeholder = "Cooler"
            cell.textField.text = shelfLifeBegins?.first?.value
            cell.setDelegate(delegate: self)
            
            if currentSelections == [0:""] || productName == "" {
                cell.textField.toggle(enable: false)
            }
            else {
                cell.textField.toggle(enable: true)
            }
            return cell
            
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.identifier, for: indexPath) as? TextFieldCell else {
                return UITableViewCell()
            }
            let array = Array(1...100)
            let shelfLifeRowData: [[String]] = [array.map({ String($0) }),
                                                ["Hours", "Days"]]
            cell.title.text = "Length of Shelf Life"
            cell.changeToPTF(rowData: shelfLifeRowData, components: 2, header: "How long is the shelf life for \(productName)?", tag: 3)
            cell.textField.placeholder = "1 Day"
            if shelfLife != (0,"") {
                cell.textField.text = "\(shelfLife.0) \(shelfLife.1)"
            }
            cell.setDelegate(delegate: self)
            if currentSelections == [0:""] || productName == "" {
                cell.textField.toggle(enable: false)
            }
            else {
                cell.textField.toggle(enable: true)
            }
            return cell
            
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.identifier, for: indexPath) as? ButtonCell else {
                return UITableViewCell()
            }
            let goToColorSelect = UIAction(handler: { [self] _ in
                let csvc = storyboard?.instantiateViewController(withIdentifier: "colorSelect") as? ColorSelectViewController
                csvc!.modalPresentationStyle = .overCurrentContext
                present(csvc!, animated: true)
            })
            cell.title.text = "Color"
            cell.configureButton(title: nil, backgroundColor: HexColor(selectedColor), action: goToColorSelect)
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

extension AddProductViewController: TextFieldCellDelegate, EPTFCDelegate {
    
    func returnText(senderTag: Int, text: String) {
        let cell1 = addProductTable.cellForRow(at: IndexPath(row: 2, section: 0)) as? TextFieldCell
        let cell2 = addProductTable.cellForRow(at: IndexPath(row: 3, section: 0)) as? TextFieldCell
        switch senderTag {
        case 0:
            productName = text
            if currentSelections == [0:""] || productName == "" {
                cell1?.textField.toggle(enable: false)
                cell2?.textField.toggle(enable: false)
            }
            else {
                cell1?.textField.toggle(enable: true)
                cell2?.textField.toggle(enable: false)
            }
        case 2:
            if let slbegins = currentSelections.first(where: { $0.value == text } )?.key {
                shelfLifeBegins = [slbegins:text]
            }
        case 3:
            if text != "" {
                let subStrings = text.split(separator: " ")
                shelfLife.0 = Int(subStrings[0])!
                shelfLife.1 = String(subStrings[1])
            }
        default:
            print("Error in func returnText(senderTag: \(senderTag), text: \(text)")
        }
    }
    
    func readyForReload(numOfTextFields: Int, currentSelections: [Int : String]) {
        self.currentSelections = currentSelections
        self.numOfTextFields = numOfTextFields
        addProductTable.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
        addProductTable.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
        addProductTable.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
    }
    
    func updateSelections(selections: [Int : String]) {
        let cell1 = addProductTable.cellForRow(at: IndexPath(row: 2, section: 0)) as? TextFieldCell
        let cell2 = addProductTable.cellForRow(at: IndexPath(row: 3, section: 0)) as? TextFieldCell
        self.currentSelections = selections
        
        if currentSelections == [0:""] || productName == "" {
            cell1?.textField.toggle(enable: false)
            cell2?.textField.toggle(enable: false)
        }
        else {
            cell1?.changeToPTF(rowData: [currentSelections.values.compactMap({ $0 as String })], components: 1, header: "Where does the shelf life for \(productName) begin?", tag: 2)
            cell1?.textField.placeholder = "Cooler"
            cell1?.textField.toggle(enable: true)
            cell2?.textField.toggle(enable: true)
            }
        }
}

extension AddProductViewController: MediatorProtocol {
    func notify(sender: ColleagueProtocol, event: Event) {
        switch event {
        case .configuredLocations:
            addProductTable.reloadData()
        default:
        print("Error in func notify in AddProductViewController")
        }
    }
    
    func relayInfo(sender: ColleagueProtocol, info: Any) {
    }
}



