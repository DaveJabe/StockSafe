//
//  ProductManager.swift
//  StockSafe
//
//  Created by David Jabech on 7/10/21.
//

import UIKit

class ProductManager: LocationManager {
    
    // Array to hold all products retrieved from Firestore after 'configureProducts()'
    public var products = [Product]()
    
    // function to retrieve products from Firestore, notifys mediator when complete
    public func configureProducts() {
        products = []
        db.collection("products")
            .whereField("userID", isEqualTo: userIDkey)
            .getDocuments() { [self] querySnapshot, err in
                if err != nil {
                    print("Error in configureProducts: \(String(describing: err))")
                }
                else {
                    guard let documents = querySnapshot?.documents else {
                        print("No documents found...")
                        return
                    }
                    let group = DispatchGroup()
                    for document in documents {
                        group.enter()
                        let product = try? document.data(as: Product.self)
                        products.append(product!)
                        group.leave()
                    }
                    group.notify(queue: DispatchQueue.main) {
                        mediator?.notify(sender: self, event: .configuredProducts(products: products))
                    }
                }
            }
    }
    
    public func newShelfLife(shelfLife: Int, hoursOrDays: String, startingPoint: [Int:String]) -> ShelfLife {
        var sl: Int
        if hoursOrDays != "Hours" || hoursOrDays != "Hour" {
            sl = 24 * shelfLife
        }
        else {
            sl = shelfLife
        }
        return ShelfLife(shelfLife: sl, startingPoint: startingPoint)
    }
    
    public func addNewProduct(name: String, locations: [Int:String], shelfLife: ShelfLife?, color: String, completion: () -> Void) {
        do {
            let _ = try db.collection("products").addDocument(from: Product(name: name, cases: nil, locations: locations, shelfLife: shelfLife, color: color, userID: userIDkey))
            print("New Product successfully written to Firestore!")
        }
        catch {
            print("Error writing Product to Firestore...")
        }
    }
}



