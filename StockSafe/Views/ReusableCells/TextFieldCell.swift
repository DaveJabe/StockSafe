//
//  TextFieldCell.swift
//  StockSafe
//
//  Created by David Jabech on 7/16/21.
//

import UIKit

class TextFieldCell: UITableViewCell {

    static let identifier = "TextFieldCellIdentifier"
    
    private weak var delegate: TextFieldCellDelegate?
    
    public let title: UILabel = {
        let label = UILabel()
        label.font = VD.standardFont(size: 30)
        return label
    }()
    
    public var textField: UITextField = {
        let textField = UITextField()
        textField.font = VD.standardFont(size: 20)
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        return textField
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .systemGray5
        addSubview(title)
        contentView.addSubview(textField)
        textField.addTarget(self, action: #selector(sendBackText(_:)), for: .allEditingEvents)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        title.frame = CGRect(x: 15,
                             y: 0,
                             width: title.intrinsicContentSize.width,
                             height: contentView.frame.size.height)
        VD.addSubtleShadow(view: title)
        textField.frame = CGRect(x: contentView.frame.size.width-215,
                                 y: contentView.frame.size.height/3,
                                 width: 200,
                                 height: 35)
    }
    
    @objc private func sendBackText(_ sender: Any) {
        if let sender = sender as? PickerTextField {
            delegate?.returnText(senderTag: sender.tag, text: textField.text ?? "")
        }
        else if let sender = sender as? UITextField {
            delegate?.returnText(senderTag: sender.tag, text: textField.text ?? "")
        }
    }
    
    public func setDelegate(delegate: TextFieldCellDelegate) {
        self.delegate = delegate
    }
    
    public func changeToPTF(rowData: [[String]], components: Int, header: String?, tag: Int) {
        textField = PickerTextField.init(frame: textField.frame,
                                    rowData: rowData,
                                    components: components,
                                    header: header)
        textField.tag = tag
        textField.textAlignment = .center
        textField.addTarget(self, action: #selector(sendBackText(_:)), for: .allEditingEvents)
        addSubview(textField)
        
    }
}

