//
//  CaseDataObject.swift
//  Stocked.
//
//  Created by David Jabech on 6/1/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Case: Identifiable, Codable, Hashable, Comparable {
    // No two cases are equal
    static func == (lhs: Case, rhs: Case) -> Bool {
        return false
    }
    
    // Cases can be compared by their case number
    static func < (lhs: Case, rhs: Case) -> Bool {
        return lhs.caseNumber < rhs.caseNumber
    }
    
    @DocumentID var id: String? = UUID().uuidString
    let product: String  // Reference to this case's product
    let location: String // Reference to the location this case belongs to
    let caseNumber: Int // The number value for this case (Note: this is the ONLY distinguishing attribute that Users have access to; it caps at 100)
    let entryDate: Timestamp // The date that the case was added (to Firestore)
    var shelfLife: Timestamp? // The timeline
    let userID: String // Reference to the user this location belongs to
}
