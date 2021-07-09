//
//  ExpiredCasesViewController.swift
//  Stocked.
//
//  Created by David Jabech on 4/20/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import Network
import Lottie

class ExpiredCasesViewController: UIViewController {
    
    private let vc1 = NewCasesViewController()
    private let products = ["Filet", "Spicy", "Nugget", "Strip", "Grilled Filet", "Grilled Nugget", "Breakfast Filet"]
    private let loadingView = LoadingView.init()
    private let animationView = AnimationView()
    private let noWiFi = AnimationView()
    private let notConnectedView = UIView()
    private let notConnectedLabel = UILabel()
    private let productView = ProductCollectionView.init(frame: CGRect(x: 0,
               y: -360,
               width: UIScreen.main.bounds.size.width,
               height: 360
               ))
    private var db = Firestore.firestore()
    private var expiredCases = [Case]()
    private var selectedExpiredCases = [Case]()
    
    private var expiredCasesTable: UITableView = {
        let table = UITableView()
        table.register(ExpiredCaseCell.self, forCellReuseIdentifier: ExpiredCaseCell.identifier)
        return table
    }()
    
    @IBOutlet var expiredCasesView: UIView!
    @IBOutlet var productSelectView: UIView!
    
    @IBAction func archiveButton(_ sender: Any) {
        if selectedExpiredCases.count != 0 {
            archiveSelectedCases() { [self] () -> () in
                reloadExpiredCasesTable()
            }
        }
    
        else {
            let noCasesSelectedAlert = UIAlertController(title: "No case selected.", message: "Please select cases to archive.", preferredStyle: .alert)
            noCasesSelectedAlert.addAction(UIAlertAction(title: "Please select cases to archive.", style: .default, handler: nil))
            present(noCasesSelectedAlert, animated: true)
        }
    }
    @IBAction func changeProductsButton(_ sender: UIBarButtonItem) {
        toggleProductView()
    }
    
    private func findExpiredCases(completion: @escaping () -> Void) {
        
        expiredCases = []
        
        let offsetDate = Calendar.current.date(byAdding: .day, value: -4, to: Date())
        
        db.collection("testData")
            .whereField("product", isEqualTo: selectedProduct)
            .whereField("shelfLife", isLessThanOrEqualTo: offsetDate!)
            .whereField("userID", isEqualTo: userIDkey)
            .getDocuments() { [self] (querySnapshot, err) in
                if let err = err {
                    print("error in findExpiredCases query: \(err)")
                }
                else {
                    guard let documents = querySnapshot?.documents else {
                        print("no documents found")
                        return
                    }
                    expiredCases = documents.compactMap { queryDocumentSnapshot -> Case? in
                        return try? queryDocumentSnapshot.data(as: Case.self)
                    }
                    completion()
                }
            }
    }
    
    @objc private func reloadExpiredCasesTable() {
        expiredCasesTable.addSubview(loadingView)
        expiredCasesTable.bringSubviewToFront(loadingView)
        StockCasesViewController().setTableColor(product: selectedProduct, table: expiredCasesTable)
        loadingView.loadingAnimation.backgroundColor = expiredCasesTable.backgroundColor?.withAlphaComponent(1)
        loadingView.loadingAnimation.play()
        animationView.play()
        
        selectedExpiredCases = []
        findExpiredCases { [self] () -> () in
            expiredCasesTable.reloadData()
            if expiredCases.count == 0 {
                let noCasesLabel = UILabel()
                noCasesLabel.text = "No Cases Found."
                noCasesLabel.font = UIFont(name: "Avenir", size: 20)
                noCasesLabel.textAlignment = .center
                expiredCasesTable.backgroundView = noCasesLabel
            }
            else {
                expiredCasesTable.backgroundView = nil
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                loadingView.removeFromSuperview()
            }
        }
    }
    
    private func buildExpiredCasesTable() {
        expiredCasesView.addSubview(expiredCasesTable)
        expiredCasesTable.allowsMultipleSelection = true
        expiredCasesTable.separatorColor = .clear
        expiredCasesTable.backgroundColor = .clear
        
        expiredCasesTable.delegate = self
        expiredCasesTable.dataSource = self
    }
    
    func archiveSelectedCases(completion: @escaping () -> Void) {
        for selectedCase in selectedExpiredCases {
            db.collection("cases")
                .whereField("product", isEqualTo: selectedProduct)
                .whereField("caseNumber", isEqualTo: selectedCase.caseNumber)
                .whereField("userID", isEqualTo: userIDkey)
                .getDocuments() { [self] (querySnapshot, err) in
                    if let err = err {
                        print("error in archive selected cases:\(err)")
                    }
                    else {
                        if querySnapshot!.documents.count > 1 {
                            let errorAlert = UIAlertController(title: "Error", message: "More than one case with this number exists", preferredStyle: .alert)
                            errorAlert.addAction(UIAlertAction(title: "Heard on that.", style: .default, handler: nil))
                            present(errorAlert, animated: true)
                        }
                        else{
                            for document in querySnapshot!.documents {
                                document.reference.delete()
                            }
                        }
                    }
                    completion()
                }
        }
    }
    
    func setUpNotConnectedView() {
        view.addSubview(notConnectedView)
        view.bringSubviewToFront(notConnectedView)
        notConnectedView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width-200, height: view.frame.size.height-900)
        notConnectedView.backgroundColor = .white
        notConnectedView.layer.masksToBounds = true
        notConnectedView.layer.cornerRadius = 10
        notConnectedView.addSubview(notConnectedLabel)
        notConnectedLabel.text = "Please connect to the internet to archive cases."
        notConnectedLabel.font = UIFont(name: "Avenir", size: 18)
        notConnectedLabel.frame = CGRect(x: 0, y: 0, width: 500, height: 100)
        notConnectedLabel.center = notConnectedView.center
        notConnectedLabel.textAlignment = .center
        notConnectedView.center = view.center
        notConnectedView.isHidden = true
        notConnectedView.addSubview(noWiFi)
        notConnectedView.bringSubviewToFront(noWiFi)
        
        noWiFi.animation = Animation.named("noWiFi")
        noWiFi.frame = CGRect(x: 190, y: 20, width: 40, height: 40)
        noWiFi.contentMode = .scaleAspectFill
        noWiFi.loopMode = .playOnce
    }
    
    func toggleProductView() {
        if productView.frame.origin.y == 0 {
            UIView.animate(withDuration: 0.3) {
                self.productView.frame.origin.y = -360
            }
        }
        else {
            UIView.animate(withDuration: 0.3) {
                self.productView.frame.origin.y = 0
            }
        }
    }
    
    func hideProductView() {
        UIView.animate(withDuration: 0.3) {
            self.productView.frame.origin.y = -360
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadExpiredCasesTable), name: NSNotification.Name(changeProductKey), object: nil)
        
        setUpNotConnectedView()
        
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [self] path in
            if path.status == .satisfied {
                print("we're connected :)")
                view.isUserInteractionEnabled = true
                notConnectedView.isHidden = true
            }
            else {
                print("we're not connected :(")
                view.isUserInteractionEnabled = false
                notConnectedView.isHidden = false
                noWiFi.play()
            }
        }
        
        monitor.start(queue: DispatchQueue.main)
        
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        selectedProduct = "Filet"
        view.addSubview(productView)
        buildExpiredCasesTable()
        reloadExpiredCasesTable()
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        expiredCasesTable.frame = expiredCasesView.bounds

        loadingView.frame = CGRect(x: 0,
                                   y: 0,
                                   width: expiredCasesTable.frame.size.width,
                                   height: expiredCasesTable.frame.size.height)
        loadingView.loadingAnimation.frame = loadingView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
        NotificationCenter.default.post(name: Notification.Name(rawValue: vckey), object: nil)
        }
    }
}

extension ExpiredCasesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Expired Cases: \(selectedProduct)"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedExpiredCases.append(expiredCases[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedExpiredCases.removeAll(where: { $0 == expiredCases[indexPath.row]})
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expiredCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExpiredCaseCell.identifier, for: indexPath) as? ExpiredCaseCell else {
            return UITableViewCell()
        }
        cell.clipsToBounds = true
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = UIColor(red: 199, green: 199, blue: 204, alpha: 1).cgColor
        cell.layer.borderWidth = 1
        cell.caseNumberLabel.text = String(expiredCases[indexPath.row].caseNumber)
        cell.productLabel.text = expiredCases[indexPath.row].product
        cell.locationLabel.text = expiredCases[indexPath.row].location
        let ptc = ProductTableCell()
        ptc.setCellColor(product: selectedProduct, cell: cell, indexPath: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension ExpiredCasesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if productView.frame.origin.y == 0 {
            hideProductView()
        }
    }
}

