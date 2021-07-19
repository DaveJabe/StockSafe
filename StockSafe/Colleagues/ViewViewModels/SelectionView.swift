//
//  ProductCollectionView.swift
//  Stocked.
//
//  Created by David Jabech on 5/29/21.
//

import UIKit
import CollectionViewCenteredFlowLayout

enum SelectionViewType {
    case products
    case locations
    case destinations
}

class SelectionView: UIView, ColleagueProtocol {
    
    public weak var mediator: MediatorProtocol?
    
    public var type: SelectionViewType
            
    public var productsToDisplay: [Product]?
    
    public var locationsToDisplay: [Location]?
    
    public var destinationsToDisplay: [Location]?
        
    public var selectedProduct: Product?
    
    public var selectedLocation: Location?
    
    public var selectedDestination: Location?
    
    public let header = SelectionHeader()
    
    public let collectionView: UICollectionView = {
        let layout = CollectionViewCenteredFlowLayout.init()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 15.0
        layout.minimumLineSpacing = 5.0
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width - 40)/4.5, height: ((UIScreen.main.bounds.size.width - 40)/6))
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 60)
        let collection = UICollectionView(frame: .infinite, collectionViewLayout: layout)
        collection.register(SelectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SelectionHeader.identifier)
        collection.register(SelectionCell.self, forCellWithReuseIdentifier: SelectionCell.identifier)

        return collection
    }()

    init(frame: CGRect, type: SelectionViewType) {
        self.type = type
        super.init(frame: frame)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false
        addSubview(collectionView)
    }
    
    func setMediator(mediator: MediatorProtocol) {
        self.mediator = mediator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = 10
        
        collectionView.backgroundColor = .systemGray6
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collectionView.layer.cornerRadius = 10
        collectionView.frame = bounds
    }
}

extension SelectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SelectionHeader.identifier, for: indexPath) as? SelectionHeader else {
            return UICollectionReusableView()
        }
        header.backgroundColor = .systemGray6
        switch type {
        case .products:
            header.title.text = "Products"
        case .locations:
            header.title.text = "Locations"
        case .destinations:
            header.title.text = "Destinations"
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch type {
        case .products:
            return productsToDisplay?.count ?? 0
        case .locations:
            return locationsToDisplay?.count ?? 0
        case .destinations:
            return destinationsToDisplay?.count ?? 0
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectionCell.identifier, for: indexPath) as? SelectionCell else {
            return UICollectionViewCell()
        }
        switch type {
        case .products:
            cell.itemTitle.text = productsToDisplay?[indexPath.row].name ?? ""
            cell.backgroundColor = HexColor(productsToDisplay?[indexPath.row].color ?? "FFFFF")
        case .locations:
            cell.itemTitle.text = locationsToDisplay?[indexPath.row].name ?? ""
            cell.backgroundColor = HexColor(locationsToDisplay?[indexPath.row].color ?? "FFFFF")
        case .destinations:
            cell.itemTitle.text = destinationsToDisplay?[indexPath.row].name ?? ""
            cell.backgroundColor = HexColor(destinationsToDisplay?[indexPath.row].color ?? "FFFFF")
        }
        cell.itemTitle.configureForCell(frame: cell.bounds)
        cell.frame.size.width = cell.itemTitle.frame.size.width
        cell.contentView.layer.borderWidth = 0
        VD.addShadow(view: cell)
        VD.addSubtleShadow(view: cell.itemTitle)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? SelectionCell
        switch type {
        case .products:
            selectedProduct = productsToDisplay?[indexPath.row]
        case .locations:
            selectedLocation = locationsToDisplay?[indexPath.row]
        case .destinations:
            selectedDestination = destinationsToDisplay?[indexPath.row]
        }
        cell!.layer.borderWidth = 2
        mediator?.notify(sender: self, event: .selectionChanged(type: type))
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? SelectionCell
        cell!.layer.borderWidth = 0
    }
}


