//
//  ProductCollectionView.swift
//  Stocked.
//
//  Created by David Jabech on 5/29/21.
//

import UIKit
import CollectionViewCenteredFlowLayout

class ProductCollectionView: UIView {
    
    public let products = ["Filet", "Spicy", "Nugget", "Strip", "Grilled Filet", "Grilled Nugget", "Breakfast Filet"]
    
    private var labelsReference: [Int] = []
    
    public let productView: UICollectionView = {
        let layout = CollectionViewCenteredFlowLayout.init()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 5.0
        layout.minimumLineSpacing = 5.0
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width - 40)/5, height: ((UIScreen.main.bounds.size.width - 40)/6))
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 60)
        let collection = UICollectionView(frame: .infinite, collectionViewLayout: layout)
        collection.register(ProductLocationCollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProductLocationCollectionHeader.identifier)
        collection.register(ProductLocationCollectionCell.self, forCellWithReuseIdentifier: ProductLocationCollectionCell.identifier)

        return collection
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func postChangeProduct(_ sender: UITapGestureRecognizer) {
        productView.selectItem(at: IndexPath(item: sender.view!.tag, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        collectionView(productView, didSelectItemAt: IndexPath(item: sender.view!.tag, section: 0))
    }
    
    
    private func configureLayout() {
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = 10
        self.addSubview(productView)
        productView.backgroundColor = HexColor("fdfaf6")
        productView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        productView.layer.cornerRadius = 10
        productView.frame = self.bounds
        productView.delegate = self
        productView.dataSource = self
        productView.allowsMultipleSelection = false
    }
}

extension ProductCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProductLocationCollectionHeader.identifier, for: indexPath) as? ProductLocationCollectionHeader else {
            return UICollectionReusableView()
        }
        
        header.title.text = "Products"
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = productView.dequeueReusableCell(withReuseIdentifier: ProductLocationCollectionCell.identifier, for: indexPath) as? ProductLocationCollectionCell else {
            return UICollectionViewCell()
        }
        if indexPath.item == 0 {
            cell.layer.borderWidth = 2
        }
        else {
            cell.layer.borderWidth = 0
        }
        cell.selectionLabel.text = products[indexPath.row]
        cell.selectionLabel.frame = cell.contentView.bounds
        cell.selectionLabel.centerVerticalText()
        cell.selectionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(postChangeProduct(_:))))
        cell.selectionLabel.tag = indexPath.item
        cell.configureCellColor()
            
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for index in 0...productView.numberOfItems(inSection: 0)-1 {
            let cell = productView.cellForItem(at: IndexPath(item: index, section: 0)) as? ProductLocationCollectionCell
            if !cell!.isSelected {
                cell!.layer.borderWidth = 0
            }
        }
        
        let cell = productView.cellForItem(at: indexPath) as? ProductLocationCollectionCell
        cell!.layer.borderWidth = 2
        selectedProduct = cell!.selectionLabel.text!
        NotificationCenter.default.post(name: NSNotification.Name(changeProductKey), object: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = productView.cellForItem(at: indexPath) as? ProductLocationCollectionCell
        cell!.layer.borderWidth = 0
    }
}

