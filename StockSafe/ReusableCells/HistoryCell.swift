//
//  HistoryCell.swift
//  Stocked.
//
//  Created by David Jabech on 6/4/21.
//

import UIKit

class HistoryCell: UITableViewCell {
    
    public let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 20)
        label.textAlignment = .left
        return label
    }()
    
    public let casesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 20)
        return label
    }()
    
    public let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 20)
        return label
    }()
    
    private let arrowIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "arrow.forward")
        return imageView
    }()
    
    public let destinationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 20)
        return label
    }()

    static let identifier = "HistoryCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(casesLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(arrowIcon)
        contentView.addSubview(destinationLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = contentView.frame.size.height-10
        timestampLabel.frame = CGRect(x: 5,
                                      y: 0,
                                      width: 40,
                                      height: height)
        casesLabel.frame = CGRect(x: 50,
                                  y: 0,
                                  width: 40,
                                  height: height)
        locationLabel.frame = CGRect(x: 100,
                                     y: 0,
                                     width: 40,
                                     height: height)
        arrowIcon.frame = CGRect(x: 150,
                                 y: 0,
                                 width: 40,
                                 height: height)
        destinationLabel.frame = CGRect(x: 200,
                                 y: 0,
                                 width: 40,
                                 height: height)
    }
    
    override func prepareForReuse() {
        timestampLabel.text = ""
        locationLabel.text = ""
        destinationLabel.text = ""
    }
}
