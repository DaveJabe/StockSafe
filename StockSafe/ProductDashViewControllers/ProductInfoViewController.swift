//
//  ProductInfoViewController.swift
//  StockSafe
//
//  Created by David Jabech on 7/7/21.
//

import UIKit

class ProductInfoViewController: UIViewController {
    
    public var productInfo: [String:String] = [:]
    
    @IBOutlet weak var productInfoTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        productInfoTable.delegate = self
        productInfoTable.dataSource = self 
    }

}

extension ProductInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "productInfoCell", for: indexPath) as? ProductInfoCell else {
            return UITableViewCell()
        }
        
        return cell
    }
}
