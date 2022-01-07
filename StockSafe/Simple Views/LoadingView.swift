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
        backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = 10
        addSubview(loadingAnimation)
        loadingAnimation.frame = bounds
        loadingAnimation.animation = Animation.named("loadingBox")
        loadingAnimation.loopMode = .loop
        loadingAnimation.contentMode = .center
    }
}
