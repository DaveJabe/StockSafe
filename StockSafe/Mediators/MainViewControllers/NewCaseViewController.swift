//
//  testfilepleasework.swift
//  Stocked.
//
//  Created by David Jabech on 3/13/21.
//
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Network
import Lottie

class newCaseCell: UITableViewCell {
    
    @IBOutlet var productLabel: UILabel!
    @IBOutlet var numLabel: UILabel!
    
}

class NewCaseViewController: UIViewController {
    
    // Label for "Case Range"
    private let caseNumRangeLabel: UILabel = UILabel()
    
    // First textfield for case range selection
    private let caseNumRangeTF: UITextField = UITextField()
    
    // Second textfield for case range selection
    private let caseNumRangeTF2: UITextField = UITextField()
    
    // Pickerview for case range selection
    private let caseNumRangePV: UIPickerView = UIPickerView()
    
    // Pickerview for case number selection
    private let numOfCases: UIPickerView = UIPickerView()
    
    // SelectionView for product selection
    private var productSV = SelectionView.init(frame: CGRect(x: 0,
                                                 y: UIScreen.main.bounds.size.height,
                                                 width: UIScreen.main.bounds.size.width,
                                                 height: 360),
                                   type: .products)
    
    // Provides access to relevant alerts
    private let alerts = NewCaseAlerts()
    
    // Manages cases (reads and writes to Firestore)
    private let manager = CaseManager()
            
    // NotConnectedView to display when there is no network connection
    private let connectionMonitor = NotConnectedView.init(frame: CGRect(x: UIScreen.main.bounds.maxX/5.5,
                                                                        y: UIScreen.main.bounds.size.height/4,
                                                                        width: UIScreen.main.bounds.size.width/1.5,
                                                                        height: UIScreen.main.bounds.size.height/4))
    
    // NWPathMonitor for monitoring network connection status
    private let monitor = NWPathMonitor()

    // IBOutlet view for selection interface
    @IBOutlet var selectionInterface: UIView!
    
    // IBOutlet label for "Product"
    @IBOutlet var productLabel: UILabel!
    
    // IBOutlet button for product selection
    @IBOutlet var productSelect: UIButton!
    
    // IBOutlet label for "Case Number"
    @IBOutlet var caseNumberLabel: UILabel!
    
    // IBOutlet for date label
    @IBOutlet var dateLabel: UILabel!
    
    // IBOutlet for time label
    @IBOutlet var timeLabel: UILabel!
    
    // IBOutlet for help button
    @IBOutlet var helpButton: UIButton!
    
    // IBOutlet for table view (subclass: CaseTable)
    @IBOutlet var newCasesTable: CaseTable!
    
    @IBOutlet var multipleCasesLabel: UILabel!
    
    // IBOutlet for switch to toggle between adding modes (adding a single case or adding multiple cases)
    @IBOutlet var multipleCasesSwitch: UISwitch!
    
    // IBOutlet textfield for case number selection
    @IBOutlet var numOfCasesText: UITextField!
    
    @IBOutlet var enterNewCasesButton: UIButton!
    
    // IBAction for multipleCasesSwitch to toggle adding modes
    @IBAction func multipleCasesToggle(_ sender: UISwitch) {
        if multipleCasesSwitch.isOn {
            caseNumberLabel.text = "Case Range"
            numOfCasesText.isHidden = true
            caseNumRangeTF.isHidden  = false
            caseNumRangeTF2.isHidden = false
            caseNumRangeLabel.isHidden = false
            
        }
        else {
            caseNumberLabel.text = "Case Number"
            numOfCasesText.isHidden = false
            caseNumRangeTF.isHidden = true
            caseNumRangeTF2.isHidden = true
            caseNumRangeLabel.isHidden = true
        }
        hideProductView()
        numOfCasesText.resignFirstResponder()
        caseNumRangeTF.resignFirstResponder()
        caseNumRangeTF2.resignFirstResponder()
    }
    
    // IBAction for entering new cases
    @IBAction func enterNewCases(_ sender: UIButton) {
        if !multipleCasesSwitch.isOn {
            if numOfCasesText.text == "" {
                present(alerts.missingCaseNumAlert, animated: true)
            }
            else {
                newCasesTable.toggleLoadingView(present: true, color: HexColor(productSV.selectedProduct!.color))
                manager.singleNewCaseAlgo(caseAttributes: (number: Int(numOfCasesText.text!)!,
                                                           productName: productSV.selectedProduct!.name,
                                                           location: productSV.selectedProduct!.locations[0]!),
                                          slp: getSLP()) { [self] existCheck, aec_string in
                    if existCheck == .alreadyExists {
                        let CAEAlert = alerts.configureCAEAlert(aec_string: aec_string!)
                        present(CAEAlert, animated: true)
                    }
                    else {
                        refreshData()
                    }
                }
            }
        }
        else if multipleCasesSwitch.isOn {
            if caseNumRangeTF.text == "" || caseNumRangeTF2.text == "" {
                present(alerts.missingCaseRangeAlert, animated: true)
            }
            else if Int(caseNumRangeTF.text!)! > Int(caseNumRangeTF2.text!)! {
                present(alerts.rangeInvalidAlert, animated: true)
            }
            else {
                let casesToAdd = Array(Int(caseNumRangeTF.text!)!...Int(caseNumRangeTF2.text!)!)
                manager.multipleNewCasesAlgo(caseAttributes: (caseRange: casesToAdd,
                                                              name: productSV.selectedProduct!.name,
                                                              location: productSV.selectedProduct!.locations[0]!),
                                             slp: getSLP()) { [self] aec_string in
                    print(aec_string)
                    if aec_string != "" {
                        let MCAEAlert = alerts.configureMCAEAlert(aec_string: aec_string)
                        present(MCAEAlert, animated: true)
                    }
                    else {
                        refreshData()
                    }
                }
            }
        }
    }
    
    private func refreshData() {
        if manager.products.count != 0 {
            newCasesTable.backgroundColor = HexColor(productSV.selectedProduct!.color)?.withAlphaComponent(0.5)
            newCasesTable.toggleLoadingView(present: true, color: HexColor(productSV.selectedProduct!.color))
            manager.queryFirestore(parameters: (productName: productSV.selectedProduct!.name, location: productSV.selectedProduct!.locations[0]!)) { [self] cases, sortedCases in
                newCasesTable.reloadCaseTable(cases: cases, sortedCases: sortedCases, currentCount: manager.currentCount, limit: manager.limit)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.newCasesTable.toggleLoadingView(present: false, color: nil)
                }
            }
        }
    }
    
    private func getSLP() -> ShelfLifeParameter {
        if productSV.selectedProduct!.locations[0] == productSV.selectedProduct!.shelfLife?.startingPoint {
            return .newShelfLife
        }
        else {
            return .noNewShelfLife
        }
    }
    
    private func setUpSelectionInterface() {
        if manager.products.count == 0 {
            productSelect.setTitle("No Products Found", for: .normal)
        }
        else {
            productSelect.setTitle(manager.products[0].name, for: .normal)
            productSelect.backgroundColor = HexColor(manager.products[0].color)
        }
        productSelect.addTarget(self, action: #selector(toggleProductView), for: .touchDown)
        
        caseNumRangeTF.addTarget(self, action: #selector(hideProductView), for: .touchDown)
        
        caseNumRangeTF2.addTarget(self, action: #selector(hideProductView), for: .touchDown)
        
        numOfCasesText.inputView = numOfCases
        numOfCasesText.addTarget(self, action: #selector(hideProductView), for: .touchDown)
        
        caseNumRangePV.delegate = self
        caseNumRangePV.dataSource = self
        numOfCases.dataSource = self
        numOfCases.delegate = self
    }
    
    @objc private func toggleProductView() {
        if productSV.frame.origin.y == UIScreen.main.bounds.size.height {
            UIView.animate(withDuration: 0.3) {
                self.productSV.frame.origin.y = UIScreen.main.bounds.size.height-360
            }
        }
        else {
            UIView.animate(withDuration: 0.3) {
                self.productSV.frame.origin.y = UIScreen.main.bounds.size.height
            }
        }
        numOfCasesText.resignFirstResponder()
        caseNumRangeTF.resignFirstResponder()
        caseNumRangeTF2.resignFirstResponder()
    }
    
    @objc private func hideProductView() {
        if productSV.frame.origin.y != UIScreen.main.bounds.size.height {
            UIView.animate(withDuration: 0.3) {
                self.productSV.frame.origin.y = UIScreen.main.bounds.size.height
            }
        }
    }
    
    private func getDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: Date())
        timeLabel.text = timeFormatter.string(from: Date())
    }
    
    private func setUpConnectionMonitor() {
        view.addSubview(connectionMonitor)
        monitor.pathUpdateHandler = { [self] path in
            if path.status == .satisfied {
                connectionMonitor.isHidden = true
                view.isUserInteractionEnabled = true
            }
            else {
                connectionMonitor.isHidden = false
                view.isUserInteractionEnabled = false
                connectionMonitor.notConnectedAnimation.play()
            }
        }
        let queue = DispatchQueue.main
        monitor.start(queue: queue)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        VD.addShadow(view: selectionInterface)
        VD.addShadow(view: newCasesTable)
        VD.addShadow(view: enterNewCasesButton)
        VD.addSubtleShadow(view: caseNumRangeTF)
        VD.addSubtleShadow(view: caseNumRangeTF2)
        VD.addSubtleShadow(view: numOfCasesText)
        
        VD.addSubtleShadow(view: productLabel)
        VD.addSubtleShadow(view: caseNumRangeLabel)
        VD.addSubtleShadow(view: caseNumberLabel)
        VD.addShadow(view: dateLabel)
        VD.addShadow(view: timeLabel)
        VD.addSubtleShadow(view: multipleCasesLabel)
        
        productSelect.titleLabel!.font = VD.boldFont(size: 20)
        productSelect.setTitleColor(.black, for: .normal)
        VD.configureItemView(view: productSelect)
        
        caseNumRangeTF.borderStyle = .roundedRect
        caseNumRangeTF2.borderStyle = .roundedRect
        
        numOfCasesText.text = "1"
        
        caseNumRangeTF.backgroundColor = .white
        caseNumRangeTF.frame = CGRect(x: 65, y: 263, width: numOfCasesText.frame.size.width, height: numOfCasesText.frame.size.height)
        caseNumRangeTF.font = VD.standardFont(size: 20)
        caseNumRangeTF.inputView = caseNumRangePV
        caseNumRangeTF.text = "1"
        
        caseNumRangeTF2.backgroundColor = .white
        caseNumRangeTF2.frame = CGRect(x: 165, y: 263, width: numOfCasesText.frame.size.width, height: numOfCasesText.frame.size.height)
        caseNumRangeTF2.font = VD.standardFont(size: 20)
        caseNumRangeTF2.inputView = caseNumRangePV
        caseNumRangeTF2.placeholder = "100"
        
        caseNumRangeLabel.text = "-"
        caseNumRangeLabel.font = VD.standardFont(size: 40)
        caseNumRangeLabel.frame = CGRect(x: 145, y: 266, width: 100, height: 46)
        
        selectionInterface.addSubview(caseNumRangeTF)
        selectionInterface.addSubview(caseNumRangeTF2)
        selectionInterface.addSubview(caseNumRangeLabel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                    
        multipleCasesToggle(multipleCasesSwitch)
        
        getDate()
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (Timer) in
            self.getDate()
        })
        
        view.addSubview(productSV)
        view.bringSubviewToFront(productSV)
        
        numOfCases.tag = 1
        caseNumRangePV.tag = 2
        
        newCasesTable.register(CaseCell.self, forCellReuseIdentifier: CaseCell.identifier)
        
        newCasesTable.setMediator(mediator: self)
        manager.setMediator(mediator: self)
        productSV.setMediator(mediator: self)
        alerts.setMediator(mediator: self)
        
        manager.configureProducts()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let hvc = parent?.children.first(where: { $0.restorationIdentifier == "homeScreen"}) as? HomeViewController
        hvc!.viewDidLoad()
    }
}

extension NewCaseViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView.tag {
        case 1:
            return 1
        case 2:
            return 2
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return 100
        case 2:
            return 100
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let cases = Array(1...100)
        switch pickerView.tag {
        case 1:
            return String(cases[row])
        case 2:
            return String(cases[row])
        default:
            return "Error"
        }
    }
    
    // function to execute code when a row is selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let cases = Array(1...100)
        switch pickerView.tag {
        case 1:
            numOfCasesText.text = String(cases[row])
            numOfCasesText.resignFirstResponder()
        case 2:
            if component == 0 {
                caseNumRangeTF.text = String(cases[row])
            }
            else {
                caseNumRangeTF2.text = String(cases[row])
                caseNumRangeTF.resignFirstResponder()
                caseNumRangeTF2.resignFirstResponder()
            }
        default:
            return
        }
    }
}

extension NewCaseViewController: MediatorProtocol {
    func notify(sender: ColleagueProtocol, event: Event) {
        switch event {
        case .configuredProducts(let products):
            if products.count != 0 {
                productSV.selectedProduct = products[0]
            }
            else {
                productSelect.setTitle("No Products", for: .normal)
            }
            refreshData()
            productSV.productsToDisplay = products
            productSV.collectionView.reloadData()
            setUpSelectionInterface()
        case .selectionChanged:
            hideProductView()
            productSelect.setTitle(productSV.selectedProduct?.name, for: .normal)
            productSelect.backgroundColor = HexColor(productSV.selectedProduct!.color)
            refreshData()
        case .replaceCases:
            manager.archiveAndReplaceMultipleCases { [self] in
                refreshData()
            }
        default:
            print("Message sent in func notify in NewCaseViewController: \(event)")
        }
    }
    
    func relayInfo(sender: ColleagueProtocol, info: Any) {
    }
}

extension NewCaseViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

extension NewCaseViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideProductView()
    }
}

