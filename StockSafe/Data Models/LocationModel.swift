//
//  LocationModel.swift
//  StockSafe
//
//  Created by David Jabech on 7/14/21.
//

import Foundation
import FirebaseFirestoreSwift

// Locations are where Cases of Products are stored
struct Location: Identifiable, Codable, Hashable {
    @DocumentID var id: String? = UUID().uuidString
    let name: String // The name of the location (used by products to reference their locations)
    let products: [Product]?  // Array of all the products that can be stored at a given location (optional because it is possible to have no products)
    let color: String // The hexadecimal value for the color that can be used to identify a product (Note: this is intended for Users and is NOT a unique id; e.g. products may share a color)
    let userID: String // Reference to the user this location belongs to
}

struct ArchiveTemplate: Identifiable, Encodable, Hashable {
    @DocumentID var id: String? = UUID().uuidString
    let name: String = "Archive"
    let products: [Product] = []
    let color: String = "D32F2F"
    var userID: String
}
