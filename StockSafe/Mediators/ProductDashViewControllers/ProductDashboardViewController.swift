//
//  ProductDashboardViewController.swift
//  StockSafe
//
//  Created by David Jabech on 7/7/21.
//

import UIKit
import FirebaseFirestore

class ProductDashboardViewController: UIViewController {

    private var manager = ProductManager()
    
    private var goToAddProductButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "plus.app.fill")
        button.tintColor = .systemGreen
        button.action = #selector(goToAddProduct(from:))
        return button
    }()
    
    @IBOutlet weak var productCollection: UICollectionView!
    
    @objc private func goToAddProduct(from sender: Any) {
        let apvc = self.storyboard?.instantiateViewController(withIdentifier: "addProductVC") as? AddProductViewController
        apvc!.modalPresentationStyle = .pageSheet
        self.present(apvc!, animated: true)
    }

    
    private func configureProductCollection() {
        productCollection.delegate = self
        productCollection.dataSource = self
        productCollection.register(SelectionCell.self, forCellWithReuseIdentifier: SelectionCell.identifier)
        productCollection.register(SelectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SelectionHeader.identifier)
        VD.addShadow(view: productCollection)
        VD.setCustomCollectionLayout(collectionView: productCollection)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        goToAddProductButton.target = self
        navigationItem.rightBarButtonItem = goToAddProductButton
        
        manager.setMediator(mediator: self)
        manager.configureProducts()
        configureProductCollection()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let hvc = parent?.children.first(where: { $0.restorationIdentifier == "homeScreen" })
        hvc?.viewDidLoad()
    }
}

extension ProductDashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SelectionHeader.identifier, for: indexPath) as? SelectionHeader else {
            return UICollectionReusableView()
        }
        header.backgroundColor = .clear
        header.title.textAlignment = .left
        header.title.text = "    Select A Product"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return manager.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectionCell.identifier, for: indexPath) as? SelectionCell else {
            return UICollectionViewCell()
        }
        cell.itemTitle.text = manager.products[indexPath.row].name
        cell.itemTitle.configureForCell(frame: cell.bounds)
        cell.frame.size.width = cell.itemTitle.frame.size.width
        cell.backgroundColor = HexColor(manager.products[indexPath.row].color)
        cell.contentView.layer.borderWidth = 0
        VD.addShadow(view: cell)
        VD.addSubtleShadow(view: cell.itemTitle)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        // This will later present ProductInfoViewController and pass to it the data regarding the product selected

    }
}

extension ProductDashboardViewController: MediatorProtocol {
    func notify(sender: ColleagueProtocol, event: Event) {
        switch event {
        case .configuredProducts:
            productCollection.reloadData()
        default:
            print("Error in func notify in ProductDashboardViewController")
        }
    }
    
    func relayInfo(sender: ColleagueProtocol, info: Any) {
        // Not sure if needed yet
    }
}


