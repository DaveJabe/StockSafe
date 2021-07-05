//
//  ExpiredCaseCell.swift
//  Stocked.
//
//  Created by David Jabech on 4/20/21.
//

import UIKit

class ExpiredCaseCell: UITableViewCell {
    
    static let identifier = "expiredCaseCellidentifier"
    
    var productLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 25)
        return label
    }()
    
    var locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 25)
        return label
    }()
    
    var caseNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 25)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(productLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(caseNumberLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        productLabel.frame = CGRect(x: 15, y: 15, width: 250, height: 30)
        locationLabel.frame = CGRect(x: 15, y: 40, width: 250, height: 30)
        caseNumberLabel.frame = CGRect(x: 385, y: 30, width: 50, height: 30)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productLabel.text = ""
        locationLabel.text = ""
        caseNumberLabel.text = ""
    }

}

