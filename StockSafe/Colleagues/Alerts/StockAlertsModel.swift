//
//  StockAlertsModel.swift
//  StockSafe
//
//  Created by David Jabech on 7/12/21.
//

import UIKit

class StockAlerts: ColleagueProtocol {
    public weak var mediator: MediatorProtocol?
    
    init() {
        configureAlerts()
    }
        
    private let heard = UIAlertAction(title: "Heard on that.",
                                      style: .default,
                                      handler: nil)
    
    public let selectCasesAlert = UIAlertController(title: "Please select cases to stock",
                                                    message: nil,
                                                    preferredStyle: .alert)
    
    public let sameDestinationAlert = UIAlertController(title: "Please select a different destination",
                                                        message: "The selected destination cannot be the same as the current location.",
                                                        preferredStyle: .alert)

    func setMediator(mediator: MediatorProtocol) {
        self.mediator = mediator
    }
    
    private func configureAlerts() {
        selectCasesAlert.addAction(heard)
        sameDestinationAlert.addAction(heard)

    }
    
    public func configureMCAlert(destination: String) -> UIAlertController {
        let maxCapAlert = UIAlertController(title: nil,
                                                   message: nil ,
                                                   preferredStyle: .alert)
        maxCapAlert.title = "\(destination) doesn't have enough space"
        maxCapAlert.message = "Please remove cases from the \(destination) or stock fewer cases."
        maxCapAlert.addAction(heard)
        return maxCapAlert
    }
    
    public func configureSLAlert(cases: [Case], sl_String: String) -> UIAlertController {
        let shelfLifeAlert = UIAlertController(title: nil,
                                                            message: "Would you like to restart their shelf lives?",
                                                            preferredStyle: .alert)
        shelfLifeAlert.title = "Cases \(sl_String) already have shelf lives"
        shelfLifeAlert.addAction(UIAlertAction(title: "Stock cases and restart shelf lives",
                                                     style: .default,
                                                     handler: { [self] _ in mediator?.relayInfo(sender: self, info: (ShelfLifeParameter.replace, cases)) } ))
        shelfLifeAlert.addAction(UIAlertAction(title: "Stock cases but don't restart shelf lives",
                                                     style: .default,
                                                     handler: { [self] _ in mediator?.relayInfo(sender: self, info: (ShelfLifeParameter.doNotReplace, cases)) } ))
        shelfLifeAlert.addAction(UIAlertAction(title: "Don't stock cases",
                                                     style: .default,
                                                     handler: nil))
        return shelfLifeAlert
    }
    
}
