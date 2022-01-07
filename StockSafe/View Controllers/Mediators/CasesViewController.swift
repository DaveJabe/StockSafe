//
//  CasesViewController.swift
//  StockSafe
//
//  Created by David Jabech on 7/27/21.
//

import UIKit

class CasesViewController: UIViewController {
    
    // Initializing manager for handling reading/writing cases data to/from Firestore
    private var manager = CaseManager()
    
    // Initializing selectionView for product selection
    private var productSV = SelectionView.init(frame: CGRect(x: 0,
                                                             y: UIScreen.main.bounds.size.height-100,
                                                             width: UIScreen.main.bounds.size.width,
                                                             height: 360),
                                               type: .products)
    
    // Initializing selectionView for location selection
    private var locationSV = SelectionView.init(frame: CGRect(x: 0,
                                                              y: UIScreen.main.bounds.size.height-100,
                                                              width: UIScreen.main.bounds.size.width,
                                                              height: 300),
                                                type: .locations)
    
    // Initializing selectionView for destination selection
    private var destinationSV = SelectionView.init(frame: CGRect(x: 0,
                                                                 y: UIScreen.main.bounds.size.height-100,
                                                                 width: UIScreen.main.bounds.size.width,
                                                                 height: 300),
                                                   type: .destinations)
    
    // Initializing toolbar from which the user will have access to three options (new cases, stock cases, or select cases)
    private var toolbar = ToolbarView.init(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: UIScreen.main.bounds.width,
                                                         height: UIScreen.main.bounds.height/10),
                                           type: .caseToolbar)
    
    // Intitalizing submenu (which is revealed by the toolbar) for product, location, and destination selection/new cases PTFs (and a done button for both stocking and new cases)
    public var submenu = SubmenuView.init(frame: CGRect(x: 0,
                                                        y: UIScreen.main.bounds.height/10,
                                                        width: UIScreen.main.bounds.width,
                                                        height: UIScreen.main.bounds.height/6.5),
                                          option: .newCases)
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        return scrollView
    }()
    
    // Intializing caseTable for user interaction with a list cases
    private let caseTable = CaseTable(frame: .zero, style: .grouped)
    
    // Setting up frames, shadows, and layers for subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.backgroundColor = ColorThemes.backgroundColor
        
        let tableY = (submenu.frame.maxY)+30
        scrollView.frame = CGRect(x: 50,
                                  y: tableY,
                                  width: UIScreen.main.bounds.size.width-100,
                                  height:  UIScreen.main.bounds.size.height-tableY-200)
        
        scrollView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        scrollView.layer.cornerRadius = 10
        caseTable.frame = CGRect(x: 0,
                                 y: 0,
                                 width: scrollView.frame.size.width,
                                 height: scrollView.frame.size.height)
        caseTable.layer.masksToBounds = true
        caseTable.layer.cornerRadius = 10
        
        scrollView.addShadow()
        toolbar.addSubtleShadow()
        submenu.addShadow()
        
        caseTable.toggleLoadingView(present: true, color: .systemGray6)
    }
    
    // Adding subviews, setting mediators, and setting up subviews
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(toolbar)
        view.addSubview(submenu)
        view.addSubview(scrollView)
        scrollView.addSubview(caseTable)
        
        // These subviews are brought to front only to ensure that they're not behind any views (they shouldn't be anyways because they're the last to be added)
        view.addSubview(productSV)
        view.bringSubviewToFront(productSV)
        view.addSubview(locationSV)
        view.bringSubviewToFront(locationSV)
        view.addSubview(destinationSV)
        view.bringSubviewToFront(destinationSV)
        
        // Setting the mediator for all of the colleagues to self
        manager.setMediator(mediator: self)
        toolbar.setMediator(mediator: self)
        caseTable.setMediator(mediator: self)
        submenu.setMediator(mediator: self)
        productSV.setMediator(mediator: self)
        locationSV.setMediator(mediator: self)
        destinationSV.setMediator(mediator: self)
        
        caseTable.register(CaseCell.self, forCellReuseIdentifier: CaseCell.identifier)
        
        // Ensuring that the manager querys Firestore for product information, from which self will use case, product, and location information for case management
        manager.configureProducts()
        
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        caseTable.bounces = false
        caseTable.isScrollEnabled = true
        
        
    }
    
    
    // Refreshes case data (at start-up and when product or location selection changes
    private func refreshData() {
        caseTable.currentColor = HexColor(productSV.selectedProduct!.color)
        manager.queryFirestore(parameters: (productName: productSV.selectedProduct!.name, locationName: locationSV.selectedLocation!.name), sort: nil) { [self] cases in
            caseTable.reloadCaseTable(cases: cases, location: locationSV.selectedLocation!.name, currentCount: manager.currentCount, limit: manager.limit)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                scrollView.contentSize = caseTable.contentSize
                self.caseTable.toggleLoadingView(present: false, color: nil)
            }
        }
    }
    
    // Refreshes product select button when product changes
    private func refreshProductSelect() {
        submenu.productSelect.setTitle(productSV.selectedProduct!.name, for: .normal)
        submenu.productSelect.backgroundColor = HexColor(productSV.selectedProduct!.color)
    }
    
    // Refreshes locations displayed by locationSV and location select button when product changes
    private func refreshLocations() {
        locationSV.locationsToDisplay = manager.filterAndSortLocations(by: productSV.selectedProduct!, includeArchive: false)
        locationSV.selectedLocation = locationSV.locationsToDisplay![0]
        submenu.locationSelect.setTitle(locationSV.locationsToDisplay![0].name, for: .normal)
        submenu.locationSelect.backgroundColor = HexColor(locationSV.locationsToDisplay![0].color)
        locationSV.collectionView.reloadData()
        // This line of code is done to ensure that selectedLocationKey is not nil when locations are refreshed
        locationSV.selectedLocationKey = [0:locationSV.locationsToDisplay![0].name]
    }
    
    // Refreshes destinations displayed by destinationSV and destination select button when product changes
    private func refreshDestinations() {
        destinationSV.destinationsToDisplay = manager.filterAndSortLocations(by: productSV.selectedProduct!, includeArchive: true)
        destinationSV.selectedDestination = destinationSV.destinationsToDisplay![1]
        submenu.destinationSelect.setTitle(destinationSV.destinationsToDisplay![0].name, for: .normal)
        submenu.destinationSelect.backgroundColor = HexColor(destinationSV.destinationsToDisplay![0].color)
        destinationSV.collectionView.reloadData()
        // This line of code is done to ensure that selectedDestinationKey is not nil when destinations are refreshed
        destinationSV.selectedDestinationKey = [0:destinationSV.destinationsToDisplay![0].name]
    }
    
    // Toggles (shows/hides) selection views respective to the submenu button (sender) tag
    @objc private func toggleSelectionView(tag: Int) {
        switch tag {
        case 0:
            if productSV.frame.origin.y == UIScreen.main.bounds.size.height-100 {
                UIView.animate(withDuration: 0.3) { [self] in
                    productSV.frame.origin.y = UIScreen.main.bounds.size.height-500
                    locationSV.frame.origin.y = UIScreen.main.bounds.size.height-100
                    destinationSV.frame.origin.y = UIScreen.main.bounds.size.height-100
                }
            }
            else {
                UIView.animate(withDuration: 0.3) { [self] in
                    productSV.frame.origin.y = UIScreen.main.bounds.size.height-100
                }
            }
        case 1:
            if locationSV.frame.origin.y == UIScreen.main.bounds.size.height-100 {
                UIView.animate(withDuration: 0.3) { [self] in
                    locationSV.frame.origin.y = UIScreen.main.bounds.size.height-500
                    productSV.frame.origin.y = UIScreen.main.bounds.size.height-100
                    destinationSV.frame.origin.y = UIScreen.main.bounds.size.height-100
                }
            }
            else {
                UIView.animate(withDuration: 0.3) { [self] in
                    locationSV.frame.origin.y = UIScreen.main.bounds.size.height-100
                }
            }
        case 2:
            if destinationSV.frame.origin.y == UIScreen.main.bounds.size.height-100 {
                UIView.animate(withDuration: 0.3) { [self] in
                    destinationSV.frame.origin.y = UIScreen.main.bounds.size.height-500
                    productSV.frame.origin.y = UIScreen.main.bounds.size.height-100
                    locationSV.frame.origin.y = UIScreen.main.bounds.size.height-100
                }
            }
            else {
                UIView.animate(withDuration: 0.3) { [self] in
                    destinationSV.frame.origin.y = UIScreen.main.bounds.size.height-100
                }
            }
        default:
            print("Error in StockCasesViewController - toggleSelectionView()")
        }
    }
    
    // Tucks away any selection view that may be visible (to be used when data needs to be refreshed or the user taps on something else)
    public func tuckAwaySelectionViews() {
        if productSV.frame.origin.y == UIScreen.main.bounds.size.height-500 {
            toggleSelectionView(tag: 0)
        }
        else if locationSV.frame.origin.y == UIScreen.main.bounds.size.height-500 {
            toggleSelectionView(tag: 1)
        }
        else if destinationSV.frame.origin.y == UIScreen.main.bounds.size.height-500 {
            toggleSelectionView(tag: 2)
        }
    }
    
    // Func for getting the shelf life paramter for when the user would like to stock cases
    private func getSLPForStocking() -> ShelfLifeParameter {
        if destinationSV.selectedDestinationKey!.first!.value == productSV.selectedProduct!.shelfLife?.startingPoint.first?.value {
            return .newSL
        }
        else {
            return .noNewSL
        }
    }
    
    // Func for getting the shelf life paramter for when the user would like to add cases
    private func getSLPForAdding() -> ShelfLifeParameter {
        if locationSV.selectedLocationKey!.first!.value == productSV.selectedProduct!.shelfLife?.startingPoint.first?.value {
            return .newSL
        }
        else {
            return .noNewSL
        }
    }
    
    // Func for adding cases (single or multiple; uses algorithms from manager)
    private func addNewCases() {
        if submenu.convertibleLabel.text == "Single Case" {
            if submenu.ptfOne!.text == "" {
                presentSimpleAlert(title: "Please enter a case number", message: nil)
            }
            else {
                caseTable.undoButton.toggle(on: true)
                caseTable.toggleLoadingView(present: true, color: HexColor(productSV.selectedProduct!.color))
                manager.singleNewCaseAlgo(caseAttributes: (caseNumber: Int(submenu.ptfOne!.text!)!,
                                                           productName: productSV.selectedProduct!.name,
                                                           locationName: locationSV.selectedLocation!.name),
                                          slp: getSLPForAdding()) { [self] existCheck, aec_string in
                    if existCheck == .alreadyExists {
                        presentSimpleAlert(title: aec_string!, message: "Would you like to archive and replace this case?")
                    }
                    else {
                        refreshData()
                    }
                }
            }
        }
        else {
            if submenu.ptfOne!.text == "" || submenu.ptfTwo!.text == "" {
                presentSimpleAlert(title: "Please enter a valid case range", message: nil)
            }
            else if Int(submenu.ptfOne!.text!)! > Int(submenu.ptfTwo!.text!)! {
                presentSimpleAlert(title: "Please enter a valid case range", message: "The first case should be a smaller number than the last case.")
            }
            else {
                caseTable.undoButton.toggle(on: true)
                caseTable.toggleLoadingView(present: true, color: HexColor(productSV.selectedProduct!.color))
                let casesToAdd = Array(Int(submenu.ptfOne!.text!)!...Int(submenu.ptfTwo!.text!)!)
                manager.multipleNewCasesAlgo(caseAttributes: (caseRange: casesToAdd,
                                                              productName: productSV.selectedProduct!.name,
                                                              locationName: locationSV.selectedLocation!.name),
                                             slp: getSLPForAdding()) { [self] aec_string in
                    if aec_string != "" {
                        var message: String
                        if !aec_string.contains(",") {
                            message = "Would you like to archive and replace this case?"
                        }
                        else {
                            message = "Would you like to archive and replace those cases?"
                        }
                        presentAlertWithOptions(title: aec_string, message: message, options: "Archive and replace", "No") { option in
                            if option == 0 {
                                // this function works for a single case as well
                                manager.archiveAndReplaceMultipleCases { [self] in
                                    refreshData()
                                }
                            }
                            else {
                                caseTable.toggleLoadingView(present: false, color: nil)
                            }
                        }
                    }
                    else {
                        refreshData()
                    }
                }
            }
        }
    }
    
    // Func for stocking cases (single or multiple; uses algorithms from manager)
    private func stockCases() {
        if caseTable.selectedCases.count == 0 {
            presentSimpleAlert(title: "Please select cases to stock", message: nil)
        }
        else if submenu.locationSelect.currentTitle == submenu.destinationSelect.currentTitle {
            presentSimpleAlert(title: "Please select a different destination", message: "The selected destination cannot be the same as the current location.")
        }
        else {
            caseTable.undoButton.toggle(on: true)
            caseTable.toggleLoadingView(present: true, color: HexColor(productSV.selectedProduct!.color)?.withAlphaComponent(0.5))
            manager.stockAlgorithm(cases: caseTable.selectedCases, slp: getSLPForStocking(), destination: destinationSV.selectedDestinationKey!, product: productSV.selectedProduct!) { [self] maxCapCheck, sl_string, unstockedCases in
                if maxCapCheck == .atMaxCapacity {
                    presentSimpleAlert(title: "\(destinationSV.selectedDestination!.name) doesn't have enough space",
                                       message: "Please remove cases from the \(destinationSV.selectedDestination!.name) or stock fewer cases.")
                    caseTable.toggleLoadingView(present: false, color: nil)
                }
                else if !unstockedCases.isEmpty {
                    presentAlertWithOptions(title: "Shelf life for this product begins at a later location, would you like to erase the shelf lives for these cases?",
                                            message: "Cases \(sl_string) already have shelf lives",
                                            options: "Stock cases and erase shelf lives",
                                            "Stock cases but don't erase shelf lives",
                                            "Don't stock cases") { option in
                        var slp2: ShelfLifeParameter? = nil
                        switch option {
                        case 0:
                            slp2 = .eraseSL
                        case 1:
                            slp2 = .doNotEraseSL
                        case 2:
                            return
                        default:
                            print("Error in stockCases() - line 331")
                        }
                        if let slp2 = slp2 {
                            manager.stockAlgorithm(cases: unstockedCases, slp: slp2, destination: destinationSV.selectedDestinationKey!, product: productSV.selectedProduct!) { [self] maxCapCheck, sl_string, unstockedCases in
                                refreshData()
                            }
                        }
                    }
                }
                else {
                    refreshData()
                }
            }
        }
    }
}

extension CasesViewController: MediatorProtocol {
    // MediatorProtocol function intended for receiving a message from a ColleagueProtocol in the form of an event (see ColleagueProtocol for enum of events)
    func notify(sender: ColleagueProtocol, event: Event) {
        // Switch to account for different events
        switch event {
        // event where manager has completed configuring products
        case .configuredProducts:
            if manager.products.count != 0 {
                productSV.productsToDisplay = manager.products
                productSV.selectedProduct = manager.products[0]
                refreshProductSelect()
                productSV.collectionView.reloadData()
                
                refreshLocations()
                
                refreshDestinations()
                
                caseTable.toggleLoadingView(present: true, color: HexColor(productSV.selectedProduct!.color))
                refreshData()
            }
            else {
                submenu.productSelect.setTitle("No Products", for: .normal)
                submenu.locationSelect.setTitle("No Locations", for: .normal)
                submenu.destinationSelect.setTitle("No Destinations", for: .normal)
            }
            
        // event for when a selectionView selection has changed
        case .selectionChanged(let type):
            tuckAwaySelectionViews()
            switch type {
            case .products:
                caseTable.toggleLoadingView(present: true, color: HexColor(productSV.selectedProduct!.color))
                
                refreshProductSelect()
                
                refreshLocations()
                
                refreshDestinations()
                
                refreshData()
                
            case .locations:
                caseTable.toggleLoadingView(present: true, color: HexColor(productSV.selectedProduct!.color))
                
                submenu.locationSelect.backgroundColor = HexColor(locationSV.selectedLocation!.color)
                submenu.locationSelect.setTitle(locationSV.selectedLocation!.name, for: .normal)
                
                refreshData()
                
            case .destinations:
                submenu.destinationSelect.backgroundColor = HexColor(destinationSV.selectedDestination!.color)
                submenu.destinationSelect.setTitle(destinationSV.selectedDestination!.name, for: .normal)
            }
            
        // event for when the toolbar selection has changed
        case .toolbarSelection(let buttonTag):
            
            caseTable.selectedCases = []
            if !(caseTable.indexPathsForSelectedRows?.isEmpty ?? true) {
                for indexPath in caseTable.indexPathsForSelectedRows! {
                    caseTable.deselectRow(at: indexPath, animated: true)
                }
                print(caseTable.selectedCases)
            }
            // new cases option was selected
            if buttonTag == 0 {
                submenu.toggleSubmenu(option: .newCases)
                submenu.isHidden = false
                caseTable.allowsMultipleSelection = false
                caseTable.allowsSelection = false
            }
            // select cases option was selected
            else if buttonTag == 1 {
                submenu.isHidden = true
                caseTable.allowsMultipleSelection = false
                submenu.ptfOne!.resignFirstResponder()
                submenu.ptfTwo!.resignFirstResponder()
                tuckAwaySelectionViews()
            }
            // stock cases option was selected
            else if buttonTag == 2 {
                submenu.toggleSubmenu(option: .stockCases)
                submenu.isHidden = false
                caseTable.allowsSelection = true
                caseTable.allowsMultipleSelection = true
                submenu.ptfOne!.resignFirstResponder()
                submenu.ptfTwo!.resignFirstResponder()
            }
            
        // event for when the submenu's done button has been selected
        case .doneButtonSelected(let option):
            if option == .newCases {
                addNewCases()
            }
            else {
                stockCases()
            }
            
        // event for when product select, location select, or destination select have been selected
        case .submenuSelection(let buttonTag):
            toggleSelectionView(tag: buttonTag)

        // event for when the user would like to undo stocked or added cases
        case .undo:
            caseTable.toggleLoadingView(present: true, color: HexColor(productSV.selectedProduct!.color))
            manager.undo { [self] in
                caseTable.redoButton.toggle(on: true)
                if manager.undoQueue.isEmpty {
                    caseTable.undoButton.toggle(on: false)
                }
                refreshData()
            }
            
        // event for when the user would like to redo stocked or added cases
        case .redo:
            caseTable.toggleLoadingView(present: true, color: HexColor(productSV.selectedProduct!.color))
            manager.redo {
                if manager.redoQueue.isEmpty {
                    caseTable.redoButton.toggle(on: false)
                }
                refreshData()
            }
            
        // event for when the user would like to sort cases
        case .sortCases(let parameter):
            caseTable.toggleLoadingView(present: true, color: HexColor(productSV.selectedProduct!.color))
            manager.queryFirestore(parameters: (productName: productSV.selectedProduct!.name, locationName: locationSV.selectedLocation!.name), sort: parameter) { [self] cases in
                caseTable.reloadCaseTable(cases: cases, location: locationSV.selectedLocation!.name, currentCount: manager.currentCount, limit: manager.limit)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    caseTable.toggleLoadingView(present: false, color: nil)
                }
            }
            
        default:
            print("notified")
        }
    }
}

// This extension is for the purpose of controlling the isScrollEnabled property of both the CaseTable and the scrollView in which it is contained
// It's important that the CaseTable is within a scrollView because this allows us to prevent scrolling past the header (with the code below)
extension CasesViewController: UIScrollViewDelegate {
    
    
    // This func enables/disables scroll depending on the scrollView and contentOffset.y of that scrollView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        
        if scrollView == caseTable {
            if yOffset <= 0 {
                caseTable.isScrollEnabled = false
                self.scrollView.isScrollEnabled = true
            }
            else {
                caseTable.isScrollEnabled = true
                self.scrollView.isScrollEnabled = false
            }
        }
    }
    
    // This func disables the scrollView because scrolling would extend past the bottom of the CaseTable
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            scrollView.isScrollEnabled = false
        }
    }
}


