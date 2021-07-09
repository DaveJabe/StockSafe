//
//  ProductDashboardViewController.swift
//  StockSafe
//
//  Created by David Jabech on 7/7/21.
//

import UIKit
import FirebaseFirestore

class ProductDashboardViewController: UIViewController {
    
    private var db: Firestore!
    private var products = [Product]()
    
    private var goToAddProductButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "plus.app.fill")
        return button
    }()
    
    @IBOutlet var productCollection: UICollectionView!
    
    @objc private func goToAddProduct(_ sender: Any) {
        let apvc = self.storyboard?.instantiateViewController(withIdentifier: "addProductVC") as? AddProductViewController
        apvc!.modalPresentationStyle = .pageSheet
        self.present(apvc!, animated: true)
    }
    
    private func configureProducts(completion: @ escaping ()->Void) {
        products = []
        db.collection("products")
            .whereField("userID", isEqualTo: userIDkey)
            .getDocuments() { [self] querySnapshot, err in
                if err != nil {
                    print("Error in configureProducts: \(String(describing: err))")
                }
                else {
                    guard let documents = querySnapshot?.documents else {
                        print("No documents found...")
                        return
                    }
                    let group = DispatchGroup()
                    for document in documents {
                        group.enter()
                        let product = try? document.data(as: Product.self)
                        products.append(product!)
                        group.leave()
                    }
                    group.notify(queue: DispatchQueue.main) {
                        completion()
                    }
                }
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        if let layout = productCollection.collectionViewLayout as? CollectionViewLeadingFlowLayout {
            layout.delegate = self
        }
        goToAddProductButton.target = self
        goToAddProductButton.action = #selector(goToAddProduct(_:))
        navigationItem.rightBarButtonItem = goToAddProductButton
        
        productCollection.delegate = self
        productCollection.dataSource = self
        productCollection.register(ProductDashboardCell.self, forCellWithReuseIdentifier: ProductDashboardCell.identifier)
        productCollection.register(ProductLocationCollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProductLocationCollectionHeader.identifier)
        
        configureProducts { [self] in
            productCollection.reloadData()
            print(productCollection.numberOfItems(inSection: 0))
        }
    }
}

extension ProductDashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProductLocationCollectionHeader.identifier, for: indexPath) as? ProductLocationCollectionHeader else {
            return UICollectionReusableView()
        }
        header.title.text = "Select A Product"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductDashboardCell.identifier, for: indexPath) as? ProductDashboardCell else {
            return UICollectionViewCell()
        }
            cell.productTextView.frame = cell.contentView.bounds
            cell.productTextView.text = products[indexPath.item].name
            cell.productTextView.centerVerticalText()
            cell.backgroundColor = HexColor(products[indexPath.item].color)
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if indexPath.item != products.count {
            let infovc = storyboard?.instantiateViewController(withIdentifier: "productInfo") as? ProductInfoViewController
            infovc!.modalPresentationStyle = .overCurrentContext
            
            for location in products[indexPath.row].locations {
                infovc!.productInfo["Locations"]! += "\(location) "
            }
            self.present(infovc!, animated: true, completion: nil)
        }
    }
}

extension ProductDashboardViewController: CollectionViewLeadingFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
        return (UIScreen.main.bounds.size.width - 40) / 5
    }
}

