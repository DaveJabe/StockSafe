//
//  StockedProViewController.swift
//  Stocked.
//
//  Created by David Jabech on 3/29/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import Lottie
import Network

var changeProductKey = "changeProductKey"
var changeLocationKey = "changeLocationKey"
var changeDestinationKey = "changeDestinationKey"

var selectedProduct = "Filet"
var selectedLocation = "Freezer"
var selectedDestination = "Thawing Cabinet"

class ProductTableCell: UITableViewCell {
    
    @IBOutlet var productTF: UILabel!
    @IBOutlet var caseNumTF: UILabel!
    @IBOutlet var shelfLifeLabel: UILabel!
    @IBOutlet var caseNumView: UIView!
    
    func setCellColor(product: String, cell: UITableViewCell, indexPath: Int) {
        switch product {
        
        case "Filet":
            cell.contentView.backgroundColor = UIColor(red: 0, green: 1, blue: 1, alpha: 0.3)
            
        case "Spicy":
            cell.contentView.backgroundColor = UIColor(red: 0.65, green: 0, blue: 1, alpha: 0.3)
            
        case "Nugget":
            cell.contentView.backgroundColor = UIColor(red: 1, green: 0.70, blue: 0.70, alpha: 0.3)
            
        case "Strip":
            cell.contentView.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.3)
            
        case "Grilled Filet":
            cell.contentView.backgroundColor = UIColor(red: 0.65, green: 0.65, blue: 0, alpha: 0.3)
            
        case "Grilled Nugget":
            cell.contentView.backgroundColor = UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 0.3)
            
        case "Breakfast Filet":
            cell.contentView.backgroundColor = UIColor(red: 0.90, green: 1, blue: 0, alpha: 0.3)
            
        default:
            cell.contentView.backgroundColor = .gray
        }
    }
}

class SearchView: UIViewController {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    private var db: Firestore!
    private var cases: [Case:String] = [:]
    private var sortedCases = [Case]()
    private var selectedCases = [Case]()
    private var DocIDs: [String] = []
    private var currentCount: Int = 0
    private var limit: Int = 0
    private var historyID: String = ""
    private var limitView = UIView()
    private var limitLabel = UILabel()
    private var selectCasesLabel = UILabel()
    
    public let destinations = ["Thawing Cabinet", "Breading Table", "Archive"]
    private let locations = ["Freezer", "Thawing Cabinet", "Breading Table"]
    
    private let productView = ProductCollectionView.init(frame: CGRect(x: 0,
                                                                       y: UIScreen.main.bounds.size.height,
                                                                       width: UIScreen.main.bounds.size.width,
                                                                       height: 360))
    private let locationView = LocationCollectionView.init(frame: CGRect(x: 0,
                                                                         y: UIScreen.main.bounds.size.height,
                                                                         width: UIScreen.main.bounds.size.width,
                                                                         height: 300))
    private let destinationView = DestinationCollectionView.init(frame: CGRect(x: 0,
                                                                               y: UIScreen.main.bounds.size.height,
                                                                               width: UIScreen.main.bounds.size.width,
                                                                               height: 300))
    private let connectionMonitor = NotConnectedView.init(frame: CGRect(x: UIScreen.main.bounds.maxX/5.5,
                                                                        y: UIScreen.main.bounds.size.height/4,
                                                                        width: UIScreen.main.bounds.size.width/1.5,
                                                                        height: UIScreen.main.bounds.size.height/4))
    private let historyView = StockingHistory.init(frame: CGRect(x: 0,
                                                                    y: UIScreen.main.bounds.size.height,
                                                                    width: UIScreen.main.bounds.size.width,
                                                                    height: 300))
    private let loadingView = LoadingView.init()
    
    private let monitor = NWPathMonitor()
    
    private let heard = UIAlertAction(title: "Heard on that.", style: .default, handler: nil)
    
    private var undoQueue: [([Case], String)] = []
    
    @IBOutlet var productSelect: UIButton!
    @IBOutlet var locationSelect: UIButton!
    @IBOutlet var destinationSelect: UIButton!
    
    @IBAction func tappedOutside(_ sender: UITapGestureRecognizer) {
        tuckAwaySelectionViews()
    }
    
    @IBOutlet weak var stockingTable: UITableView!
    
    @IBOutlet var stockingHistoryButton: UIBarButtonItem!
    @IBAction func showStockingHistory(_ sender: UIBarButtonItem) {
        if historyView.frame.origin.y == UIScreen.main.bounds.size.height {
            UIView.animate(withDuration: 0.3) { [self] in
                historyView.frame.origin.y = UIScreen.main.bounds.size.height-300
            }
        }
        else {
            UIView.animate(withDuration: 0.3) { [self] in
                historyView.frame.origin.y = UIScreen.main.bounds.size.height
            }
        }
    }
    
    @IBOutlet var undoButton: UIButton!
    @IBAction func undo(_ sender: UIButton) {
        let casesToUndo = undoQueue.last
        for var caseIndex in casesToUndo!.0 {
            let documentReference = db.collection("testData").document(caseIndex.id!)
            if casesToUndo!.1 == "Freezer" {
                caseIndex.location = casesToUndo!.1
                caseIndex.shelfLife = nil
                do {
                    try documentReference.setData(from: caseIndex)
                }
                catch let error {
                    print("Error updating case data in Firestore: \(error)")
                }
            }
            else if casesToUndo!.1 == "Thawing Cabinet" {
                caseIndex.location = casesToUndo!.1
                caseIndex.breadingStamp = nil
                do {
                    try documentReference.setData(from: caseIndex)
                }
                catch let error {
                    print("Error updating case data in Firestore: \(error)")
                }
            }
            else {
                caseIndex.location = casesToUndo!.1
                do {
                    try documentReference.setData(from: caseIndex)
                }
                catch let error {
                    print("Error updating case data in Firestore: \(error)")
                }
            }
        }
        undoQueue.removeLast()
        if undoQueue.count == 0 {
            undoButton.isEnabled = false
            undoButton.tintColor = .systemGray
        }
        loadCases()
    }
        
    private func stockCases() {
        undoQueue.append((selectedCases, selectedLocation))
        undoButton.isEnabled = true
        undoButton.tintColor = .systemBlue
        
        for caseIndex in selectedCases {
            let document = db.collection("testData").document(caseIndex.id!)
            switch selectedDestination {
            case "Thawing Cabinet":
                if selectedLocation != "Breading Table" && selectedLocation != "Thawing Cabinet" {
                    document.updateData([
                        "location" : "Thawing Cabinet",
                        "shelfLife" : Firebase.Timestamp.init()
                    ])
                }
                else {
                    let thawingCabinetAlert = UIAlertController(title: "Only cases in the freezer can be stocked to the thawing cabinet", message: nil, preferredStyle: .alert)
                    thawingCabinetAlert.addAction(heard)
                    present(thawingCabinetAlert, animated: true)
                }
            case "Breading Table":
                if selectedLocation != "Freezer" && selectedLocation != "Breading Table" {
                    document.updateData([
                        "location" : "Breading Table",
                        "breadingStamp" : Firebase.Timestamp.init()
                    ])
                }
                else {
                    let breadingTableAlert = UIAlertController(title: "Only cases in the thawing cabinet can be stocked to the breading table", message: nil, preferredStyle: .alert)
                    breadingTableAlert.addAction(heard)
                    present(breadingTableAlert, animated: true)
                }
            case "Archive":
                document.delete()
            default: print("error")
            }
        }
        loadCases()
    }
    
    private func loadCases() {
        tuckAwaySelectionViews()
        stockingTable.addSubview(loadingView)
        stockingTable.bringSubviewToFront(loadingView)
        setTableColor(product: selectedProduct, table: stockingTable)
        loadingView.loadingAnimation.backgroundColor = stockingTable.backgroundColor?.withAlphaComponent(1)
        if stockingTable.contentOffset.y > 0 {
            loadingView.frame.origin.y += stockingTable.contentOffset.y
        }
        loadingView.loadingAnimation.play()
        stockingTable.isScrollEnabled = false
        limitView.isHidden = true
        
        cases = [:]
        sortedCases = []
        selectedCases = []
        
        buildLimitView()
        
        let selectedProduct = db.collection("testData")
            .whereField("product", isEqualTo: selectedProduct)
            .whereField("location", isEqualTo: selectedLocation)
            .whereField("userID", isEqualTo: userIDkey)
        
        selectedProduct.getDocuments() { [self] querySnapshot, err in
            if err != nil {
                print("Error getting documents - loadCases: \(String(describing: err))")
            }
            else {
                guard let documents = querySnapshot?.documents else {
                    print("no documents found - loadCases")
                    return
                }
                let group = DispatchGroup()
                for document in documents {
                    group.enter()
                    let thisCase = try? document.data(as: Case.self)
                    let expiryDate = getExpirationDate(timestamp: thisCase?.shelfLife)
                    cases[thisCase!] = expiryDate
                    group.leave()
                    }
                group.notify(queue: DispatchQueue.main) {
                    sortedCases = cases.keys.sorted(by: {$0.caseNumber < $1.caseNumber})
                    let noCases = UILabel.init(frame: stockingTable.bounds)
                    noCases.text = "No Cases Found."
                    noCases.font = UIFont(name: "Avenir", size: 20)
                    noCases.textAlignment = .center
                    stockingTable.backgroundView = noCases
                    if cases.count > 0 {
                        stockingTable.backgroundView = nil
                    }
                    setLimitLabelText()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                        loadingView.removeFromSuperview()
                        limitView.isHidden = false
                        stockingTable.isScrollEnabled = true
                        stockingTable.reloadData()
                    }
                }
            }
        }
    }
    
    private func getExpirationDate(timestamp: Date?) -> String {
        var expirationDate = ""
        if timestamp != nil {
            let offsetDate = Calendar.current.date(byAdding: .hour, value: -4, to: Date())
            
            let components = Calendar.current.dateComponents([.day], from: timestamp!, to: offsetDate!)
            let hourComponents = Calendar.current.dateComponents([.hour], from: timestamp!, to: offsetDate!)
            
            let daysRemaining = 4 - components.day!
            let hoursRemaining = 96 - hourComponents.hour!
            
            if daysRemaining == 1 {
                expirationDate = "Expires in 1 day"
            }
            else if daysRemaining < 1 {
                if hoursRemaining <= 0 {
                    expirationDate = "Expired"
                }
                else {
                    expirationDate = "Expires in \(hoursRemaining) hours"
                }
            }
            else if daysRemaining > 1 {
                expirationDate = "Expires in \(daysRemaining) days"
            }
        }
        return expirationDate
    }
    
    public func setTableColor(product: String, table: UITableView) {
        switch product {
        case "Filet":
            table.backgroundColor = UIColor(red: 0, green: 1, blue: 1, alpha: 0.4)
        case "Spicy":
            table.backgroundColor = UIColor(red: 0.65, green: 0, blue: 1, alpha: 0.4)
        case "Nugget":
            table.backgroundColor = UIColor(red: 1, green: 0.70, blue: 0.70, alpha: 0.4)
        case "Strip":
            table.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.4)
        case "Grilled Filet":
            table.backgroundColor = UIColor(red: 0.65, green: 0.65, blue: 0, alpha: 0.4)
        case "Grilled Nugget":
            table.backgroundColor = UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 0.4)
        case "Breakfast Filet":
            table.backgroundColor = UIColor(red: 0.90, green: 1, blue: 0, alpha: 0.4)
        default:
            print("Error in setTableColor")
        }
    }
    
    private func determineLimit(Product: String, Location: String, completion: @escaping () -> Void) {
        
        db.collection("testData")
            .whereField("product", isEqualTo: Product)
            .whereField("location", isEqualTo: Location)
            .whereField("userID", isEqualTo: userIDkey)
            .getDocuments() { [self] (querySnapshot, err) in
                if let err = err {
                    print("error in determineLimit: \(err)")
                }
                else {
                    switch Location {
                    case "Thawing Cabinet":
                        switch Product {
                        case "Filet":
                            limit = UserDefaults.standard.integer(forKey: "tc_filet")
                            currentCount = querySnapshot!.documents.count
                        case "Spicy":
                            limit = UserDefaults.standard.integer(forKey: "tc_spicy")
                            currentCount = querySnapshot!.documents.count
                        case "Nugget":
                            limit = UserDefaults.standard.integer(forKey: "tc_nugget")
                            currentCount = querySnapshot!.documents.count
                        case "Strip":
                            limit = UserDefaults.standard.integer(forKey: "tc_strip")
                            currentCount = querySnapshot!.documents.count
                        case "Grilled Filet":
                            limit = UserDefaults.standard.integer(forKey: "tc_gfilet")
                            currentCount = querySnapshot!.documents.count
                        case "Grilled Nugget":
                            limit = UserDefaults.standard.integer(forKey: "tc_gnugget")
                            currentCount = querySnapshot!.documents.count
                        case "Breakfast Filet":
                            limit = UserDefaults.standard.integer(forKey: "tc_bfilet")
                            currentCount = querySnapshot!.documents.count
                        default:
                            limit = 0
                            print("error in product switch determine limit")
                        }
                    case "Breading Table":
                        switch Product {
                        case "Filet":
                            limit = UserDefaults.standard.integer(forKey: "bt_filet")
                            currentCount = querySnapshot!.documents.count
                            print(currentCount)
                            print(limit)
                        case "Spicy":
                            limit = UserDefaults.standard.integer(forKey: "bt_spicy")
                            currentCount = querySnapshot!.documents.count
                        case "Nugget":
                            limit = UserDefaults.standard.integer(forKey: "bt_nugget")
                            currentCount = querySnapshot!.documents.count
                        case "Strip":
                            limit = UserDefaults.standard.integer(forKey: "bt_strip")
                            currentCount = querySnapshot!.documents.count
                        case "Grilled Filet":
                            limit = UserDefaults.standard.integer(forKey: "bt_gfilet")
                            currentCount = querySnapshot!.documents.count
                        case "Grilled Nugget":
                            limit = UserDefaults.standard.integer(forKey: "bt_gnugget")
                            currentCount = querySnapshot!.documents.count
                        case "Breakfast Filet":
                            limit = UserDefaults.standard.integer(forKey: "bt_bfilet")
                            currentCount = querySnapshot!.documents.count
                        default:
                            limit = 0
                            print("error in product switch determine limit")
                        }
                    default:
                        print("location = freezer (no limit)")
                    }
                }
                completion()
            }
    }
    
    private func buildLimitView() {
        limitLabel.translatesAutoresizingMaskIntoConstraints = false
        selectCasesLabel.translatesAutoresizingMaskIntoConstraints = false
        limitView.backgroundColor = .white
        limitView.addSubview(limitLabel)
        limitView.addSubview(selectCasesLabel)
        limitLabel.font = UIFont(name: "Avenir Heavy", size: 20)
        selectCasesLabel.text = "Select Cases:"
        selectCasesLabel.font =  UIFont(name: "Avenir Heavy", size: 20)
        selectCasesLabel.textColor = .darkGray
        NSLayoutConstraint.activate([
                                        selectCasesLabel.leadingAnchor.constraint(equalTo: limitView.layoutMarginsGuide.leadingAnchor),
                                        selectCasesLabel.widthAnchor.constraint(equalToConstant: 150),
                                        selectCasesLabel.heightAnchor.constraint(equalToConstant: 50),
                                        selectCasesLabel.centerYAnchor.constraint(equalTo: limitView.centerYAnchor),
                                        
                                        limitLabel.heightAnchor.constraint(equalToConstant: 30),
                                        limitLabel.trailingAnchor.constraint(equalTo: limitView.layoutMarginsGuide.trailingAnchor),
                                        limitLabel.centerYAnchor.constraint(equalTo: limitView.centerYAnchor)])
        setLimitLabelText()
    }
    
    private func setLimitLabelText() {
        if UserDefaults.standard.bool(forKey: "SetLimitsKey") {
            determineLimit(Product: selectedProduct, Location: selectedLocation) { [self] () -> () in
                if selectedLocation == "Freezer" {
                    limitLabel.isHidden = true
                }
                else {
                    limitLabel.isHidden = false
                }
                if currentCount >= limit {
                    limitLabel.textColor = .red
                }
                else {
                    limitLabel.textColor = .darkGray
                }
                limitLabel.text = "Capacity: \(currentCount)/\(limit)"
            }
        }
        else {
            limitLabel.text = ""
        }
    }
    
    private func checkCapacity(currentCount: Int, limit: Int) -> Bool {
        if UserDefaults.standard.bool(forKey: "SetLimitsKey") {
            if currentCount >= limit {
                return false
            }
            else if currentCount + selectedCases.count > limit {
                return false
            }
            else {
                return true
            }
        }
        else {
            return true
        }
    }
    
    @objc private func toggleProductView(_ sender: UIButton) {
        if productView.frame.origin.y == UIScreen.main.bounds.size.height {
            UIView.animate(withDuration: 0.3) { [self] in
                productView.frame.origin.y = UIScreen.main.bounds.size.height-360
                locationView.frame.origin.y = UIScreen.main.bounds.size.height
                destinationView.frame.origin.y = UIScreen.main.bounds.size.height
            }
        }
        else {
            UIView.animate(withDuration: 0.3) { [self] in
                productView.frame.origin.y = UIScreen.main.bounds.size.height
            }
        }
    }
    
    @objc private func toggleLocationView(_ sender: UIButton) {
        if locationView.frame.origin.y == UIScreen.main.bounds.size.height {
            UIView.animate(withDuration: 0.3) { [self] in
                locationView.frame.origin.y = UIScreen.main.bounds.size.height-300
                productView.frame.origin.y = UIScreen.main.bounds.size.height
                destinationView.frame.origin.y = UIScreen.main.bounds.size.height
            }
        }
        else {
            UIView.animate(withDuration: 0.3) { [self] in
                locationView.frame.origin.y = UIScreen.main.bounds.size.height
            }
        }
    }
    
    @objc private func toggleDestinationView(_ sender: UIButton) {
        if destinationView.frame.origin.y == UIScreen.main.bounds.size.height {
            UIView.animate(withDuration: 0.3) { [self] in
                destinationView.frame.origin.y = UIScreen.main.bounds.size.height-300
                productView.frame.origin.y = UIScreen.main.bounds.size.height
                locationView.frame.origin.y = UIScreen.main.bounds.size.height
            }
        }
        else {
            UIView.animate(withDuration: 0.3) { [self] in
                destinationView.frame.origin.y = UIScreen.main.bounds.size.height
            }
        }
    }
    
    private func tuckAwaySelectionViews() {
        if productView.frame.origin.y == UIScreen.main.bounds.size.height-360 {
            toggleProductView(productSelect)
        }
        else if locationView.frame.origin.y == UIScreen.main.bounds.size.height-300 {
            locationSelect.resignFirstResponder()
            toggleLocationView(locationSelect)
        }
        else if destinationView.frame.origin.y == UIScreen.main.bounds.size.height-300 {
            destinationSelect.resignFirstResponder()
            toggleDestinationView(destinationSelect)
        }
    }
    
    @objc public func changeProduct() {
        setButtonColorsAndTitles()
        loadCases()
    }
    
    @objc public func changeLocation() {
        switch selectedLocation {
        case "Freezer":
            destinationView.collectionView(destinationView.destinationView, didSelectItemAt: IndexPath(item: 0, section: 0))
        case "Thawing Cabinet":
            destinationView.collectionView(destinationView.destinationView, didSelectItemAt: IndexPath(item: 1, section: 0))
        case "Breading Table":
            destinationView.collectionView(destinationView.destinationView, didSelectItemAt: IndexPath(item: 2, section: 0))
        default:
            print("Error: selectedLocation != an actual location")
        }
        setButtonColorsAndTitles()
        loadCases()
    }
    
    @objc public func changeDestination() {
        setButtonColorsAndTitles()
    }
    
    private func setUpButtons() {
        let shadowPath = CGPath(ellipseIn: CGRect(x: 0,
                                                  y: productSelect.layer.bounds.height,
                                                    width: productSelect.layer.bounds.width + 20 * 2,
                                                    height: 20),
                                transform: nil)
        
        productSelect.titleLabel!.font = UIFont(name: "Avenir Heavy", size: 20)
        productSelect.setTitleColor(.black, for: .normal)
        productSelect.addTarget(self, action: #selector(toggleProductView(_:)), for: .touchUpInside)
        productSelect.layer.masksToBounds = true
        productSelect.layer.cornerRadius = 6.0
        productSelect.layer.cornerRadius = 6.0
        productSelect.layer.borderWidth = 1.0
        productSelect.layer.masksToBounds = true
        productSelect.layer.shadowRadius = 5
        productSelect.layer.shadowOpacity = 0.5
        productSelect.layer.shadowPath = shadowPath
        
        locationSelect.titleLabel!.font = UIFont(name: "Avenir Heavy", size: 20)
        locationSelect.setTitleColor(.black, for: .normal)
        locationSelect.addTarget(self, action: #selector(toggleLocationView(_:)), for: .touchUpInside)
        locationSelect.layer.masksToBounds = true
        locationSelect.layer.cornerRadius = 6.0
        locationSelect.layer.cornerRadius = 6.0
        locationSelect.layer.borderWidth = 1.0
        locationSelect.layer.masksToBounds = true
        locationSelect.layer.shadowRadius = 5
        locationSelect.layer.shadowOpacity = 0.5
        locationSelect.layer.shadowPath = shadowPath
        
        destinationSelect.titleLabel!.font = UIFont(name: "Avenir Heavy", size: 20)
        destinationSelect.setTitleColor(.black, for: .normal)
        destinationSelect.addTarget(self, action: #selector(toggleDestinationView(_:)), for: .touchUpInside)
        destinationSelect.layer.masksToBounds = true
        destinationSelect.layer.cornerRadius = 6.0
        destinationSelect.layer.cornerRadius = 6.0
        destinationSelect.layer.borderWidth = 1.0
        destinationSelect.layer.masksToBounds = true
        destinationSelect.layer.shadowRadius = 5
        destinationSelect.layer.shadowOpacity = 0.5
        destinationSelect.layer.shadowPath = shadowPath
        
        setButtonColorsAndTitles()
    }
    
    private func setButtonColorsAndTitles() {
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
        productSelect.setTitle(selectedProduct, for: .normal)
        
        switch selectedLocation {
        case "Freezer":
            locationSelect.backgroundColor = HexColor("126e82", alpha: 0.6)
        case "Thawing Cabinet":
            locationSelect.backgroundColor = HexColor("7eca9c", alpha: 0.6)
        case "Breading Table":
            locationSelect.backgroundColor = HexColor("f0c929", alpha: 0.6)
        default:
            print("Error in setButtonColors switch")
        }
        locationSelect.setTitle(selectedLocation, for: .normal)
        
        switch selectedDestination {
        case "Thawing Cabinet":
            destinationSelect.backgroundColor = HexColor("7eca9c", alpha: 0.6)
        case "Breading Table":
            destinationSelect.backgroundColor = HexColor("f0c929", alpha: 0.6)
        case "Archive":
            destinationSelect.backgroundColor = HexColor("c15050", alpha: 0.6)
        default:
            print("Error in setButtonColors switch")
        }
        destinationSelect.setTitle(selectedDestination, for: .normal)
    }
    
    private func setUpNetworkMonitor() {
        view.addSubview(connectionMonitor)
        
        monitor.pathUpdateHandler = { [self] path in
            if path.status == .satisfied {
                print("we're connected!")
                connectionMonitor.isHidden = true
                view.isUserInteractionEnabled = true
                
            }
            else {
                print("we're not connected :(")
                connectionMonitor.isHidden = false
                view.isUserInteractionEnabled = false
                connectionMonitor.notConnectedAnimation.play()
            }
        }
        
        let queue = DispatchQueue.main
        monitor.start(queue: queue)
    }
    
    private func getDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: Date())
        timeLabel.text = timeFormatter.string(from: Date())
    }
    
    private func getHistoryID(completion: @escaping () -> Void) {
        db.collection("stockingData")
            .whereField("userID", isEqualTo: userIDkey)
            .whereField("date", isEqualTo: Date())
            .getDocuments() { [self] querySnapshot, err in
                if err != nil {
                    print("Error getting documents in configureHistory: \(String(describing: err))")
                }
                else {
                    if querySnapshot!.documents.count > 1 {
                        print("Error: more than one stockingData for same date")
                    }
                    else {
                        historyID = querySnapshot!.documents[0].documentID
                        completion()
                    }
                }
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeProduct), name: NSNotification.Name(changeProductKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeLocation), name: NSNotification.Name(changeLocationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeDestination), name: NSNotification.Name(changeDestinationKey), object: nil)
        
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        getDate()
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in self.getDate() }
                
        view.addSubview(productView)
        view.addSubview(locationView)
        view.addSubview(destinationView)
        view.addSubview(connectionMonitor)
        
        selectedProduct = "Filet"
        stockingTable.dataSource = self
        stockingTable.delegate = self
        stockingTable.allowsMultipleSelection = true
        
        undoQueue = []
        undoButton.isEnabled = false
        undoButton.tintColor = .systemGray
        
//        getHistoryID {
//        }
        setUpNetworkMonitor()
        setUpButtons()
        buildLimitView()
        loadCases()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadingView.frame = CGRect(x: 0,
                                   y: 0,
                                   width: stockingTable.frame.size.width,
                                   height: stockingTable.frame.size.height)
        loadingView.loadingAnimation.frame = loadingView.bounds
        setUpButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        productView.productView.reloadData()
        locationView.locationView.reloadData()
        destinationView.destinationView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            NotificationCenter.default.post(name: Notification.Name(rawValue: vckey), object: nil)
        }
    }
    
    @IBAction func stockButton(_ sender: UIButton) {
        print(selectedCases.count)
        
        if selectedProduct == "" || selectedLocation == "" || selectedDestination == "" || selectedCases.count == 0 {
            let emptyFieldAlert = UIAlertController(title: "Please fill in all fields and select cases to stock.", message: nil, preferredStyle: .alert)
            emptyFieldAlert.addAction(heard)
            present(emptyFieldAlert, animated: true)
        }
        else if selectedDestination != "Archive" {
            determineLimit(Product: selectedProduct, Location: selectedDestination) { [self] () -> () in
                let capCheck = checkCapacity(currentCount: currentCount, limit: limit)
                if capCheck {
                    stockCases()
                }
                else {
                    let maxCapLimit = UIAlertController(title: "\(selectedDestination) doesn't have enough space!", message: "Please remove cases from the \(selectedDestination) or stock fewer cases.", preferredStyle: .alert)
                    maxCapLimit.addAction(heard)
                    present(maxCapLimit, animated: true)
                }
            }
        }
        else {
            stockCases()
        }
    }
}
    
extension SearchView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tuckAwaySelectionViews()
        selectedCases.append(sortedCases[indexPath.row])
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedCases.removeAll(where: {$0 == sortedCases[indexPath.row]} )
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sortedCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let caseCell = tableView.dequeueReusableCell(withIdentifier: "caseCell", for: indexPath) as? ProductTableCell else {
            return UITableViewCell()
        }
        let caseAtIndexPath = sortedCases[indexPath.row]
        
        caseCell.shelfLifeLabel.font = UIFont(name: "Avenir", size: 20)
        caseCell.productTF.font = UIFont(name: "Avenir", size: 20)
        caseCell.caseNumTF.font = UIFont(name: "Avenir", size: 20)
        
        caseCell.productTF.text = selectedProduct
        caseCell.shelfLifeLabel.text = cases[caseAtIndexPath]
        caseCell.caseNumTF.text = String(caseAtIndexPath.caseNumber)
        if cases[caseAtIndexPath] == "Expired" {
            caseCell.shelfLifeLabel.textColor = .systemRed
        }
        caseCell.setCellColor(product: selectedProduct, cell: caseCell, indexPath: indexPath.row)
        caseCell.caseNumView.backgroundColor = caseCell.backgroundColor?.withAlphaComponent(0.5)
       
        return caseCell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let tableFooter = UIView()
        tableFooter.frame = stockingTable.bounds
        return tableFooter
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return limitView
    }
}

extension SearchView:  UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

extension SearchView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tuckAwaySelectionViews()
    }
}




