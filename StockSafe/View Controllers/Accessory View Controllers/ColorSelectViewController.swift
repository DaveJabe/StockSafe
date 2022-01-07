//
//  ColorSelectViewController.swift
//  StockSafe
//
//  Created by David Jabech on 7/7/21.
//

import UIKit
import CollectionViewCenteredFlowLayout

class ColorSelectViewController: UIViewController {
        
    // These colors were found on the 'Material Design Color Chart' at htmlcolorcodes.com
    private var productColors = ["#D32F2F", "#C2185B", "#7B1FA2", "#4527A0", "#303F9F",
                                 "#1976D2", "#0288D1", "#0097A7", "#00796B", "#388E3C",
                                 "#689F38", "#AFB42B", "#FBC02D", "#FFA000", "#F57C00",
                                 "#E64A19", "#5D4037", "#616161", "#455A64", "#273746"]
    
    // These colors were found on the 'Flat Design Color Chart' at htmlcolorcodes.com
    private var locationColors: [String] = ["#A93226", "#CB4335", "#884EA0", "#7D3C98", "#2471A3",
                                            "#2E86C1", "#17A589", "#138D75", "#229954", "#28B463",
                                            "#D4AC0D", "#D68910", "#CA6F1E", "#BA4A00", "#D0D3D4",
                                            "#A6ACAF", "#839192", "#707B7C", "#2E4053", "#273746"]
        
    @IBOutlet weak var colorCollection: UICollectionView!
    
    private func configureColorCollection() {
        colorCollection.delegate = self
        colorCollection.dataSource = self
        
        let layout = CollectionViewCenteredFlowLayout.init()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 5.0
        layout.minimumLineSpacing = 5.0
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width - 40)/5, height: ((UIScreen.main.bounds.size.width - 40)/6))
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 60)
        colorCollection.collectionViewLayout = layout
        
        colorCollection.register(SelectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SelectionHeader.identifier)
    }
    
    private func changeColorAndDismiss(colorIndex: Int) {
        if let pvc = presentingViewController as? AddProductViewController {
            pvc.selectedColor = productColors[colorIndex]
            pvc.addProductTable.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .automatic)
        }
        else if let lvc = presentingViewController as? AddLocationViewController {
            lvc.locationColor = locationColors[colorIndex]
            lvc.addLocationTable.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            
        }
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureColorCollection()
    }
}

extension ColorSelectViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return productColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SelectionHeader.identifier, for: indexPath) as? SelectionHeader else {
            return UICollectionReusableView()
        }
        if (presentingViewController as? AddProductViewController) != nil {
            header.title.text = "Select a Product Color"
        }
        else if (presentingViewController as? AddLocationViewController) != nil {
            header.title.text = "Select a Location Color"
        }
        header.backgroundColor = .white
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCollectionCell", for: indexPath)
        
        if (presentingViewController as? AddProductViewController) != nil {
            cell.backgroundColor = HexColor(productColors[indexPath.row])
        }
        else if (presentingViewController as? AddLocationViewController) != nil {
            cell.backgroundColor = HexColor(locationColors[indexPath.row])
        }
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        changeColorAndDismiss(colorIndex: indexPath.row)
    }
}
