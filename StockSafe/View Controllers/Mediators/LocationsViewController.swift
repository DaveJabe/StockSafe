//
//  LocationDashboardViewController.swift
//  StockSafe
//
//  Created by David Jabech on 7/17/21.
//

import UIKit

class LocationsViewController: UIViewController {
    
    private let toolbar = ToolbarView.init(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: UIScreen.main.bounds.width,
                                                         height: UIScreen.main.bounds.height/10),
                                           type: .productOrLocationToolbar)
    
    private var manager = LocationManager()
    
    public var locationCollection: UICollectionView?
    
    private var locations: [Location]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let layout = locationCollection.collectionViewLayout as? CollectionViewLeadingFlowLayout {
//            layout.delegate = self
//        }
        
        view.addSubview(toolbar)
        
        configureLocationCollection()
        view.addSubview(locationCollection!)
        
        manager.setMediator(mediator: self)
    }
    
    private func configureLocationCollection() {
        let collectionViewY = toolbar.frame.maxY+30
        let collectionViewFrame = CGRect(x: 50,
                                         y: collectionViewY,
                                         width: UIScreen.main.bounds.size.width-100,
                                         height:  UIScreen.main.bounds.size.height-collectionViewY)
        locationCollection = UICollectionView(frame: collectionViewFrame,
                                             collectionViewLayout: getCustomCollectionLayout(frame: collectionViewFrame))
        locationCollection!.delegate = self
        locationCollection!.dataSource = self
        locationCollection!.register(SelectionCell.self, forCellWithReuseIdentifier: SelectionCell.identifier)
        locationCollection!.register(SelectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SelectionHeader.identifier)
        locationCollection!.backgroundColor = .systemGray6
        locationCollection!.backgroundColor = .systemGray6
        locationCollection!.layer.masksToBounds = true
        locationCollection!.layer.cornerRadius = 10
        locationCollection!.addShadow()
    }
    
    @objc private func goToAddLocation() {
        let sb = UIStoryboard(name: "Main" , bundle: nil)
        let alvc = sb.instantiateViewController(withIdentifier: "AddLocationVC") as? AddLocationViewController
        alvc!.modalPresentationStyle = .pageSheet
        self.present(alvc!, animated: true)
    }
}

extension LocationsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
        
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SelectionHeader.identifier, for: indexPath) as? SelectionHeader else {
            return UICollectionReusableView()
        }
        header.backgroundColor = .clear
        header.title.text = "Select A Location"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return manager.locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectionCell.identifier, for: indexPath) as? SelectionCell else {
            return UICollectionViewCell()
        }
        cell.itemTitle.text = manager.locations[indexPath.row].name
        cell.itemTitle.configureForCell(frame: cell.bounds)
        cell.frame.size.width = cell.itemTitle.frame.size.width
        cell.backgroundColor = HexColor(manager.locations[indexPath.row].color)
        cell.contentView.layer.borderWidth = 0
        cell.addShadow()
        cell.itemTitle.addSubtlerShadow()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // this func will present location info through a LocationInfoViewController
    }
}

extension LocationsViewController: MediatorProtocol {
    func notify(sender: ColleagueProtocol, event: Event) {
        switch event {
        case .configuredLocations:
            locationCollection!.reloadData()
        case .toolbarSelection(let buttonTag):
            if buttonTag == 0 {
                goToAddLocation()
            }
            else if buttonTag == 1 {
                // select products functionality
            }
            else if buttonTag == 2 {
                // grouping functionality
            }
        default:
            print("Unnecessary message sent in func notify - LocationDashboardViewController")
        }
    }
}

