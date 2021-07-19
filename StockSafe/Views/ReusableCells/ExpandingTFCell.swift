//
//  ProductLocationsCell.swift
//  StockSafe
//
//  Created by David Jabech on 7/16/21.
//

import UIKit

class ExpandingTFCell: UITableViewCell {
    
    // Identifier for cell reuse
    static let identifier = "ExpandingTFCellIdentifier"
    
    // Title label for cell
    public let title: UILabel = {
        let label = UILabel()
        label.font = VD.standardFont(size: 30)
        return label
    }()
    
    // The number of PTFs that should be displayed within the cell
    private var numOfTextFields: Int
    
    // The locations from which the User can choose for their product
    private let locations: [String]
    
    // The selections a User has made before reloading the cell [textField.tag : selectedRow]
    public var currentSelections: [Int:String]
    
    private let placeHolders = ["Kitchen Cooler", "Prep Table", "Front Cooler"]
    
    private var type: TextFieldCellType
    
    // Delegate for preserving User input while reloading to accomadate one more or one fewer PTF
    private weak var delegate: EPTFCDelegate?
    
    // Button for the User to press when they would like to add a new PTF
    private var addButton: SFButton
    
    // Button for the User to press when they would like to remove a PTF
    private var deleteButton: SFButton
    
    // Custom initializer
    init(numOfTextFields: Int, locations: [String], currentSelections: [Int:String], type: TextFieldCellType, delegate: EPTFCDelegate) {
        self.numOfTextFields = numOfTextFields
        self.locations = locations
        self.currentSelections = currentSelections
        self.delegate = delegate
        let symbolConfig = UIImage.SymbolConfiguration(scale: .large)
        addButton = SFButton(frame: .zero, sfImage: UIImage(systemName: "plus.circle.fill", withConfiguration: symbolConfig)!, color: .systemGreen)
        deleteButton = SFButton(frame: .zero, sfImage: UIImage(systemName: "minus.circle.fill", withConfiguration: symbolConfig)!, color: .systemRed)
        self.type = type
       
        super.init(style: .subtitle, reuseIdentifier: ExpandingTFCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureCell(type: type)
        addArchiveTF()
        addArrowSymbols()
    }
    
    public func setDelegate(delegate: EPTFCDelegate) {
        self.delegate = delegate
    }

    // Configures PTFs and addButton
    private func configureCell(type: TextFieldCellType) {
        title.frame = CGRect(x: 15,
                             y: 0,
                             width: title.intrinsicContentSize.width,
                             height: contentView.frame.size.height)
        addSubview(title)
        backgroundColor = .systemGray5
        
        if type == .textField {
            for index in 0..<numOfTextFields {
                let tf = UITextField(frame: CGRect(x: Int(contentView.frame.size.width-215),
                                                   y: Int(88*index)+25,
                                                   width: 200,
                                                   height: 35))
                tf.addTarget(self, action: #selector(getTFSelection), for: .allEditingEvents)
                tf.tag = index
                tf.font = VD.standardFont(size: 20)
                tf.borderStyle = .roundedRect
                tf.placeholder = placeHolders[index]
                tf.textAlignment = .center
                tf.text = currentSelections[index]
                tf.resignForOutsideTouch(target: self)
                addSubview(tf)
            }
        }
        else {
            for index in 0..<numOfTextFields {
                let ptf = PickerTextField(frame: CGRect(x: Int(contentView.frame.size.width-215),
                                                         y: (88*index)+25,
                                                         width: 200,
                                                         height: 35),
                                           rowData: [locations],
                                           components: 1,
                                           header: "Select Location \(index+1)")
                ptf.addTarget(self, action: #selector(getPTFSelection), for: .allEditingEvents)
                ptf.tag = index
                ptf.font = VD.standardFont(size: 20)
                ptf.borderStyle = .roundedRect
                ptf.textAlignment = .center
                ptf.resignForOutsideTouch(target: self)
                ptf.text = currentSelections[index]
                ptf.placeholder = placeHolders[index]
                addSubview(ptf)
            }
        }
        if numOfTextFields < 3 {
            addButton.frame = CGRect(x: Int(contentView.frame.size.width-250),
                                     y: Int(88*(numOfTextFields-1))+25,
                                     width: 35,
                                     height: 35)
            addButton.addTarget(self, action: #selector(addNewTF), for: .touchUpInside)
            addButton.contentMode = .scaleAspectFill
            contentView.addSubview(addButton)
        }
        if numOfTextFields != 1 {
            deleteButton.frame = CGRect(x: Int(contentView.frame.size.width-280),
                                     y: Int(88*(numOfTextFields-1))+25,
                                     width: 35,
                                     height: 35)
            if numOfTextFields == 3 {
                deleteButton.frame.origin.x = contentView.frame.size.width-250
            }
            deleteButton.addTarget(self, action: #selector(deleteTF), for: .touchUpInside)
            contentView.addSubview(deleteButton)
        }
    }

     
    private func addArrowSymbols() {
        for index in 0..<numOfTextFields {
            let arrow = UIImageView()
            arrow.image = UIImage(systemName: "arrow.down.square.fill")
            arrow.frame = CGRect(x: Int(contentView.frame.size.width-130),
                                 y: (88*index)+70,
                                 width: 35,
                                 height: 30)
            addSubview(arrow)
        }
    }
    
    public func addArchiveTF() {
        let atf = UITextField(frame: CGRect(x: Int(contentView.frame.size.width-215),
                                            y: (88*(numOfTextFields))+25,
                                            width: 200,
                                            height: 35))
        atf.text = "Archive"
        atf.font = VD.boldFont(size: 20)
        atf.isEnabled = false
        atf.textAlignment = .center
        atf.borderStyle = .roundedRect
        addSubview(atf)
    }
    
    // Function to retrieve and store PTF selection
    @objc private func getPTFSelection(_ sender: PickerTextField) {
        print(currentSelections.count)
        currentSelections[sender.tag] = sender.text
        delegate?.updateSelections(selections: currentSelections)
    }
    
    @objc private func getTFSelection(_ sender: UITextField) {
        currentSelections[sender.tag] = sender.text
        delegate?.updateSelections(selections: currentSelections)
    }
    
    // Func to pass through delegate to reload cell with an added PTF
    @objc private func addNewTF() {
        numOfTextFields += 1
        delegate?.readyForReload(numOfTextFields: numOfTextFields, currentSelections: currentSelections)
    }
    
    @objc private func deleteTF() {
        numOfTextFields -= 1
        delegate?.readyForReload(numOfTextFields: numOfTextFields, currentSelections: currentSelections)
    }
}
