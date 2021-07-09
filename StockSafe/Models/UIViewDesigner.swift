//
//  UIViewDesigner.swift
//  StockSafe
//
//  Created by David Jabech on 7/9/21.
//

import UIKit
import CollectionViewCenteredFlowLayout

typealias design = UIViewDesigner

class UIViewDesigner {
    
    public func addlabelShadow(label: UILabel) {
        // Set the color of the shadow layer
        label.layer.shadowColor = UIColor.black.cgColor
        // Set the radius of the shadow layer
        label.layer.shadowRadius = 2.0
        // Set the opacity of the shadow layer (1 = fully opaque, 0 = fully transparent)
        label.layer.shadowOpacity = 0.4
        /* Offset refers to where and to what extent a shadow is offset from the view (in points)
        The default offset size is (0, -1), which indicates a shadow one point above the text. */
        label.layer.shadowOffset = CGSize(width: 0.5, height: 1.5)
        label.layer.masksToBounds = false
     }
    
    public func addShadow(to view: UIView) {
        // Set the color of the shadow layer
        view.layer.shadowColor = UIColor.black.cgColor
        // Set the radius of the shadow layer
        view.layer.shadowRadius = 5.0
        // Set the opacity of the shadow layer
        view.layer.opacity = 0.5
        // Set the shadow offset of the shadow layer
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.masksToBounds = true
    }
    
    public func addGradientLayer(to view: UIView, colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint, opacity: Float) {
        // Create a gradient layer.
        let gradientLayer = CAGradientLayer()
        // Set the size of the layer to be equal to size of the display.
        gradientLayer.frame = view.bounds
        // Set an array of Core Graphics colors (.cgColor) to create the gradient.
        var cgColors = [CGColor]()
        for color in colors {
            cgColors.append(color.cgColor)
        }
        gradientLayer.colors = cgColors
        // Rasterize this static layer to improve app performance.
        gradientLayer.shouldRasterize = true
        // Set path for gradient (e.g. vertical, horizontal, diagonal)
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        // Set the opacity for the gradient layer
        gradientLayer.opacity = opacity
        // Apply the gradient to the backgroundGradientView.
        view.layer.addSublayer(gradientLayer)
    }
    
    public func buildTableViewHeader(title: String) -> UIView {
        let label = UILabel()
        let header = UIView()
        label.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .white
        header.addSubview(label)
        label.text = title
        label.font =  UIFont(name: "Avenir Heavy", size: 20)
        label.textColor = .darkGray
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: header.layoutMarginsGuide.leadingAnchor),
            label.widthAnchor.constraint(equalToConstant: 250),
            label.heightAnchor.constraint(equalToConstant: 50),
            label.centerYAnchor.constraint(equalTo: header.centerYAnchor)
        ])
        return header
    }
}
extension UITextView {

    func centerVerticalText() {
        self.textAlignment = .center
        let fitSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fitSize)
        let calculate = (bounds.size.height - size.height * zoomScale) / 2
        let offset = max(1, calculate)
        contentOffset.y = -offset
    }
}
