//
//  CaseDataObject.swift
//  Stocked.
//
//  Created by David Jabech on 6/1/21.
//

import Foundation
import FirebaseFirestoreSwift

struct Case: Identifiable, Codable, Hashable {
    @DocumentID var id: String? = UUID().uuidString
    let product: String
    let caseNumber: Int
    var location: String
    let timestamp: Date
    var shelfLife: Date?
    var breadingStamp: Date?
    let userID: String
}
