//
//  SubscriptionViewController.swift
//  Stocked.
//
//  Created by David Jabech on 5/3/21.
//

import UIKit
import StoreKit

var models = [SKProduct]()

class SubscriptionViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    @IBOutlet var subscriptionTable: UITableView!
    
    
    enum ProductList: String, CaseIterable {
        case MonthlyBaseSubscription = "ink.sagacity.Stocked.monthlyBaseSubscription"
        case YearlyBaseSubscription = "ink.sagacity.Stocked.yearlyBaseSubscription"
    }
    
    private func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(ProductList.allCases.compactMap({ $0.rawValue })))
        request.delegate = self
        request.start()
        print(request)
    }
    
    public func purchaseBaseMonthSub(completion: @escaping () -> Void) {
        let Payment = SKPayment(product: models[0])
        SKPaymentQueue.default().add(Payment)
    }
    
    public func purchaseBaseYearlySub(completion: @escaping () -> Void) {
        let Payment = SKPayment(product: models[1])
        SKPaymentQueue.default().add(Payment)
    }
    
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        models = response.products
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // not necessary function
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)
        subscriptionTable.delegate = self
        subscriptionTable.dataSource = self
        fetchProducts()
        print(models)
    }
    
}

extension SubscriptionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0 :
            guard let currentSubCell = tableView.dequeueReusableCell(withIdentifier: CurrentSubCell.identifier, for: indexPath) as? CurrentSubCell else {
                return UITableViewCell()
            }
            currentSubCell.subscriptionLabel.frame = CGRect(x: currentSubCell.contentView.frame.size.width-220,
                                                            y: currentSubCell.contentView.center.y-15,
                                                            width: 300,
                                                            height: 30 )
            if UserDefaults.standard.bool(forKey: "BaseSubscription") {
                currentSubCell.subscriptionLabel.text = "Base Subscription - Monthly"
            }
            else if UserDefaults.standard.bool(forKey: "YearlySubscription") {
                currentSubCell.subscriptionLabel.text = "None"
            }
            return currentSubCell
        case 1:
            guard let renewCell = tableView.dequeueReusableCell(withIdentifier: DateRenewCell.identifier, for: indexPath) as? DateRenewCell else {
                return UITableViewCell()
            }
            renewCell.renewalDateLabel.frame = CGRect(x: renewCell.contentView.frame.size.width-25,
                                                            y: renewCell.contentView.center.y-15,
                                                            width: 50,
                                                            height: 30 )
                if UserDefaults.standard.string(forKey: "PurchaseDate") != nil {
                    renewCell.renewalDateLabel.text = UserDefaults.standard.string(forKey: "PurchaseDate")
                }
                else {
                    renewCell.renewalDateLabel.text = "---"
                }
            return renewCell
        case 2:
            guard let subCell = tableView.dequeueReusableCell(withIdentifier: SubscribeCell.identifier, for: indexPath) as? SubscribeCell else {
                return UITableViewCell()
            }
            return subCell
        case 3:
            guard let restoreCell = tableView.dequeueReusableCell(withIdentifier: RestorePurchaseCell.identifier, for: indexPath) as? RestorePurchaseCell else {
                return UITableViewCell()
            }
            return restoreCell
        default:
            return UITableViewCell()
        }
    }
}


class CurrentSubCell: UITableViewCell {
    static let identifier = "currentSubCell"
    @IBOutlet var subscriptionLabel: UILabel!
    
}

class DateRenewCell: UITableViewCell {
    static let identifier = "dateRenewCell"
    @IBOutlet var renewalDateLabel: UILabel!
    
}

class SubscribeCell: UITableViewCell {
    static let identifier = "subscribeCell"
    @IBAction func subscribeButton(_ sender: UIButton) {
        if !UserDefaults.standard.bool(forKey: "BaseSubscription") {
        SubscriptionViewController().purchaseBaseMonthSub { () -> () in
            UserDefaults.standard.setValue(true, forKey: "BaseSubscription")
            let renewDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            UserDefaults.standard.setValue(formatter.string(from: renewDate!), forKey: "PurchaseDate")
            }
        }
        else {
            let alreadyPurchased = UIAlertController(title: "You have already purchased this subscription.",
                                                     message: nil,
                                                     preferredStyle: .alert)
            alreadyPurchased.addAction(UIAlertAction(title: "Heard on that.",
                                                     style: .default,
                                                     handler: nil))
            UIApplication.shared.keyWindow!.rootViewController?.present(alreadyPurchased, animated: true)
        }
    }
}

class RestorePurchaseCell: UITableViewCell {
    static let identifier = "restorePurchaseCell"
    @IBAction func restorePurchaseButton(_ sender: UIButton) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
