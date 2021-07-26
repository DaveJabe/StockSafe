//
//  LocationDashboardViewController.swift
//  StockSafe
//
//  Created by David Jabech on 7/17/21.
//

import UIKit

class LocationDashboardViewController: UIViewController {
    
    private var manager = LocationManager()
    
    private var locations: [Location]?
    
    private var goToAddLocationButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "plus.app.fill")
        button.tintColor = .systemGreen
        button.action = #selector(goToAddLocation(_:))
        return button
    }()
    
    @IBOutlet var locationCollection: UICollectionView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let layout = locationCollection.collectionViewLayout as? CollectionViewLeadingFlowLayout {
//            layout.delegate = self
//        }
        
        manager.setMediator(mediator: self)
        
        configureLocationCollection()
        
        goToAddLocationButton.target = self
        navigationItem.rightBarButtonItem = goToAddLocationButton
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let hvc = parent?.children.first(where: { $0.restorationIdentifier == "homeScreen" })
        hvc?.viewDidLoad()
    }
    
    private func configureLocationCollection() {
        locationCollection.delegate = self
        locationCollection.dataSource = self
        locationCollection.register(SelectionCell.self, forCellWithReuseIdentifier: SelectionCell.identifier)
        locationCollection.register(SelectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SelectionHeader.identifier)
        VD.addShadow(view: locationCollection)
        VD.setCustomCollectionLayout(collectionView: locationCollection)
    }
    
    @objc private func goToAddLocation(_ sender: UIBarButtonItem) {
        let alvc = storyboard?.instantiateViewController(withIdentifier: "addLocation") as? AddLocationViewController
        alvc!.modalPresentationStyle = .pageSheet
        present(alvc!, animated: true)
    }
}

extension LocationDashboardViewController: MediatorProtocol {
    func notify(sender: ColleagueProtocol, event: Event) {
        switch event {
        case .configuredLocations:
            locationCollection.reloadData()
        default:
            print("Unnecessary message sent in func notify - LocationDashboardViewController")
        }
    }
    
    func relayInfo(sender: ColleagueProtocol, info: Any) {
    }
}

extension LocationDashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
        
    
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
        VD.addShadow(view: cell)
        VD.addSubtleShadow(view: cell.itemTitle)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // this func will present location info through a LocationInfoViewController
    }
}

