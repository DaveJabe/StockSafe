//
//  ProductDataObject.swift
//  Stocked.
//
//  Created by David Jabech on 6/22/21.
//

import Foundation
import FirebaseFirestoreSwift

// Products are categories for Cases, which can be stored in Locations
// Products delineate key features for cases: the locations they can be stored to, at which location their shelflife begins, and the length of their shelflife (in hours)

struct Product: Identifiable, Codable, Hashable {
    static func == (lhs: Product, rhs: Product) -> Bool {
        return false
    }
    
    // Uses FirebaseFirestoreSwift attribute '@DocumentID' to set a unique identifier for the Product document when it's written to Firestore
    @DocumentID var id: String? = UUID().uuidString
    
    // Product name (cases use this as a reference)
    let name: String
    
    // This is all of the cases of a product, regardless of where they are located
    let cases: [Case]?
    
    // This references the locations at which a product may be stored
    let locations: [Int:String]
    
    // Represents the length and starting point of a given product's shelflife
    let shelfLife: ShelfLife?
    
    // An array of case limits for a given product
    // Optional because limits are an optional feature for products/locations
    var limits: [Limit]?
    
    // The color that can be used to identify a product (Note: this is intended for Users and is NOT a unique id; e.g. products may share a color)
    let color: String
    
    // Reference to the user this location belongs to
    let userID: String
}

struct Limit: Codable, Hashable {
    // Reference to the location that this struct represents a limit for
    let locationName: String
    
    // Integer representing the current number of cases of a given product in a given location
    let currentCount: Int
    
    // Integer representing the limit to how many cases of a given product can be stored in a given location
    let limit: Int
}

struct ShelfLife: Codable, Hashable {
    // The amount of time a product can be held (after its shelflife begins) ***in hours
    // Optional because a product may not have a shelflife
    let shelfLife: Int?
    
    // This is a reference to the location at which a products shelflife begins
    // Optional because a product may not have a shelflife
    let startingPoint: String?
}
