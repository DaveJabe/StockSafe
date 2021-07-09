//
//  StockingData.swift
//  Stocked.
//
//  Created by David Jabech on 6/4/21.
//

import Foundation
import FirebaseFirestoreSwift

struct StockingData: Codable, Identifiable {
    @DocumentID var id: String? = UUID().uuidString
    let date: Date
    var history: [StockingInstance]
    let userID: String
}

struct StockingInstance: Codable {
    let cases: [Case]
    let location: String?
    let destination: String
    let time: Date
}
