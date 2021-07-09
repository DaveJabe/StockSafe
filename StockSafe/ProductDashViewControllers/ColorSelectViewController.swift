//
//  ColorSelectViewController.swift
//  StockSafe
//
//  Created by David Jabech on 7/7/21.
//

import UIKit
import CollectionViewCenteredFlowLayout

class ColorSelectViewController: UIViewController {
        
    // These colors were found on the 'Flat Design Color Chart' at htmlcolorcodes.com
    private var colors = [HexColor("#D32F2F"), HexColor("#C2185B"), HexColor("#7B1FA2"), HexColor("#4527A0"), HexColor("#303F9F"),
                          HexColor("#1976D2"), HexColor("#0288D1"), HexColor("#0097A7"), HexColor("#00796B"), HexColor("#388E3C"),
                          HexColor("#689F38"), HexColor("#AFB42B"), HexColor("#FBC02D"), HexColor("#FFA000"), HexColor("#F57C00"),
                          HexColor("#E64A19"), HexColor("#5D4037"), HexColor("#616161"), HexColor("#455A64"), HexColor("#273746")]
    

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
        
        colorCollection.register(ProductLocationCollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProductLocationCollectionHeader.identifier)
    }
    
    private func changeColorAndDismiss(ColorIndex: Int) {
        let pvc = self.presentingViewController as? AddProductViewController
        pvc!.selectedColor = colors[ColorIndex]
        pvc!.addProductTable.reloadRows(at: [IndexPath(row: 4, section: 0)], with: UITableView.RowAnimation.automatic)
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureColorCollection()
    }
}

extension ColorSelectViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProductLocationCollectionHeader.identifier, for: indexPath) as? ProductLocationCollectionHeader else {
            return UICollectionReusableView()
        }
        header.title.text = "Select a Color"
        header.backgroundColor = .white
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCollectionCell", for: indexPath)
        
        cell.backgroundColor = colors[indexPath.row]
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        changeColorAndDismiss(ColorIndex: indexPath.row)
    }
}
