//
//  CasesTable.swift
//  StockSafe
//
//  Created by David Jabech on 7/10/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class CaseTable: UITableView, ColleagueProtocol {
    
    public weak var mediator: MediatorProtocol?
    
    // Dictionary with Cases as keys and Strings (expiration Dates) as values
    public var cases: [Case:String] = [:]
    
    // Array of sorted Cases (from `cases` dictionary)
    public var sortedCases: [Case] = []
    
    // Loading view for when table is reloading its rows (cases)
    private let loadingView = LoadingView.init()
    
    // Header view for CaseTable
    private let header = UIView()
    
    // Header label for case limit
    private var limitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = VD.boldFont(size: 20)
        label.textColor = .darkGray
        return label
    }()
    
    // Header label: 'Select Cases'
    private var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font =  VD.boldFont(size: 20)
        label.textColor = .darkGray
        return label
    }()
    
    // Label to display when no cases are found
    private var noCasesLabel: UILabel = {
        let label = UILabel()
        label.text = "No Cases Found"
        label.font = VD.standardFont(size: 20)
        label.textAlignment = .center
        return label
    }()
    
    public func setMediator(mediator: MediatorProtocol) {
        self.mediator = mediator
        noCasesLabel.frame = bounds
        
        buildHeader()
        
        delegate = self
        dataSource = self
        allowsSelection = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(loadingView)
        bringSubviewToFront(loadingView)
        loadingView.frame = CGRect(x: 0,
                                   y: 0,
                                   width: frame.size.width,
                                   height: frame.size.height)
        loadingView.loadingAnimation.frame = loadingView.bounds
        loadingView.layer.masksToBounds = true
        loadingView.layer.cornerRadius = 10
    }
        
    public func reloadCaseTable(cases: [Case:String], sortedCases: [Case], currentCount: Int, limit: Int) {
        self.cases = cases
        self.sortedCases = sortedCases
        reloadData()
        if cases.count > 0 {
            backgroundView = nil
            headerLabel.text = "Cases in \(sortedCases[0].location)"
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
    
    private func buildHeader() {
        header.backgroundColor = .white
        header.addSubview(limitLabel)
        header.addSubview(headerLabel)
        if UserDefaults.standard.bool(forKey: "SetLimitsKey") {
            NSLayoutConstraint.activate([
                headerLabel.leadingAnchor.constraint(equalTo: header.layoutMarginsGuide.leadingAnchor),
                headerLabel.widthAnchor.constraint(equalToConstant: 150),
                headerLabel.heightAnchor.constraint(equalToConstant: 50),
                headerLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
                
                limitLabel.heightAnchor.constraint(equalToConstant: 30),
                limitLabel.trailingAnchor.constraint(equalTo: header.layoutMarginsGuide.trailingAnchor),
                limitLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor)])
        }
        else {
            NSLayoutConstraint.activate([
                headerLabel.leadingAnchor.constraint(equalTo: header.layoutMarginsGuide.leadingAnchor),
                headerLabel.widthAnchor.constraint(equalToConstant: 250),
                headerLabel.heightAnchor.constraint(equalToConstant: 50),
                headerLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor)
            ])
        }
        header.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        header.layer.cornerRadius = 10
        VD.addShadow(view: header)
    }

    private func setLimitLabelText(currentCount: Int, limit: Int) {
        if currentCount >= limit {
            limitLabel.textColor = .red
        }
        else {
            limitLabel.textColor = .darkGray
        }
        limitLabel.text = "Capacity: \(currentCount)/\(limit)"
    }
}

// UITableViewDelegate and UITableViewDataSource functions
extension CaseTable: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let tableFooter = UIView(frame: bounds)
        tableFooter.layer.masksToBounds = true
        tableFooter.layer.cornerRadius = 10
        return tableFooter
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let caseCell = tableView.dequeueReusableCell(withIdentifier: CaseCell.identifier, for: indexPath) as? CaseCell else {
            return UITableViewCell()
        }
        
        let caseAtIndexPath = sortedCases[indexPath.row]
        
        caseCell.backgroundColor = backgroundColor?.withAlphaComponent(0.5)
        caseCell.numberLabel.backgroundColor = caseCell.backgroundColor?.withAlphaComponent(1)
        
        if cases[caseAtIndexPath] == "Expired" {
            caseCell.shelfLifeLabel.textColor = .systemRed
        }
        else {
            caseCell.shelfLifeLabel.textColor = .darkText
        }
        
        caseCell.numberLabel.text = String(caseAtIndexPath.caseNumber)
        caseCell.productLabel.text = caseAtIndexPath.product
        caseCell.shelfLifeLabel.text = cases[caseAtIndexPath]
       
        return caseCell
    }
}
