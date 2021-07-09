//
//  LocationCollectionView.swift
//  Stocked.
//
//  Created by David Jabech on 5/29/21.
//

import UIKit
import CollectionViewCenteredFlowLayout

class LocationCollectionView: UIView {
    
    private let locations = ["Freezer", "Thawing Cabinet", "Breading Table"]
    
    public let locationView: UICollectionView = {
        let layout = CollectionViewCenteredFlowLayout.init()
        layout.sectionInset = UIEdgeInsets(top: 30, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 30.0
        layout.minimumLineSpacing = 5.0
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width - 40)/5, height: ((UIScreen.main.bounds.size.width - 40)/6))
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
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
    
    @objc private func postChangeLocation(_ sender: UITapGestureRecognizer) {
        locationView.selectItem(at: IndexPath(item: sender.view!.tag, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        collectionView(locationView, didSelectItemAt: IndexPath(item: sender.view!.tag, section: 0))
    }
    
    private func configureLayout() {
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = 10
        self.addSubview(locationView)
        locationView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        locationView.layer.cornerRadius = 10
        locationView.backgroundColor = HexColor("fdfaf6")
        locationView.frame = self.bounds
        locationView.delegate = self
        locationView.dataSource = self
    }
}

extension LocationCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = locationView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProductLocationCollectionHeader.identifier, for: indexPath) as? ProductLocationCollectionHeader else {
            return UICollectionReusableView()
        }
        header.title.text = "Locations"
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
        return locations.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = locationView.dequeueReusableCell(withReuseIdentifier: ProductLocationCollectionCell.identifier, for: indexPath) as? ProductLocationCollectionCell else {
            return UICollectionViewCell()
        }
        if indexPath.item == 0 {
            cell.layer.borderWidth = 2
        }
        else {
            cell.layer.borderWidth = 0
        }
        cell.selectionLabel.text = locations[indexPath.row]
        cell.selectionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(postChangeLocation)))
        cell.selectionLabel.tag = indexPath.item
        cell.selectionLabel.frame = cell.contentView.bounds
        cell.selectionLabel.centerVerticalText()
        cell.configureCellColor()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for visibleIndexPath in locationView.indexPathsForVisibleItems {
            let cell = locationView.cellForItem(at: visibleIndexPath) as? ProductLocationCollectionCell
            if !(cell?.isSelected)! {
                cell!.layer.borderWidth = 0
            }
        }
        
        let cell = locationView.cellForItem(at: indexPath) as? ProductLocationCollectionCell
        cell!.layer.borderWidth = 2
        selectedLocation = cell!.selectionLabel.text!
        NotificationCenter.default.post(name: NSNotification.Name(changeLocationKey), object: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = locationView.cellForItem(at: indexPath) as? ProductLocationCollectionCell
        cell!.layer.borderWidth = 0
    }
}
