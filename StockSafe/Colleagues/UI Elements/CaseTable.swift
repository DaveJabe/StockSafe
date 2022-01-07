//
//  CasesTable.swift
//  StockSafe
//
//  Created by David Jabech on 7/10/21.
//

import UIKit

/* This subclass of UITableView is used for displaying cases to the user along with most features crucial to adding or stocking cases: scrolling, selecting, shows
   capacity, has buttons for undoing, sorting, and deleting cases,and it tells the user what location they're looking in. CaseTable inherits ColleagueProtocol so that
   it can let the mediator know how many or which cases have been selected, as well as whether the user has selected to undo, sort, or delete cases. */

class CaseTable: UITableView, ColleagueProtocol {
    
    // variable for mediator (in this case, CasesViewController)
    public weak var mediator: MediatorProtocol?
    
    // Dictionary with Cases as keys and Strings (expiration Dates) as values
    public var cases: [(Case, String)] = []
    
    // The current color (to be used for table view cells)
    public var currentColor: HexColor?
    
    // Array of selected cases
    public var selectedCases = [Case]()
    
    // Loading view for when table is reloading its rows (cases)
    private let loadingView = LoadingView.init()
    
    // This is the background view for the header (this way we can add subviews to it and provide the appearance of subviews underneath the actual header view)
    private let headerView = UIView()
    
    // Header view for CaseTable
    private let header = UIView()
    
    // Header label for case limit
    private var limitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = boldFont(size: 25)
        label.textColor = .systemGray6
        return label
    }()
    
    // Header label: 'Select Cases'
    private var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font =  boldFont(size: 25)
        label.textColor = .systemGray6
        return label
    }()
    
    // Toolbar (stackView) for tableViewHeader for access to undo, sort and delete buttons)
    private var tableToolBar: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorThemes.foregroundColor2
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    public var undoButton: UIButton = {
        let button = UIButton()
        button.makeSFButton(symbolName: "arrow.uturn.left", tintColor: .systemGray6, configuration: Constants.SymbolConfigs.largeSymbolConfig)
        return button
    }()
    public var sortButton: UIButton = {
        let button = UIButton()
        button.makeSFButton(symbolName: "lineweight", tintColor: .systemGray6, configuration: Constants.SymbolConfigs.largeSymbolConfig)
        return button
    }()
    
    public var searchButton: UIButton = {
        let button = UIButton()
        button.makeSFButton(symbolName: "magnifyingglass", tintColor: .systemGray6, configuration: Constants.SymbolConfigs.largeSymbolConfig)
        return button
    }()
        
    public var redoButton: UIButton = {
        let button = UIButton()
        button.makeSFButton(symbolName: "arrow.uturn.right", tintColor: .systemGray6, configuration: Constants.SymbolConfigs.largeSymbolConfig)
        return button
    }()
    
    // Label to display when no cases are found
    public var noCasesLabel: UILabel = {
        let label = UILabel()
        label.text = "No Cases Found"
        label.font = standardFont(size: 20)
        label.textAlignment = .center
        return label
    }()
    
    // Func to set mediator, which in this case we're also using to set some essential properties like delegate (kind of like you would in an initializer)
    public func setMediator(mediator: MediatorProtocol) {
        self.mediator = mediator
        
        delegate = self
        dataSource = self
        allowsSelection = false
        
        undoButton.addTarget(self, action: #selector(notifyToUndo(_:)), for: .touchUpInside)
        undoButton.toggle(on: false)
        redoButton.addTarget(self, action: #selector(notifyToRedo(_:)), for: .touchUpInside)
        redoButton.toggle(on: false)
        sortButton.addTarget(self, action: #selector(notifyToSort(_:)), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
        
        addSubview(loadingView)
        bringSubviewToFront(loadingView)
        loadingView.frame = CGRect(x: 0,
                                   y: 0,
                                   width: frame.size.width,
                                   height: frame.size.height)
        loadingView.loadingAnimation.frame = loadingView.bounds
        loadingView.layer.masksToBounds = true
        loadingView.layer.cornerRadius = 10
        
        noCasesLabel.frame = bounds
        
        buildHeader()
        
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.darkGray.cgColor
    }
    
    // Func used to reload the caseTable (called in refreshData() in CasesViewController)
    public func reloadCaseTable(cases: [(Case, String)], location: String, currentCount: Int, limit: Int) {
        // Resets selectedCases to be empty
        selectedCases = []
        // Sets new cases (received from CaseManager via the CasesViewController)
        self.cases = cases
        // Toggles the sortButton & searchButton depending on whether cases is empty
        if cases.count != 0 {
            sortButton.toggle(on: true)
            searchButton.toggle(on: true)
        }
        else {
            sortButton.toggle(on: false)
            searchButton.toggle(on: false)
        }
        // Setting the header label to the currently selected location
        headerLabel.text = "Cases in \(location)"
        // Reloads table data
        reloadData()
        // If-else statement to provide a backgroundView when there are no cases to display
        if cases.count > 0 {
            backgroundView = nil
        }
        else {
            backgroundView = noCasesLabel
        }
        if UserDefaults.standard.bool(forKey: "SetLimitsKey") {
            setLimitLabelText(currentCount: currentCount, limit: limit)
        }
        else {
            limitLabel.text = ""
        }
    }
    
    // Sets the text for the limit label based on the currentCount of cases and the limit for their location (both provided by CaseManager via CasesViewController)
    private func setLimitLabelText(currentCount: Int, limit: Int) {
        // Realistically, the currentCount should NEVER exceed the limit, but here we use >= just in case
        if currentCount >= limit {
            limitLabel.textColor = .red
        }
        else {
            limitLabel.textColor = .darkGray
        }
        limitLabel.text = "\(currentCount)/\(limit)"
    }
    
    // Func called in CasesViewController when the caseTable is going to/is reloading data
    public func toggleLoadingView(present: Bool, color: HexColor?) {
        if present {
            isScrollEnabled = false
            loadingView.loadingAnimation.backgroundColor = color!.withAlphaComponent(0.5)
            if contentOffset.y > 0 {
                loadingView.frame.origin.y += contentOffset.y
            }
            loadingView.isHidden = false
            loadingView.loadingAnimation.play()
        }
        else {
            loadingView.isHidden = true
            isScrollEnabled = true
        }
    }
    
    // Func to build the header for CaseTable
    public func buildHeader() {
        header.backgroundColor = ColorThemes.foregroundColor1
        header.addSubview(limitLabel)
        header.addSubview(headerLabel)
        header.addSubview(tableToolBar)
        headerView.addSubview(header)

        sortButton.tag = 1
        sortButton.setTitle("Case Number", for: .normal)
        sortButton.titleLabel?.font = boldFont(size: 10)
        
        tableToolBar.addArrangedSubview(undoButton)
        tableToolBar.addArrangedSubview(sortButton)
        tableToolBar.addArrangedSubview(searchButton)
        tableToolBar.addArrangedSubview(redoButton)
        
        header.frame = headerView.bounds
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: header.layoutMarginsGuide.leadingAnchor),
            headerLabel.widthAnchor.constraint(equalToConstant: 250),
            headerLabel.heightAnchor.constraint(equalToConstant: 50),
            headerLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            
            tableToolBar.widthAnchor.constraint(equalToConstant: 450),
            tableToolBar.heightAnchor.constraint(equalToConstant: 30),
            tableToolBar.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            tableToolBar.centerYAnchor.constraint(equalTo: header.centerYAnchor, constant: 35),
        ])
        
        header.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        header.layer.cornerRadius = 10
        header.addShadow()
        tableToolBar.addSubtlerShadow()
    }
    
    @objc private func notifyToUndo(_ sender: UIButton) {
        mediator?.notify(sender: self, event: .undo)
    }
    
    @objc private func notifyToRedo(_ sender: UIButton) {
        mediator?.notify(sender: self, event: .redo)
    }
    
    @objc private func notifyToSort(_ sender: UIButton) {
        print(sender.tag)
        switch sender.tag {
        case 0:
            sender.setTitle("Case Number", for: .normal)
            mediator?.notify(sender: self, event: .sortCases(parameter: .byNumber))
            sender.tag = 1
        case 1:
            sender.titleLabel?.text = "Expiry Date"
            mediator?.notify(sender: self, event: .sortCases(parameter: .byExpiryDate))
            sender.tag = 2
        case 2:
            sender.setTitle("Date Added", for: .normal)
            mediator?.notify(sender: self, event: .sortCases(parameter: .byDateAdded))
            sender.tag = 0
        default:
            print("Error in notifyToSort: tag with value other than 0, 1, or 2")
        }
    }
    
    @objc private func notifyToDelete(_ sender: UIButton) {
        mediator?.notify(sender: self, event: .deleteCases)
    }
}

// UITableViewDelegate and UITableViewDataSource functions
extension CaseTable: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let tableFooter = UIView(frame: bounds)
        tableFooter.layer.masksToBounds = true
        tableFooter.layer.cornerRadius = 10
        return tableFooter
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let caseCell = tableView.dequeueReusableCell(withIdentifier: CaseCell.identifier, for: indexPath) as? CaseCell else {
            return UITableViewCell()
        }
        
        let caseAtIndexPath = cases[indexPath.row]
        
        caseCell.backgroundColor = .systemGray6
        caseCell.numberLabel.backgroundColor = currentColor
        
        if caseAtIndexPath.1 == "Expired" {
            caseCell.shelfLifeLabel.textColor = .systemRed
        }
        else {
            caseCell.shelfLifeLabel.textColor = .darkText
        }
        
        caseCell.numberLabel.text = String(caseAtIndexPath.0.caseNumber)
        caseCell.productLabel.text = caseAtIndexPath.0.product
        caseCell.shelfLifeLabel.text = caseAtIndexPath.1
        
        return caseCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCases.append(cases[indexPath.row].0)
        print("Row was selected - Selected Cases: \(selectedCases.count) cases")
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedCases.removeAll(where: { $0.caseNumber == cases[indexPath.row].0.caseNumber } )
        print("Row was deselected - Selected Cases: \(selectedCases.count) cases")
    }
}
