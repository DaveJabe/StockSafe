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

class NewCasesViewController: UIViewController {
    
    private var db: Firestore!
    private var tableCases = [Case]()
    
    private let caseNumRangeLabel: UILabel = UILabel()
    private let caseNumRangeTF: UITextField = UITextField()
    private let caseNumRangeTF2: UITextField = UITextField()
    private let caseNumRangePV: UIPickerView = UIPickerView()
    
    @IBOutlet var selectionView: UIView!
    @IBOutlet var productLabel: UILabel!
    @IBOutlet var productSelect: UIButton!
    @IBOutlet var caseNumberLabel: UILabel!
    @IBOutlet var numOfCasesText: UITextField!
    private let numOfCases: UIPickerView = UIPickerView()
    
    private let productView: ProductCollectionView = ProductCollectionView.init(frame: CGRect(x: 0,
                                                                                              y: UIScreen.main.bounds.size.height,
                                                                                              width: UIScreen.main.bounds.size.width,
                                                                                              height: 360))
    
    private let connectionMonitor = NotConnectedView.init(frame: CGRect(x: UIScreen.main.bounds.maxX/5.5,
                                                                        y: UIScreen.main.bounds.size.height/4,
                                                                        width: UIScreen.main.bounds.size.width/1.5,
                                                                        height: UIScreen.main.bounds.size.height/4))
    private let loadingView = LoadingView.init()
    private let monitor = NWPathMonitor()
    
    private let heard = UIAlertAction(title: "Heard on that.", style: .default, handler: nil)
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var enterNewCasesView: UIView!
    @IBOutlet var helpButton: UIButton!
    private let header = UIView()
    @IBOutlet var newCasesTable: UITableView!
    @IBOutlet var multipleCasesSwitch: UISwitch!
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
    
    public func archiveSelectedCase(Product: String, CaseNumber: Int, Location: String, completion: @escaping () -> Void) {
        let casesRef = db.collection("testData")
            .whereField("product", isEqualTo: Product)
            .whereField("location", isEqualTo: Location)
            .whereField("caseNumber", isEqualTo: CaseNumber)
            .whereField("userID", isEqualTo: userIDkey)
        
        casesRef.getDocuments { (querySnapshot, err) in
            if err != nil {
                print("error in archiveSelectedCases: \(String(describing: err))")
            }
            else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                    print("document successfully deleted")
                    completion()
                }
            }
        }
    }
    
    public func addSingleCase(Product: String, CaseNumber: Int) {
        let caseAlreadyExists = UIAlertController(title: "Case Already Exists",
                                                  message: "Would you like to archive the existing case with this number and add a new one?",
                                                  preferredStyle: .alert)
        caseAlreadyExists.addAction(heard)
        caseAlreadyExists.addAction(UIAlertAction(title: "Archive and replace that case.", style: .default, handler: { [self] (action) in
            db.collection("testData")
                .whereField("product", isEqualTo: selectedProduct)
                .whereField("caseNumber", isEqualTo: Int(numOfCasesText.text!)!)
                .whereField("userID", isEqualTo: userIDkey)
                .getDocuments() { querySnapshot, err in
                    if err != nil {
                        print("Error in caseAlreadyExists: \(String(describing: err))")
                    }
                    else {
                        let group = DispatchGroup()
                        for document in querySnapshot!.documents {
                            group.enter()
                            archiveSelectedCase(Product: selectedProduct, CaseNumber: Int(numOfCasesText.text!)!, Location: document.get("location") as! String) { [self] () -> () in
                                addSingleCase(Product: selectedProduct, CaseNumber: Int(numOfCasesText.text!)!)
                            }
                            group.leave()
                        }
                        group.notify(queue: DispatchQueue.main) { [self] in
                            reloadTable()
                        }
                    }
                }
        }))
        
        let caseToAdd = Case(product: Product,
                             caseNumber: CaseNumber,
                             location: "Freezer",
                             timestamp: Date(),
                             shelfLife: nil,
                             breadingStamp: nil,
                             userID: userIDkey)
        
        let caseRef = db.collection("testData")
            .whereField("product", isEqualTo: Product)
            .whereField("caseNumber", isEqualTo: CaseNumber)
        
        caseRef.getDocuments() { [self] querySnapshot, err in
            if err != nil {
                print("Error addSingleCase - caseRef.getDocuments: \(String(describing: err))")
            }
            else {
                if querySnapshot!.documents.count != 0 {
                    present(caseAlreadyExists, animated: true)
                }
                else {
                    do {
                        let _ = try db.collection("testData").addDocument(from: caseToAdd)
                        print("document successfully added")
                    }
                    catch {
                        print("Error adding document to Firestore: addSingleCase")
                    }
                }
            }
        }
    }
    
    public func reloadTable() {
        header.isHidden = true
        StockCasesViewController().setTableColor(product: selectedProduct, table: newCasesTable)
        loadingView.backgroundColor = newCasesTable.backgroundColor?.withAlphaComponent(1)
        newCasesTable.addSubview(loadingView)
        newCasesTable.bringSubviewToFront(loadingView)
        loadingView.loadingAnimation.play()
        
        tableCases = []
        
        let freezerSearchRef = db.collection("testData")
            .whereField("product", isEqualTo: selectedProduct)
            .whereField("location", isEqualTo: "Freezer")
            .whereField("userID", isEqualTo: userIDkey)
        
        freezerSearchRef.getDocuments() { [self] querySnapshot, err in
            if err != nil {
                print("Error getting documents: \(String(describing: err))")
            }
            else {
                guard let documents = querySnapshot?.documents else {
                    print("no documents found")
                    return
                }
                tableCases = documents.compactMap { (queryDocumentSnapshot) -> Case? in
                    return try? queryDocumentSnapshot.data(as: Case.self)
                }
                tableCases.sort(by: { $0.caseNumber < $1.caseNumber })
                if tableCases.count == 0 {
                    let noCasesFound = UILabel.init(frame: newCasesTable.bounds)
                    noCasesFound.text = "No Cases Found."
                    noCasesFound.font = UIFont(name: "Avenir", size: 20)
                    noCasesFound.textAlignment = .center
                    newCasesTable.backgroundView = noCasesFound
                    newCasesTable.reloadData()
                }
                else {
                    newCasesTable.backgroundView = nil
                    newCasesTable.reloadData()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    loadingView.removeFromSuperview()
                    self.header.isHidden = false
                }
            }
        }
    }
    
    @IBAction func DoneButton(_ sender: UIButton) {
        let casesNotAdded = UIAlertController(title: "Missing Information",
                                              message: "Please fill in the missing information",
                                              preferredStyle: .alert)
        casesNotAdded.addAction(heard)
        if multipleCasesSwitch.isOn == false {
            if numOfCasesText.text == "" {
                present(casesNotAdded, animated: true)
            }
            else {
                addSingleCase(Product: selectedProduct, CaseNumber: Int(numOfCasesText.text!)!)
                reloadTable()
            }
        }
        else if multipleCasesSwitch.isOn {
            if caseNumRangeTF.text == "" || caseNumRangeTF2.text == "" {
                present(casesNotAdded, animated: true)
            }
            else if Int(caseNumRangeTF.text!)! > Int(caseNumRangeTF2.text!)! {
                let rangeInvalidAlert = UIAlertController(title: "Invalid Range",
                                                          message: "The first case should be a smaller number than the last",
                                                          preferredStyle: .alert)
                rangeInvalidAlert.addAction(heard)
                present(rangeInvalidAlert, animated: true)
            }
            else {
                var alreadyExistingCases: [Int] = []
                let group = DispatchGroup()
                let firstCase = Int(caseNumRangeTF.text!)
                let lastCase = Int(caseNumRangeTF2.text!)
                
                for index in firstCase!...lastCase! {
                    group.enter()
                    db.collection("testData")
                        .whereField("product", isEqualTo: selectedProduct)
                        .whereField("caseNumber", isEqualTo: index)
                        .whereField("userID", isEqualTo: userIDkey)
                        .getDocuments() { [self] querySnapshot, err in
                            if querySnapshot!.documents.count != 0 {
                                alreadyExistingCases.append(index)
                                group.leave()
                            }
                            else {
                                addSingleCase(Product: selectedProduct, CaseNumber: index)
                                group.leave()
                            }
                        }
                }
                group.notify(queue: DispatchQueue.main ) { [self] in
                    alreadyExistingCases.sort()
                    var aecString: String = ""
                    for index in 0..<alreadyExistingCases.count {
                        aecString.append(String(alreadyExistingCases[index]))
                        if index < alreadyExistingCases.count - 1 {
                            aecString.append(", ")
                        }
                        if index == alreadyExistingCases.count - 2 {
                            aecString.append("and ")
                        }
                    }
                    if alreadyExistingCases.count > 0 {
                        let casesAlreadyExist = UIAlertController(title: "Some cases could not be added.",
                                                                  message: "Case(s) \(aecString) already exist.",
                                                                  preferredStyle: .alert)
                        casesAlreadyExist.addAction(heard)
                        casesAlreadyExist.addAction(UIAlertAction(title: "Archive and replace those cases",
                                                                  style: .default,
                                                                  handler: { (action) in
                                                                    let group = DispatchGroup()
                                                                    for index in alreadyExistingCases {
                                                                        group.enter()
                                                                        db.collection("testData")
                                                                            .whereField("product", isEqualTo: selectedProduct)
                                                                            .whereField("caseNumber", isEqualTo: index)
                                                                            .whereField("userID", isEqualTo: userIDkey)
                                                                            .getDocuments() { (querySnapshot, err) in
                                                                                if let err = err {
                                                                                    print("error in cases already exist action: \(err)")
                                                                                }
                                                                                else {
                                                                                    for document in querySnapshot!.documents {
                                                                                        archiveSelectedCase(Product: selectedProduct, CaseNumber: index, Location: document.get("location") as! String) { [self] () -> () in
                                                                                            addSingleCase(Product: selectedProduct, CaseNumber: index)
                                                                                        }
                                                                                        group.leave()
                                                                                    }
                                                                                }
                                                                            }
                                                                    }
                                                                    group.notify(queue: DispatchQueue.main) { [self] in
                                                                        reloadTable()
                                                                    }
                                                                  } ))
                        present(casesAlreadyExist, animated: true)
                    }
                    else {
                        reloadTable()
                    }
                }
            }
        }
    }
    
    private func buildHeader() {
        let selectCasesLabel = UILabel()
        selectCasesLabel.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .white
        header.addSubview(selectCasesLabel)
        selectCasesLabel.text = "Cases In Freezer"
        selectCasesLabel.font =  UIFont(name: "Avenir Heavy", size: 20)
        selectCasesLabel.textColor = .darkGray
        NSLayoutConstraint.activate([
            selectCasesLabel.leadingAnchor.constraint(equalTo: header.layoutMarginsGuide.leadingAnchor),
            selectCasesLabel.widthAnchor.constraint(equalToConstant: 250),
            selectCasesLabel.heightAnchor.constraint(equalToConstant: 50),
            selectCasesLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor)
        ])
    }
    
    private func setUpSelectionView() {
        let shadowPath = CGPath(ellipseIn: CGRect(x: 0,
                                                  y: productSelect.layer.bounds.height,
                                                    width: productSelect.layer.bounds.width + 20 * 2,
                                                    height: 20),
                                transform: nil)
        productSelect.setTitle(selectedProduct, for: .normal)
        productSelect.addTarget(self, action: #selector(toggleProductView), for: .touchDown)
        productSelect.titleLabel!.font = UIFont(name: "Avenir Heavy", size: 20)
        productSelect.setTitleColor(.black, for: .normal)
        productSelect.layer.masksToBounds = true
        productSelect.layer.cornerRadius = 6.0
        productSelect.layer.cornerRadius = 6.0
        productSelect.layer.borderWidth = 1.0
        productSelect.layer.masksToBounds = true
        productSelect.layer.shadowRadius = 5
        productSelect.layer.shadowOpacity = 0.5
        productSelect.layer.shadowPath = shadowPath
        setProductSelectColor()
        
        caseNumRangeTF.backgroundColor = .white
        caseNumRangeTF.frame = CGRect(x: 65, y: 247, width: numOfCasesText.frame.size.width, height: numOfCasesText.frame.size.height)
        caseNumRangeTF.borderStyle = .roundedRect
        caseNumRangeTF.font = UIFont(name: "Avenir", size: 20)
        caseNumRangeTF.inputView = caseNumRangePV
        caseNumRangeTF.placeholder = "1"
        caseNumRangeTF.addTarget(self, action: #selector(hideProductView), for: .touchDown)
        selectionView.addSubview(caseNumRangeTF)
        
        caseNumRangeTF2.backgroundColor = .white
        caseNumRangeTF2.frame = CGRect(x: 165, y: 247, width: numOfCasesText.frame.size.width, height: numOfCasesText.frame.size.height)
        caseNumRangeTF2.borderStyle = .roundedRect
        caseNumRangeTF2.font = UIFont(name: "Avenir", size: 20)
        caseNumRangeTF2.inputView = caseNumRangePV
        caseNumRangeTF2.placeholder = "100"
        caseNumRangeTF2.addTarget(self, action: #selector(hideProductView), for: .touchDown)
        selectionView.addSubview(caseNumRangeTF2)
        
        numOfCasesText.placeholder = "Case #"
        numOfCasesText.font = UIFont(name: "Avenir", size: 20)
        numOfCasesText.inputView = numOfCases
        numOfCasesText.addTarget(self, action: #selector(hideProductView), for: .touchDown)
        
        caseNumRangePV.delegate = self
        caseNumRangePV.dataSource = self
        numOfCases.dataSource = self
        numOfCases.delegate = self
        
        caseNumRangeLabel.text = "-"
        caseNumRangeLabel.font = UIFont(name: "MuktaMahee Regular", size: 40)
        caseNumRangeLabel.frame = CGRect(x: 145, y: 250, width: 100, height: 46)
        selectionView.addSubview(caseNumRangeLabel)
    }
    
    private func setProductSelectColor() {
        switch selectedProduct {
        case "Filet":
            productSelect.backgroundColor = UIColor(red: 0, green: 1, blue: 1, alpha: 0.6)
        case "Spicy":
            productSelect.backgroundColor = UIColor(red: 0.65, green: 0, blue: 1, alpha: 0.6)
        case "Nugget":
            productSelect.backgroundColor = UIColor(red: 1, green: 0.70, blue: 0.70, alpha: 0.6)
        case "Strip":
            productSelect.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.6)
        case "Grilled Filet":
            productSelect.backgroundColor = UIColor(red: 0.65, green: 0.65, blue: 0, alpha: 0.6)
        case "Grilled Nugget":
            productSelect.backgroundColor = UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 0.6)
        case "Breakfast Filet":
            productSelect.backgroundColor = UIColor(red: 0.90, green: 1, blue: 0, alpha: 0.6)
        default:
            print("Error in setButtonColors switch")
        }
    }
    
    @objc private func toggleProductView() {
        if productView.frame.origin.y == UIScreen.main.bounds.size.height {
            UIView.animate(withDuration: 0.3) {
                self.productView.frame.origin.y = UIScreen.main.bounds.size.height-360
            }
        }
        else {
            UIView.animate(withDuration: 0.3) {
                self.productView.frame.origin.y = UIScreen.main.bounds.size.height
            }
        }
        numOfCasesText.resignFirstResponder()
        caseNumRangeTF.resignFirstResponder()
        caseNumRangeTF2.resignFirstResponder()
    }
    
    @objc private func hideProductView() {
        if productView.frame.origin.y != UIScreen.main.bounds.size.height {
            UIView.animate(withDuration: 0.3) {
                self.productView.frame.origin.y = UIScreen.main.bounds.size.height
            }
        }
    }
    
    @objc private func updateTableProduct() {
        productSelect.setTitle(selectedProduct, for: .normal)
        setProductSelectColor()
        reloadTable()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableProduct), name: NSNotification.Name(changeProductKey), object: nil)
        
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        multipleCasesToggle(multipleCasesSwitch)
        
        getDate()
        
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (Timer) in
            self.getDate()
        })
        
        newCasesTable.delegate = self
        newCasesTable.dataSource = self
        
        buildHeader()
        
        setUpSelectionView()
        
        view.addSubview(productView)
        view.bringSubviewToFront(productView)
        
        numOfCases.tag = 1
        caseNumRangePV.tag = 2
        
        setUpSelectionView()
        reloadTable()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadingView.frame = CGRect(x: 0,
                                   y: 0,
                                   width: newCasesTable.frame.size.width,
                                   height: newCasesTable.frame.size.height)
        loadingView.loadingAnimation.frame = loadingView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            NotificationCenter.default.post(name: Notification.Name(rawValue: vckey), object: nil)
        }
        selectedProduct = "Filet"
    }
}

extension NewCasesViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
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

extension NewCasesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCaseCell = tableView.dequeueReusableCell(withIdentifier: "newCaseCell", for: indexPath) as! newCaseCell
        
        let ptc = ProductTableCell()
        ptc.setCellColor(product: selectedProduct, cell: newCaseCell, indexPath: indexPath.row)
        
        newCaseCell.numLabel.font = UIFont(name: "Avenir", size: 20)
        newCaseCell.productLabel.font = UIFont(name: "Avenir", size: 20)
        newCaseCell.numLabel.text = String(tableCases[indexPath.row].caseNumber)
        newCaseCell.productLabel.text = selectedProduct
        
        return newCaseCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
}

extension NewCasesViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

extension NewCasesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideProductView()
    }
}

