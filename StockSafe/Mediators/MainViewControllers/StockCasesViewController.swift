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

class StockCasesViewController: UIViewController {
    
    // initializing product selectionView for product selection
    private var productSV: SelectionView = SelectionView.init(frame: CGRect(x: 0,
                                                                            y: UIScreen.main.bounds.size.height,
                                                                            width: UIScreen.main.bounds.size.width,
                                                                            height: 360),
                                                              type: .products)
    
    // initializing location selectionView for location selection
    private var locationSV: SelectionView = SelectionView.init(frame: CGRect(x: 0,
                                                                             y: UIScreen.main.bounds.size.height,
                                                                             width: UIScreen.main.bounds.size.width,
                                                                             height: 300),
                                                               type: .locations)
    
    // initializing destination selectionView for destination selection
    private var destinationSV: SelectionView = SelectionView.init(frame: CGRect(x: 0,
                                                                                y: UIScreen.main.bounds.size.height,
                                                                                width: UIScreen.main.bounds.size.width,
                                                                                height: 300),
                                                                  type: .destinations)
    
    // initializing NotConnectedView to be presented when network connection is gone
    private let connectionMonitor = NotConnectedView.init(frame: CGRect(x: UIScreen.main.bounds.maxX/5.5,
                                                                        y: UIScreen.main.bounds.size.height/4,
                                                                        width: UIScreen.main.bounds.size.width/1.5,
                                                                        height: UIScreen.main.bounds.size.height/4))

    // initialiing NWPathMonitor to monitor network connection status
    private let monitor = NWPathMonitor()
    
    // initializing Alerts() for access to relevant UIAlerts
    private let alerts = StockAlerts()
    
    private let manager = StockManager()
    
    @IBOutlet var selectionInterface: UIView!
    
    @IBOutlet var findCasesLabel: UILabel!
    
    @IBOutlet var stockLabel: UILabel!
    
    @IBOutlet var productLabel: UILabel!
    
    @IBOutlet var locationLabel: UILabel!
    
    @IBOutlet var destinationLabel: UILabel!    
    
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var productSelect: UIButton!
    
    @IBOutlet var locationSelect: UIButton!
    
    @IBOutlet var destinationSelect: UIButton!
    
    @IBOutlet var stockingTable: StockTable!
    
    @IBOutlet var undoButton: UIButton!
    
    @IBOutlet var stockButton: UIButton!
    
    @IBAction func stockCases(_ sender: UIButton) {
        undoButton.isEnabled = true
        undoButton.tintColor = .systemBlue
        
        if stockingTable.selectedCases.count == 0 {
            present(alerts.selectCasesAlert, animated: true)
        }
        else if locationSelect.currentTitle == destinationSelect.currentTitle {
            present(alerts.sameDestinationAlert, animated: true)
        }
        else {
            var shelfLifeParam = ShelfLifeParameter.noNewShelfLife
            if productSV.selectedProduct!.shelfLife!.startingPoint == destinationSV.selectedDestination!.name {
                shelfLifeParam = .newShelfLife
            }
            else {
                shelfLifeParam = .noNewShelfLife
            }
            manager.stockAlgorithm(cases: stockingTable.selectedCases, slp: shelfLifeParam, destination: destinationSV.selectedDestination!.name) { [self] maxCapCheck, sl_string, unstockedCases in
                if maxCapCheck == .atMaxCapacity {
                    let maxCapAlert = alerts.configureMCAlert(destination: destinationSV.selectedDestination!.name)
                    present(maxCapAlert, animated: true)
                }
                else if let unstockedCases = unstockedCases {
                    let SLAlert = alerts.configureSLAlert(cases: unstockedCases, sl_String: sl_string!)
                    present(SLAlert, animated: true)
                }
                else {
                    refreshData()
                }
            }
        }
    }
    
    @IBAction func undo(_ sender: UIButton) {
        manager.undo() { [self] in
            if manager.undoQueue.count == 0 {
                undoButton.isEnabled = false
                undoButton.tintColor = .systemGray
            }
        }
    }
    
    @objc private func toggleSelectionView(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if productSV.frame.origin.y == UIScreen.main.bounds.size.height {
                UIView.animate(withDuration: 0.3) { [self] in
                    productSV.frame.origin.y = UIScreen.main.bounds.size.height-360
                    locationSV.frame.origin.y = UIScreen.main.bounds.size.height
                    destinationSV.frame.origin.y = UIScreen.main.bounds.size.height
                }
            }
            else {
                UIView.animate(withDuration: 0.3) { [self] in
                    productSV.frame.origin.y = UIScreen.main.bounds.size.height
                }
            }
        case 1:
            if locationSV.frame.origin.y == UIScreen.main.bounds.size.height {
                UIView.animate(withDuration: 0.3) { [self] in
                    locationSV.frame.origin.y = UIScreen.main.bounds.size.height-300
                    productSV.frame.origin.y = UIScreen.main.bounds.size.height
                    destinationSV.frame.origin.y = UIScreen.main.bounds.size.height
                }
            }
            else {
                UIView.animate(withDuration: 0.3) { [self] in
                    locationSV.frame.origin.y = UIScreen.main.bounds.size.height
                }
            }
        case 2:
            if destinationSV.frame.origin.y == UIScreen.main.bounds.size.height {
                UIView.animate(withDuration: 0.3) { [self] in
                    destinationSV.frame.origin.y = UIScreen.main.bounds.size.height-300
                    productSV.frame.origin.y = UIScreen.main.bounds.size.height
                    locationSV.frame.origin.y = UIScreen.main.bounds.size.height
                }
            }
            else {
                UIView.animate(withDuration: 0.3) { [self] in
                    destinationSV.frame.origin.y = UIScreen.main.bounds.size.height
                }
            }
        default:
            print("Error in StockCasesViewController - toggleSelectionView()")
        }
        
    }
    
    private func refreshData() {
        if manager.products.count != 0 {
            productSelect.setTitle(productSV.selectedProduct?.name, for: .normal)
            productSelect.backgroundColor = HexColor(productSV.selectedProduct?.color ?? "#FFFFF")
            
            locationSelect.setTitle(locationSV.selectedLocation?.name, for: .normal)
            locationSelect.backgroundColor = HexColor(locationSV.selectedLocation?.color ?? "#FFFFF")
            
            destinationSelect.setTitle(destinationSV.selectedDestination?.name, for: .normal)
            destinationSelect.backgroundColor = HexColor(destinationSV.selectedDestination?.color ?? "#FFFFF")
            
            stockingTable.backgroundColor = HexColor(productSV.selectedProduct!.color)
            stockingTable.toggleLoadingView(present: true, color: HexColor(productSV.selectedProduct!.color))
            
            manager.queryFirestore(parameters: (productName: productSV.selectedProduct!.name, location: locationSV.selectedLocation!.name)) { [self] cases, sortedCases in
                stockingTable.reloadCaseTable(cases: cases, sortedCases: sortedCases, currentCount: manager.currentCount, limit: manager.limit)
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    self.stockingTable.toggleLoadingView(present: false, color: nil)
                }
            }
        }
    }

    private func tuckAwaySelectionViews() {
        if productSV.frame.origin.y == UIScreen.main.bounds.size.height-360 {
            toggleSelectionView(productSelect)
        }
        else if locationSV.frame.origin.y == UIScreen.main.bounds.size.height-300 {
            locationSelect.resignFirstResponder()
            toggleSelectionView(locationSelect)
        }
        else if destinationSV.frame.origin.y == UIScreen.main.bounds.size.height-300 {
            destinationSelect.resignFirstResponder()
            toggleSelectionView(destinationSelect)
        }
    }

    private func setUpButtons() {
        if manager.products.count != 0 {
            
            
           
            
        }
        productSelect.titleLabel!.font = VD.boldFont(size: 20)
        productSelect.setTitleColor(.black, for: .normal)
        productSelect.addTarget(self, action: #selector(toggleSelectionView(_:)), for: .touchUpInside)
        VD.configureItemView(view: productSelect)
        productSelect.tag = 0
        
        locationSelect.titleLabel!.font = VD.boldFont(size: 20)
        locationSelect.setTitleColor(.black, for: .normal)
        locationSelect.addTarget(self, action: #selector(toggleSelectionView(_:)), for: .touchUpInside)
        VD.configureItemView(view: locationSelect)
        locationSelect.tag = 1
        
        destinationSelect.titleLabel!.font = VD.boldFont(size: 20)
        destinationSelect.setTitleColor(.black, for: .normal)
        destinationSelect.addTarget(self, action: #selector(toggleSelectionView(_:)), for: .touchUpInside)
        VD.configureItemView(view: destinationSelect)
        destinationSelect.tag = 2
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDate()
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in self.getDate() }
                
        view.addSubview(productSV)
        view.addSubview(locationSV)
        view.addSubview(destinationSV)
        view.addSubview(connectionMonitor)
        
        stockingTable.register(CaseCell.self, forCellReuseIdentifier: CaseCell.identifier)
        
        productSV.mediator = self
        locationSV.mediator = self
        destinationSV.mediator = self
        stockingTable.mediator = self
        manager.mediator = self
        alerts.mediator = self
        
        manager.configureProducts()
        
        undoButton.isEnabled = false
        undoButton.tintColor = .systemGray

        setUpNetworkMonitor()
        setUpButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        VD.addShadow(view: selectionInterface)
        VD.addSubtleShadow(view: findCasesLabel)
        VD.addSubtleShadow(view: stockLabel)
        VD.addSubtleShadow(view: productLabel)
        VD.addSubtleShadow(view: locationLabel)
        VD.addSubtleShadow(view: destinationLabel)
        VD.addShadow(view: stockButton)
        VD.addShadow(view: dateLabel)
        VD.addShadow(view: timeLabel)
        VD.addShadow(view: stockingTable)
        VD.addShadow(view: productSelect)
        VD.addShadow(view: locationSelect)
        VD.addShadow(view: destinationSelect)
        setUpButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let hvc = parent?.children.first(where: { $0.restorationIdentifier == "homeScreen" })
        hvc!.viewDidLoad()
    }
}

extension StockCasesViewController: MediatorProtocol {
    func notify(sender: ColleagueProtocol, event: Event) {
        switch event {
        case .configuredProducts:
            if manager.products.count != 0 {
                productSV.productsToDisplay = manager.products
                productSV.selectedProduct = manager.products[0]
                productSelect.backgroundColor = HexColor(productSV.selectedProduct!.color)
                productSelect.setTitle(productSV.selectedProduct!.name, for: .normal)
                productSV.collectionView.reloadData()
                
                locationSV.locationsToDisplay = manager.filterAndSortLocations(by: productSV.selectedProduct!, for: .locations)
                locationSV.selectedLocation = locationSV.locationsToDisplay![0]
                locationSelect.backgroundColor = HexColor(locationSV.locationsToDisplay![0].color)
                locationSelect.setTitle(locationSV.locationsToDisplay![0].name, for: .normal)
                locationSV.collectionView.reloadData()
                
                destinationSV.destinationsToDisplay = manager.filterAndSortLocations(by: productSV.selectedProduct!, for: .destinations)
                destinationSV.selectedDestination = destinationSV.destinationsToDisplay![0]
                destinationSelect.setTitle(destinationSV.destinationsToDisplay![0].name, for: .normal)
                destinationSelect.backgroundColor = HexColor(destinationSV.destinationsToDisplay![0].color)
                destinationSV.collectionView.reloadData()
            }
            refreshData()
        case .selectionChanged(let type):
            tuckAwaySelectionViews()
            switch type {
                case .products:
                    productSelect.setTitle(productSV.selectedProduct!.name, for: .normal)
                    productSV.collectionView.reloadData()
                    
                    locationSV.locationsToDisplay = manager.filterAndSortLocations(by: productSV.selectedProduct!, for: .locations)
                    locationSV.selectedLocation = locationSV.locationsToDisplay![0]
                    locationSV.collectionView.reloadData()
                    
                    destinationSV.locationsToDisplay = manager.filterAndSortLocations(by: productSV.selectedProduct!, for: .destinations)
                    destinationSV.selectedDestination = destinationSV.destinationsToDisplay![0]
                    destinationSV.collectionView.reloadData()
                    refreshData()
                case .locations:
                    locationSelect.setTitle(locationSV.selectedLocation!.name, for: .normal)
                    refreshData()
                case .destinations:
                    destinationSelect.setTitle(destinationSV.selectedDestination!.name, for: .normal)
                }
        default:
            print("Unnecessary message sent in mediator func notify(): \(event)")
        }
    }
    
    func relayInfo(sender: ColleagueProtocol, info: Any) {
        // Checking if the relayed info is in the specific type required to execute the code within the 'if' statement
        if let info = info as? (ShelfLifeParameter, [Case]) {
            manager.stockAlgorithm(cases: info.1, slp: info.0, destination: destinationSV.selectedLocation!.name) { [self] maxCapCheck, sl_string, unstockedCases in
                refreshData()
            }
        }
    }
}

extension StockCasesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tuckAwaySelectionViews()
    }
}




