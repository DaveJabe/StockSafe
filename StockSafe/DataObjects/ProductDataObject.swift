//
//  ProductDataObject.swift
//  Stocked.
//
//  Created by David Jabech on 6/22/21.
//

import Foundation
import FirebaseFirestoreSwift

struct Product: Codable, Identifiable {
    @DocumentID var id: String? = UUID().uuidString
    let name: String
    let locations: [String]
    let shelfLifeBegins: String?
    let maxShelfLife: Int
    let color: UIColor.Hex
    let userID: String
}
