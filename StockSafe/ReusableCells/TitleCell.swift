//
//  TitleCell.swift
//  Stocked.
//
//  Created by David Jabech on 4/26/21.
//

import UIKit

class TitleCell: UITableViewCell {

    static let identifier = "titleCellidentifier"
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 15)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 100, y: 0, width: 200, height: contentView.frame.size.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
    }
    
    public func configure(with model: TitleCellOption) {
        titleLabel.text = model.title
    }

}
