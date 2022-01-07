//
//  MediatorProtocol.swift
//  StockSafe
//
//  Created by David Jabech on 7/13/21.
//

import UIKit

/* The Mediator protocol helps the Mediator (i.e. class that inherits this protocol) mediate the communication of information between two Colleagues (i.e. classes that inherit the ColleagueProtocol). This protocol is declared as a delegate by the Colleagues, giving them access to `func notify(sender: ColleagueProtocol, event: Event).` This allows the Colleague to communicate an event to the Mediator, which executes respective code for that event (typically, it executes code that communicates the event to another Colleague). */

protocol MediatorProtocol: AnyObject {
    func notify(sender: ColleagueProtocol, event: Event)
}

