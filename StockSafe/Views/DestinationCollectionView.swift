//
//  DestinationCollectionView.swift
//  Stocked.
//
//  Created by David Jabech on 5/30/21.
//

import UIKit
import CollectionViewCenteredFlowLayout


class DestinationCollectionView: UIView {
    
    private let destinations = ["Thawing Cabinet", "Breading Table", "Archive"]
    
    public let destinationView: UICollectionView = {
        let layout = CollectionViewCenteredFlowLayout.init()
        layout.sectionInset = UIEdgeInsets(top: 30, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 30.0
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
    
    @objc private func postChangeDestination(_ sender: UITapGestureRecognizer) {
        destinationView.selectItem(at: IndexPath(item: sender.view!.tag, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        collectionView(destinationView, didSelectItemAt: IndexPath(item: sender.view!.tag, section: 0))
    }
    
    private func configureLayout() {
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = 10
        self.addSubview(destinationView)
        destinationView.backgroundColor = HexColor("fdfaf6")
        destinationView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        destinationView.layer.cornerRadius = 10
        destinationView.frame = self.bounds
        destinationView.delegate = self
        destinationView.dataSource = self
    }
}

extension DestinationCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = destinationView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProductLocationCollectionHeader.identifier, for: indexPath) as? ProductLocationCollectionHeader else {
            return UICollectionReusableView()
        }
        header.title.text = "Destinations"
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return destinations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = destinationView.dequeueReusableCell(withReuseIdentifier: ProductLocationCollectionCell.identifier, for: indexPath) as? ProductLocationCollectionCell else {
            return UICollectionViewCell()
        }
        if indexPath.item == 0 {
            cell.layer.borderWidth = 2
        }
        else {
            cell.layer.borderWidth = 0
        }
        cell.selectionLabel.text = destinations[indexPath.row]
        cell.selectionLabel.frame = cell.contentView.bounds
        cell.selectionLabel.centerVerticalText()
        cell.selectionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(postChangeDestination)))
        cell.selectionLabel.tag = indexPath.item
        cell.configureCellColor()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for visibleIndexPath in destinationView.indexPathsForVisibleItems {
            let cell = destinationView.cellForItem(at: visibleIndexPath) as? ProductLocationCollectionCell
            if !(cell?.isSelected)! {
                cell!.layer.borderWidth = 0
            }
        }
        
        let cell = destinationView.cellForItem(at: indexPath) as? ProductLocationCollectionCell
        cell!.layer.borderWidth = 2
        selectedDestination = cell!.selectionLabel.text!
        NotificationCenter.default.post(name: NSNotification.Name(changeDestinationKey), object: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = destinationView.cellForItem(at: indexPath) as? ProductLocationCollectionCell
        cell!.layer.borderWidth = 0
    }
}
