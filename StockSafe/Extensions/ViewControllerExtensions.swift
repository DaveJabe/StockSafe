//
//  ViewControllerExtensions.swift
//  StockSafe
//
//  Created by David Jabech on 8/8/21.
//

import UIKit

// Below is an extension for any additional UIViewController funcs

extension UIViewController {
    
    // This func adds a child viewController and activates constraints for it's view on specified subview (viewForChild) or for the parent viewController's view itself.
    func add(_ controller: UIViewController, viewForChild: UIView?) {
        // Adds child viewController
        addChild(controller)
        
        // Checks for provided subview
        if let viewForChild = viewForChild {
            // adds childVC view to the subview
            viewForChild.addSubview(controller.view)
            
            // Deactivate autoresizingMaskIntoConstraints so that we can set our own constraints
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            
            // Activate our constraints
            NSLayoutConstraint.activate([
                controller.view.leadingAnchor.constraint(equalTo: viewForChild.leadingAnchor),
                controller.view.topAnchor.constraint(equalTo: viewForChild.topAnchor),
                controller.view.trailingAnchor.constraint(equalTo: viewForChild.trailingAnchor),
                controller.view.bottomAnchor.constraint(equalTo: viewForChild.bottomAnchor),
            ])
            
            // func that must be called when a childVC is added (after addChild or after transition, which in our case, involves setting constraints)
            controller.didMove(toParent: self)
        }
        // i.e. if no subview is provided
        else {
            // adds childVC to parentVC's view
            view.addSubview(controller.view)
            
            // Deactivate autoresizingMaskIntoConstraints so that we can set our own constraints
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            
            // Activate our constraints
            NSLayoutConstraint.activate([
                controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                controller.view.topAnchor.constraint(equalTo: view.topAnchor),
                controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
            
            // func that must be called when a childVC is added (after addChild or after transition, which in our case, involves setting constraints)
            controller.didMove(toParent: self)
        }
    }
    
    // Func to present an alert with a title and message
    func presentSimpleAlert(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(Constants.AlertComponents.heard)
        present(alert, animated: true)
    }
    
    /* Func to configure and present alert with options; in practice, this func could use a switch or if-statement in completion()
    to decide what action to perform based on user selection */
    func presentAlertWithOptions(title: String, message: String, options: String..., completion: @escaping (Int) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            alert.addAction(UIAlertAction(title: option, style: .default, handler: { _ in completion(index) }))
        }
        present(alert, animated: true)
    }
}
