//
//  PopUpMenuView.swift
//  StockSafe
//
//  Created by David Jabech on 7/28/21.
//

import UIKit
import Lottie

class PopUpMenuView: UIView, ColleagueProtocol {
    
    var mediator: MediatorProtocol?
    
    public let boxAnimation = AnimationView()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurePopUpMenu()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMediator(mediator: MediatorProtocol) {
        self.mediator = mediator
    }
    
    func configurePopUpMenu() {
        backgroundColor = .clear
        boxAnimation.animation = Animation.named("loadingBox")
        boxAnimation.contentMode = .redraw
        boxAnimation.loopMode = .playOnce
        boxAnimation.animationSpeed = 2
        boxAnimation.frame = bounds
        addSubview(boxAnimation)
    }
    

}
