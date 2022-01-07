//
//  ColleagueProtocol.swift
//  StockSafe
//
//  Created by David Jabech on 7/13/21.
//

import UIKit


/*  The following enumeration encompasses any events for which information/data should be communicated between two colleague classes. MediatorProtocol mediates this communication between colleagues
 thanks to ColleagueProtocol, allowing multiple Colleagues (i.e. classes that inherit ColleagueProtocol) to send information using the same function ('func notify()' in the MediatorProtocol). The specific action for the
 mediator (i.e. class that inherits MediatorProtocol) to perform is indicated by the event passed as a parameter through 'func notify()'. */

enum Event {
    // Event for when products have been configured by the ProductManager (could work for CaseManager as well, since it inherits from ProductManager)
    case configuredProducts(products: [Product])
    
    // Event for when locations have been configured by the LocationManager (could work for either CaseManager or ProductManager as well, since they both inherit from LocationsManager)
    case configuredLocations(locations: [Location])
    
    // Event for when a SelectionView selection has changed
    case selectionChanged(type: SelectionViewType)
    
    // Event for when a ToolBarSelection has Changed
    case toolbarSelection(buttonTag: Int)
    
    // Event for when a SubmenuSelection has occured
    case submenuSelection(buttonTag: Int)
    
    // Event for when the done button on the submenu has been selected (either to add or stock cases)
    case doneButtonSelected(option: SubmenuOption)
    
    // Event for undoing stocked or added cases
    case undo
    
    // Event for redoing stocked or added cases
    case redo
    
    // Event for when the user would like to sort cases
    case sortCases(parameter: CaseSortParameter)
    
    // Event for when the user would like to delete cases
    case deleteCases
    
    // Event for when the user has selected a new ColorTheme
    case newThemeSelection
    
    // Event to make new history (occurs when ever stocking or adding cases, products, or locations)
    case newHistory
}

// ColleagueProtocol is a crucial component to the Mediator Design Pattern; this protocol faciliates communication from a Colleague (i.e. class that inherits ColleagueProtocol) to a Mediator (i.e. class that inherits MediatorProtocol). The Mediator will most likely use the communicated information/data to execute code from another Colleague (hence, 'mediating' communication between Colleagues).
protocol ColleagueProtocol: AnyObject {
    // mediator variable to be set (always a view controller)
    var mediator: MediatorProtocol? { get }
    
    // func to set the mediator of a Colleague (e.g. 'colleague'.setMediator(self))
    func setMediator(mediator: MediatorProtocol)
}


