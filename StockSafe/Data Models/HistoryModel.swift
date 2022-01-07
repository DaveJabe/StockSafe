//
//  StockingHistory.swift
//  StockSafe
//
//  Created by David Jabech on 8/13/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

// History functionality has not yet been implemented

enum HistoryType {
    static let cases = "cases"
    static let products = "products"
    static let locations = "locations"
}

enum HistoryOption {
    static let added = "added"
    
    static let stocked = "stocked"
    
    static let grouped = "grouped"
    
    static let archived = "archived"
    
    static let deleted = "deleted"
}

struct History: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    
    let time: Timestamp
    
    let type: String
    
    let name: String
    
    let option: String
    
    let quantity: Int?
}
