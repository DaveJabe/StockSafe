//
//  NotConnectedView.swift
//  Stocked.
//
//  Created by David Jabech on 5/29/21.
//

import UIKit
import Lottie

class NotConnectedView: UIView {
    
    private let notConnectedLabel = UILabel()
    public let notConnectedAnimation = AnimationView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        self.backgroundColor = .white
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        
        self.addSubview(notConnectedLabel)
        notConnectedLabel.text = "Please connect to the internet to stock cases"
        notConnectedLabel.font = UIFont(name: "Avenir", size: 18)
        notConnectedLabel.frame = self.bounds
        notConnectedLabel.textAlignment = .center
        
        self.addSubview(notConnectedAnimation)
        notConnectedAnimation.animation = Animation.named("noWiFi")
        notConnectedAnimation.contentMode = .center
        notConnectedAnimation.loopMode = .playOnce
        notConnectedAnimation.frame = CGRect(x: self.frame.size.width/2.5, y: 20, width: 100, height: 100)
        }
}
