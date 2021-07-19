//
//  MediatorProtocol.swift
//  StockSafe
//
//  Created by David Jabech on 7/13/21.
//

import UIKit

protocol MediatorProtocol: AnyObject {
    func notify(sender: ColleagueProtocol, event: Event)
    
    func relayInfo(sender: ColleagueProtocol, info: Any)
}

