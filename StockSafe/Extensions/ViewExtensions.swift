//
//  ViewExtensions.swift
//  StockSafe
//
//  Created by David Jabech on 8/8/21.
//

import UIKit

// Below is a UIView extension that provides many of the functions used to configure UI elements in StockSafe (e.g. shadows, gradients, etc.)

extension UIView {
    
    /* The following four functions are not currently used in this app, but are here just in case we want to spice things up design wise;
       these funcs each add a triangle sublayer facing a direction (right, left, up, down). */
    
    func setRightTriangle(){
        backgroundColor = .clear
        
        let heightWidth = frame.size.width
        let path = CGMutablePath()
        
        path.move(to: CGPoint(x: heightWidth/2, y: 0))
        path.addLine(to: CGPoint(x:heightWidth, y: heightWidth/2))
        path.addLine(to: CGPoint(x:heightWidth/2, y:heightWidth))
        path.addLine(to: CGPoint(x:heightWidth/2, y:0))
        
        let shape = CAShapeLayer()
        shape.path = path
        shape.fillColor = UIColor.blue.cgColor
        
        layer.insertSublayer(shape, at: 0)
    }
    
    func setLeftTriangle(){
        backgroundColor = .clear
        
        let heightWidth = frame.size.width
        let path = CGMutablePath()
        
        path.move(to: CGPoint(x: heightWidth/2, y: 0))
        path.addLine(to: CGPoint(x:0, y: heightWidth/2))
        path.addLine(to: CGPoint(x:heightWidth/2, y:heightWidth))
        path.addLine(to: CGPoint(x:heightWidth/2, y:0))
        
        let shape = CAShapeLayer()
        shape.path = path
        shape.fillColor = UIColor.blue.cgColor
        
        layer.insertSublayer(shape, at: 0)
    }
    
    func setUpTriangle(){
        let heightWidth = frame.size.width
        let path = CGMutablePath()
        
        path.move(to: CGPoint(x: 0, y: heightWidth))
        path.addLine(to: CGPoint(x:heightWidth/2, y: heightWidth/2))
        path.addLine(to: CGPoint(x:heightWidth, y:heightWidth))
        path.addLine(to: CGPoint(x:0, y:heightWidth))
        
        let shape = CAShapeLayer()
        shape.path = path
        shape.fillColor = UIColor.blue.cgColor
        
        layer.insertSublayer(shape, at: 0)
    }
    
    func setDownTriangle(){
        backgroundColor = .clear
        
        let heightWidth = frame.size.width
        let path = CGMutablePath()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x:heightWidth/2, y: heightWidth/2))
        path.addLine(to: CGPoint(x:heightWidth, y:0))
        path.addLine(to: CGPoint(x:0, y:0))
        
        let shape = CAShapeLayer()
        shape.path = path
        shape.fillColor = UIColor.blue.cgColor
        
        layer.insertSublayer(shape, at: 0)
    }
    
    // This func makes a UIView appear as a circle (used for the home tab bar menu 'button')
    func asCircle() {
        layer.cornerRadius = self.frame.width / 2;
        layer.masksToBounds = true
    }
    
    // Adds a two-color gradient layer to a UIView (used for the submenu background)
    func addGradientLayer(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint, opacity: Float) {
        // Create a gradient layer.
        let gradientLayer = CAGradientLayer()
        // Set the size of the layer to be equal to size of the display.
        gradientLayer.frame = bounds
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
        // This one isn't necessary here but good to know: you can change the type of a gradient to be either radial, conical, or axial
        gradientLayer.type = .axial
        // Apply the gradient to the backgroundGradientView.
        layer.addSublayer(gradientLayer)
    }
    
    // Adds a drop shadow to a UIView
    func addShadow() {
        // Set the color of the shadow layer
        layer.shadowColor = UIColor.black.cgColor
        // Set the radius of the shadow layer
        layer.shadowRadius = 2.5
        // Set the opacity of the shadow layer (1 = fully opaque, 0 = fully transparent)
        layer.shadowOpacity = 0.6
        /* Offset refers to where and to what extent a shadow is offset from the view (in points)
         The default offset size is (0, -1), which indicates a shadow one point above the text. */
        layer.shadowOffset = CGSize(width: 0.5, height: 1.5)
        // Prevent layers of view from extending beyond the view
        layer.masksToBounds = false
    }
    
    // Another shadow function (intended for labels/textViews/some lighter objects like textfields) for adding a shadow that's a tad more subltle
    func addSubtleShadow() {
        // Set the color of the shadow layer
        layer.shadowColor = UIColor.black.cgColor
        // Set the radius of the shadow layer
        layer.shadowRadius = 2.0
        // Set the opacity of the shadow layer (1 = fully opaque, 0 = fully transparent)
        layer.shadowOpacity = 0.4
        /* Offset refers to where and to what extent a shadow is offset from the view (in points)
         The default offset size is (0, -1), which indicates a shadow one point above the text. */
        layer.shadowOffset = CGSize(width: 0.5, height: 1.5)
        // Prevent layers of view from extending beyond the view
        layer.masksToBounds = false
    }
    
    // One last shadow func for extra subtle shadows (useful for labels that are NOT bolded)
    func addSubtlerShadow() {
        // Set the color of the shadow layer
        layer.shadowColor = UIColor.black.cgColor
        // Set the radius of the shadow layer
        layer.shadowRadius = 0.5
        // Set the opacity of the shadow layer (1 = fully opaque, 0 = fully transparent)
        layer.shadowOpacity = 0.4
        /* Offset refers to where and to what extent a shadow is offset from the view (in points)
         The default offset size is (0, -1), which indicates a shadow one point above the text. */
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        // Prevent layers of view from extending beyond the view
        layer.masksToBounds = false
    }
    
    /* SIKE! Here's another shadow function: adds a shadow within a view to provide a 3D-effect to the appearance of a view
    (we probably won't be using this one anymore, but just in case, here it is) */
    func addShadowWithin() {
        // masksToBounds so that the shadow view doesn't extend outside of the views bounds
        layer.masksToBounds = true
        // Set the shadow radius
        layer.shadowRadius = 5
        // Set the shadow opacity
        layer.shadowOpacity = 0.5
        // Create a path for the shadow (in this case an ellipse, for a rounded appearance)
        let shadowPath = CGPath(ellipseIn: CGRect(x: 0,
                                                  y: frame.maxY,
                                                  width: layer.bounds.width + 20 * 2,
                                                  height: 20),
                                transform: nil)
        // Set the shadow path
        layer.shadowPath = shadowPath
    }
    
    // Configures the item view for SelectionView cells
    func configureItemView() {
        layer.cornerRadius = 6.0
        layer.borderWidth = 1.0
    }
}
