//
//  Alerts.swift
//  StockSafe
//
//  Created by David Jabech on 7/10/21.
//

import UIKit

class NewCaseAlerts: ColleagueProtocol {
    
    init() {
        configureAlerts()
    }
    
    public weak var mediator: MediatorProtocol?
    
    private let no = UIAlertAction(title: "No",
                                   style: .default,
                                   handler: nil)
        
    private let heard = UIAlertAction(title: "Heard on that.",
                                      style: .default,
                                      handler: nil)
    
    public let missingCaseNumAlert = UIAlertController(title: "Please enter a case number",
                                                  message: "",
                                                  preferredStyle: .alert)
    
    public let missingCaseRangeAlert = UIAlertController(title: "Please enter a valid case range",
                                                         message: "",
                                                         preferredStyle: .alert)
    
    public let rangeInvalidAlert = UIAlertController(title: "Invalid range",
                                                     message: "The first case should be a smaller number than the last case.",
                                                     preferredStyle: .alert)
    
    public func setMediator(mediator: MediatorProtocol) {
        self.mediator = mediator
    }
    
    private func configureAlerts() {
        
        missingCaseNumAlert.addAction(heard)
        
        missingCaseRangeAlert.addAction(heard)
        
        rangeInvalidAlert.addAction(heard)
    }
    
    public func configureCAEAlert(aec_string: String) -> UIAlertController {
        let caseAlreadyExistsAlert = UIAlertController(title: nil,
                                                        message: "Would you like to archive and replace this case?",
                                                        preferredStyle: .alert)
        caseAlreadyExistsAlert.title = aec_string
        caseAlreadyExistsAlert.addAction(UIAlertAction(title: "Archive and replace that case",
                                                       style: .default,
                                                       handler: { [self] _ in mediator?.notify(sender: self, event: .replaceCases) } ))
        caseAlreadyExistsAlert.addAction(no)
        return caseAlreadyExistsAlert
        }
    
    public func configureMCAEAlert(aec_string: String) -> UIAlertController {
        let multipleCasesAlreadyExistAlert = UIAlertController(title: nil,
                                                               message: "Would you like to archive and replace these cases?",
                                                               preferredStyle: .alert)
        multipleCasesAlreadyExistAlert.title = aec_string
        multipleCasesAlreadyExistAlert.addAction(UIAlertAction(title: "Archive and replace those cases",
                                                  style: .default,
                                                  handler: { [self] _ in mediator?.notify(sender: self, event: .replaceCases) } ))
        multipleCasesAlreadyExistAlert.addAction(no)
        return multipleCasesAlreadyExistAlert
        }
}


