//
//  ToolbarView.swift
//  StockSafe
//
//  Created by David Jabech on 7/26/21.
//

import UIKit

enum ToolbarType {
    case caseToolbar
    case productOrLocationToolbar
}

class ToolbarView: UIView, ColleagueProtocol {
    
    private var type: ToolbarType
    
    private var models = [UIButton]()
    
    public weak var mediator: MediatorProtocol?
    
    public var buttonOne: UIButton = {
        let button = UIButton()
        button.makeSFButton(symbolName: "plus", tintColor: .systemGray6, configuration: Constants.SymbolConfigs.toolbarSymbolConfig)
        return button
    }()
    
    public var buttonTwo: UIButton = {
        let button = UIButton()
        button.makeSFButton(symbolName: "hand.point.up.left", tintColor: .systemGray6, configuration: Constants.SymbolConfigs.toolbarSymbolConfig)
        return button
    }()
    
    public var buttonThree: UIButton = {
        let button = UIButton()
        button.makeSFButton(symbolName: "arrow.left.arrow.right", tintColor: .systemGray6, configuration: Constants.SymbolConfigs.toolbarSymbolConfig)
        return button
    }()
    
    init(frame: CGRect, type: ToolbarType) {
        self.type = type
        super.init(frame: frame)
        configureModels()
        backgroundColor = ColorThemes.foregroundColor1
        configureButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setMediator(mediator: MediatorProtocol) {
        self.mediator = mediator
    }
    
    @objc private func notifyMediator(_ sender: UIButton) {
        mediator?.notify(sender: self, event: .toolbarSelection(buttonTag: sender.tag))
    }
    
    private func configureModels() {
        models.append(buttonOne)
        models.append(buttonTwo)
        if type != .caseToolbar {
            buttonThree.makeSFButton(symbolName: "folder.badge.plus", tintColor: .systemGray6, configuration: Constants.SymbolConfigs.toolbarSymbolConfig)
        }
        models.append(buttonThree)
    }
    
    private func configureButtons() {
        let width: CGFloat = frame.size.width/3
        for (index, button) in models.enumerated() {
            if index == 0 {
                button.addBorder(side: .right, thickness: 0.5, color: .black)
            }
            if index == 2 {
                button.addBorder(side: .left, thickness: 0.5, color: .black)
            }
            button.frame.origin = CGPoint(x: width*CGFloat(index), y: 0)
            button.frame.size = CGSize(width: width, height: frame.size.height)
            button.tag = index
            button.addShadow()
            button.addTarget(self, action: #selector(notifyMediator(_:)), for: .touchUpInside)
            addSubview(button)
            print("Tag: \(button.tag)")
        }
    }
}
