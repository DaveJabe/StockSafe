//
//  ProductDashboardViewController.swift
//  StockSafe
//
//  Created by David Jabech on 7/7/21.
//

import UIKit
import FirebaseFirestore

class ProductsViewController: UIViewController {

    private let toolbar = ToolbarView.init(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: UIScreen.main.bounds.width,
                                                         height: UIScreen.main.bounds.height/10),
                                           type: .productOrLocationToolbar)
    
    public var manager = ProductManager()
    
    public var productCollection: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.addSubview(toolbar)
        
        configureProductCollection()
        view.addSubview(productCollection!)
        
        toolbar.setMediator(mediator: self)
        manager.setMediator(mediator: self)
        
        manager.configureProducts()
    }
    
    private func goToAddProduct() {
        let sb = UIStoryboard(name: "Main" , bundle: nil)
        let apvc = sb.instantiateViewController(withIdentifier: "AddProductVC") as? AddProductViewController
        apvc!.modalPresentationStyle = .pageSheet
        self.present(apvc!, animated: true)
    }
    
    private func configureProductCollection() {
        let collectionViewY = toolbar.frame.maxY+30
        let collectionViewFrame = CGRect(x: 50,
                                         y: collectionViewY,
                                         width: UIScreen.main.bounds.size.width-100,
                                         height:  UIScreen.main.bounds.size.height-collectionViewY)
        productCollection = UICollectionView(frame: collectionViewFrame,
                                             collectionViewLayout: getCustomCollectionLayout(frame: collectionViewFrame))
        productCollection!.delegate = self
        productCollection!.dataSource = self
        productCollection!.register(SelectionCell.self, forCellWithReuseIdentifier: SelectionCell.identifier)
        productCollection!.register(SelectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SelectionHeader.identifier)
        productCollection!.backgroundColor = .systemGray6
        productCollection!.layer.masksToBounds = true
        productCollection!.layer.cornerRadius = 10
        productCollection!.addShadow()
    }
}

extension ProductsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SelectionHeader.identifier, for: indexPath) as? SelectionHeader else {
            return UICollectionReusableView()
        }
        header.backgroundColor = .clear
        header.title.text = "Select A Product"
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
        cell.addShadow()
        cell.itemTitle.addSubtlerShadow()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        // This will later present ProductInfoViewController and pass to it the data regarding the product selected
    }
}

extension ProductsViewController: MediatorProtocol {
    func notify(sender: ColleagueProtocol, event: Event) {
        switch event {
        case .configuredProducts:
            productCollection!.reloadData()
        case .toolbarSelection(let buttonTag):
            if buttonTag == 0 {
                goToAddProduct()
            }
            else if buttonTag == 1 {
                // select products functionality
            }
            else if buttonTag == 2 {
                // grouping functionality
            }
        default:
            print("Error in func notify in ProductDashboardViewController")
        }
    }
}


