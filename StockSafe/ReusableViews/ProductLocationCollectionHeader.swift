//
//  ProductLocationCollectionHeader.swift
//  Stocked.
//
//  Created by David Jabech on 5/31/21.
//

import UIKit

class ProductLocationCollectionHeader: UICollectionReusableView {
    
    static let identifier = "ProductLocationCollectionHeader"
    
    public let title: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir Heavy", size: 30)
        label.textAlignment = .center
        label.textColor = .darkText
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        self.addSubview(title)
        self.backgroundColor = HexColor("fdfaf6")
        title.frame = self.bounds
    }
}
