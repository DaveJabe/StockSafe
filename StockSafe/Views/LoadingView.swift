//
//  LoadingView.swift
//  Stocked.
//
//  Created by David Jabech on 5/29/21.
//

import UIKit
import Lottie

class LoadingView: UIView {

    public let loadingAnimation = AnimationView()
    
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
        self.addSubview(loadingAnimation)
        loadingAnimation.frame = self.bounds
        loadingAnimation.animation = Animation.named("loadingBox")
        loadingAnimation.loopMode = .loop
        loadingAnimation.contentMode = .center
    }
    
}
