//
//  UIViewDesigner.swift
//  StockSafe
//
//  Created by David Jabech on 7/9/21.
//

import UIKit
import CollectionViewCenteredFlowLayout

typealias VD = ViewDesigner

class ViewDesigner: UIViewController {
    
    // StockSafe Fonts
    
    static func standardFont(size: CGFloat) -> UIFont {
        let font = UIFont(name: "Avenir Book", size: size)
        return font!
    }
    
    static func boldFont(size: CGFloat) -> UIFont {
        let font = UIFont(name: "Avenir Heavy", size: size)
        return font!
    }
    
    // General Functions for Enhancing UIViews
    
    // Adds a drop shadow to a UIView
    static func addShadow(view: UIView) {
        // Set the color of the shadow layer
        view.layer.shadowColor = UIColor.black.cgColor
        // Set the radius of the shadow layer
        view.layer.shadowRadius = 2.0
        // Set the opacity of the shadow layer (1 = fully opaque, 0 = fully transparent)
        view.layer.shadowOpacity = 0.4
        /* Offset refers to where and to what extent a shadow is offset from the view (in points)
        The default offset size is (0, -1), which indicates a shadow one point above the text. */
        view.layer.shadowOffset = CGSize(width: 0.5, height: 1.5)
        // Prevent layers of view from extending beyond the view
        view.layer.masksToBounds = false
     }
    
    // Another shadow function (intended for labels/textViews/some lighter objects like textfields) for adding a shadow that's a tad more subltle
    static func addSubtleShadow(view: UIView) {
        // Set the color of the shadow layer
        view.layer.shadowColor = UIColor.black.cgColor
        // Set the radius of the shadow layer
        view.layer.shadowRadius = 1.0
        // Set the opacity of the shadow layer (1 = fully opaque, 0 = fully transparent)
        view.layer.shadowOpacity = 0.2
        /* Offset refers to where and to what extent a shadow is offset from the view (in points)
        The default offset size is (0, -1), which indicates a shadow one point above the text. */
        view.layer.shadowOffset = CGSize(width: 0.5, height: 1.5)
        // Prevent layers of view from extending beyond the view
        view.layer.masksToBounds = false
    }
    
    static func configureItemView(view: UIView) {
        view.layer.cornerRadius = 6.0
        view.layer.borderWidth = 1.0
        view.layer.masksToBounds = true
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 0.5
        let shadowPath = CGPath(ellipseIn: CGRect(x: 0,
                                                    y: view.frame.maxY,
                                                    width: view.layer.bounds.width + 20 * 2,
                                                    height: 20),
                                transform: nil)
                
        view.layer.shadowPath = shadowPath
    }
    
    static func addGradientLayer(to view: UIView, colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint, opacity: Float) {
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
    
    static func setCustomCollectionLayout(collectionView: UICollectionView) {
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: collectionView.frame.size.width, height: 90)
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width - 40)/4.5, height: ((UIScreen.main.bounds.size.width - 40)/6))
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
}
extension UITextView {
    
    func configureForCell(frame: CGRect) {
        self.frame = frame
        self.textAlignment = .center
        let fitSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fitSize)
        let calculate = (bounds.size.height - size.height * zoomScale) / 2
        let offset = max(1, calculate)
        contentOffset.y = -offset
    }
}

extension UITextField {
    @objc func resign(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    func toggle(enable: Bool) {
        if enable {
            isEnabled = true
            backgroundColor = .white
        }
        else {
            text = ""
            isEnabled = false
            backgroundColor = .systemGray3
        }
    }
    
    func resignForOutsideTouch(target: Any) {
        addTarget(self, action: #selector(resign(_:)), for: .touchUpOutside)
    }
}
