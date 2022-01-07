//
//  UIViewDesigner.swift
//  StockSafe
//
//  Created by David Jabech on 7/9/21.
//

import UIKit
import CollectionViewCenteredFlowLayout

// Below are extensions for any other UI elements besides UIView and UIViewController (StockSafe fonts at the bottom)
    
func getCustomCollectionLayout(frame: CGRect) -> UICollectionViewFlowLayout {
    let layout = UICollectionViewFlowLayout()
    layout.headerReferenceSize = CGSize(width: frame.size.width, height: 90)
    layout.minimumLineSpacing = 20
    layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
    layout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width - 40)/4.5, height: ((UIScreen.main.bounds.size.width - 40)/6))
    return layout
    }
    
extension UILabel {
    
    func getDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        text = dateFormatter.string(from: Date())
    }
    
    func getTime() {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        text = timeFormatter.string(from: Date())
    }
}

extension UITextView {
    
    // This func configures the TextView to properly display text in the SelectionView CollectionViewCells (centered text)
    func configureForCell(frame: CGRect) {
        self.frame = frame
        textAlignment = .center
        let fitSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fitSize)
        let calculate = (bounds.size.height - size.height * zoomScale) / 2
        let offset = max(1, calculate)
        contentOffset.y = -offset
    }
}

extension UIWindow {
    func setRootViewController(viewController: UIViewController) {
        rootViewController = viewController
        UIView.transition(with: self,
                         duration: 0.8,
                         options: .curveEaseOut,
                         animations: nil)
    }
}

 // StockSafe Fonts

    func standardFont(size: CGFloat) -> UIFont {
        let font = UIFont(name: "Avenir Book", size: size)
        return font!
    }

    func boldFont(size: CGFloat) -> UIFont {
        let font = UIFont(name: "Avenir Heavy", size: size)
        return font!
    }
