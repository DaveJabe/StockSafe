//
//  ColleagueProtocol.swift
//  StockSafe
//
//  Created by David Jabech on 7/13/21.
//

import UIKit

enum Event {
    case configuredProducts(products: [Product])
    
    case configuredLocations(locations: [Location])
    
    case selectionChanged(type: SelectionViewType)
    
    case replaceCases
}

protocol ColleagueProtocol: AnyObject {
    var mediator: MediatorProtocol? { get }
    
    func setMediator(mediator: MediatorProtocol)
}


