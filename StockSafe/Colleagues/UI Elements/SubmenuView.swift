//
//  SubmenuView.swift
//  StockSafe
//
//  Created by David Jabech on 7/27/21.
//

import UIKit

enum SubmenuOption {
    case newCases
    case stockCases
}

class SubmenuView: UIView, ColleagueProtocol {
    
    public var mediator: MediatorProtocol?
    
    public var option: SubmenuOption
        
    private let grayBackground: UIView = {
        let view = UIView()
        view.backgroundColor = ColorThemes.foregroundColor2
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.spacing = 30
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        return stackView
    }()
    
    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.spacing = 30
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        return stackView
    }()
    
    private let ptfStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.spacing = 30
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let convertibleLabelView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.axis = .horizontal
        return stackView
    }()
    
    private let connectorView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorThemes.foregroundColor1
        return view
    }()
    
    public let productSelect: UIButton = {
        let button = UIButton()
        button.makeSVButton()
        button.tag = 0
        return button
    }()

    
    public let locationSelect: UIButton = {
        let button = UIButton()
        button.makeSVButton()
        button.tag = 1
        return button
    }()
    
    public let destinationSelect: UIButton = {
        let button = UIButton()
        button.makeSVButton()
        button.tag = 2
        return button
    }()
    
    private let productLabel: UILabel = {
        let label = UILabel()
        label.text = "Product"
        label.textAlignment = .center
        label.font = boldFont(size: 20)
        label.textColor = .white
        label.addSubtleShadow()
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Location"
        label.textAlignment = .center
        label.font = boldFont(size: 20)
        label.textColor = .white
        label.addSubtleShadow()
        return label
    }()
    
    public let convertibleLabel: UILabel = {
        let label = UILabel()
        label.text = "Destination"
        label.textAlignment = .center
        label.font = boldFont(size: 20)
        label.textColor = .white
        label.addSubtleShadow()
        return label
    }()
    
    private let stockOrAddLabel: UILabel = {
        let label = UILabel()
        label.text = "Add"
        label.textAlignment = .center
        label.font = boldFont(size: 20)
        label.textColor = .white
        label.addSubtleShadow()
        return label
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemGray6
        return button
    }()
    
    private let addModeButton: UIButton = {
        let button = UIButton()
        let symbolConfig = UIImage.SymbolConfiguration(weight: .bold)
        let arrowSymbol = UIImage(systemName: "arrow.up.and.down", withConfiguration: symbolConfig)
        button.setImage(arrowSymbol, for: .normal)
        button.tintColor = .systemGray6
        return button
    }()
    
    public var ptfOne: PickerTextField?
    
    public var ptfTwo: PickerTextField?
    
    init(frame: CGRect, option: SubmenuOption) {
        self.option = option
        super.init(frame: frame)
        configureSubmenu()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setMediator(mediator: MediatorProtocol) {
        self.mediator = mediator
    }
    
    public func toggleSubmenu(option: SubmenuOption) {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 60)
        self.option = option
        
        if option == .newCases {
            connectorView.frame.origin.x = 0
            
            doneButton.setImage(UIImage(systemName: "plus", withConfiguration: symbolConfig), for: .normal)
            if !ptfStackView.subviews.contains(ptfTwo!) {
                convertibleLabel.text = "Single Case"
            }
            else {
                convertibleLabel.text = "Case Range"
            }
            stockOrAddLabel.text = "Add Cases"
            convertibleLabelView.addArrangedSubview(addModeButton)
            
            destinationSelect.removeFromSuperview()
            stackView.insertArrangedSubview(ptfStackView, at: 2)
        }
        else {
            connectorView.frame.origin.x = frame.maxX-frame.size.width/3
            
            doneButton.setImage(UIImage(systemName: "arrow.right", withConfiguration: symbolConfig), for: .normal)
            convertibleLabel.text = "Destination"
            stockOrAddLabel.text = "Stock Cases"
            addModeButton.removeFromSuperview()
            
            ptfStackView.removeFromSuperview()
            stackView.insertArrangedSubview(destinationSelect, at: 2)
        }
    }
    
    private func configureSubmenu() {
        backgroundColor = .clear
        
        stackView.addArrangedSubview(productSelect)
        stackView.addArrangedSubview(locationSelect)
        stackView.addArrangedSubview(destinationSelect)
        stackView.addArrangedSubview(doneButton)
        
        labelStackView.addArrangedSubview(productLabel)
        labelStackView.addArrangedSubview(locationLabel)
        labelStackView.addArrangedSubview(convertibleLabelView)
        convertibleLabelView.addArrangedSubview(convertibleLabel)
        labelStackView.addArrangedSubview(stockOrAddLabel)
                
        connectorView.frame.size = CGSize(width: frame.size.width/3,
                                          height: 11)
        
        grayBackground.frame = CGRect(x: 0,
                                      y: 10,
                                      width: frame.size.width,
                                      height: frame.size.height-10)
        
        let width = grayBackground.frame.size.width-60 
        let height = grayBackground.frame.size.height-60
        
        grayBackground.addGradientLayer(colors: [ColorThemes.foregroundColor1, ColorThemes.foregroundColor2.withAlphaComponent(0.5)], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), opacity: 1)
        
        stackView.frame = CGRect(x: 30,
                                 y: 45,
                                 width: width,
                                 height: height)
        
        labelStackView.frame = CGRect(x: 30,
                                      y: 15,
                                      width: width,
                                      height: 30)
        let array = Array(1...100)
        
        ptfOne = PickerTextField(frame: CGRect(x: 0,
                                               y: 0,
                                               width: 68,
                                               height: 30), rowData: [(array.map { String($0) })], components: 1, header: nil)
        
        ptfOne!.placeholder = "1"
        ptfOne!.addShadow()
        ptfTwo = PickerTextField(frame: CGRect(x: 0,
                                               y: 0,
                                               width: 68,
                                               height: 30), rowData: [(array.map { String($0) })], components: 1, header: nil)
        ptfTwo!.placeholder = "100"
        ptfTwo!.addShadow()
        
        ptfStackView.addArrangedSubview(ptfOne!)
        
        ptfStackView.addArrangedSubview(ptfTwo!)
        
        
        grayBackground.addSubview(stackView)
        grayBackground.addSubview(labelStackView)
        addSubview(grayBackground)
        addSubview(connectorView)
        bringSubviewToFront(connectorView)
        
//        doneButton.layer.borderWidth = 0.5
//        doneButton.backgroundColor = .white.withAlphaComponent(0.2)
        doneButton.addShadow()
        
        addModeButton.addTarget(self, action: #selector(toggleAddMode(_:)), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneButtonSelected(_:)), for: .touchUpInside)
        productSelect.addTarget(self, action: #selector(submenuSelection(_:)), for: .touchUpInside)
        locationSelect.addTarget(self, action: #selector(submenuSelection(_:)), for: .touchUpInside)
        destinationSelect.addTarget(self, action: #selector(submenuSelection(_:)), for: .touchUpInside)
        
        toggleSubmenu(option: option)
    }
    
    @objc private func toggleAddMode(_ sender: UIButton) {
        if ptfStackView.subviews.contains(ptfTwo!) {
            convertibleLabel.text = "Single Case"
            ptfStackView.layoutMargins = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
            ptfTwo!.removeFromSuperview()
            // refreshBottomBorder doesn't work here for some reason, so I'm setting the border width manually
        }
        else {
            convertibleLabel.text = "Case Range"
            ptfStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            ptfStackView.addArrangedSubview(ptfTwo!)
            // refreshBottomBorder doesn't work here for some reason, so I'm setting the border width manually
        }
        
    }
    
    @objc private func doneButtonSelected(_ sender: UIButton) {
        mediator?.notify(sender: self, event: .doneButtonSelected(option: option))
    }
    
    @objc private func submenuSelection(_ sender: UIButton) {
        mediator?.notify(sender: self, event: .submenuSelection(buttonTag: sender.tag))
    }
    
}
