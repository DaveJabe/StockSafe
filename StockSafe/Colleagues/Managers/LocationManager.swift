//
//  LocationManager.swift
//  StockSafe
//
//  Created by David Jabech on 7/14/21.
//

import Foundation
import Firebase
import FirebaseFirestore

// LocationManager - this class is responsible for managing a User's locations (reading and writing to Firestore)
class LocationManager: ColleagueProtocol {
    
    // `db` variable used to interact with Firestore
    public var db: Firestore!
    
    // Mediator protocol for communicating events to the mediator (view controller)
    public weak var mediator: MediatorProtocol?
    
    // Array to hold all locations retrieved from Firestore after 'configureProducts()'
    public var locations = [Location]()
    
    // Intializer that sets up Firestore and configures Products and Locations
    init() {
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
    
        configureLocations()
    }
    
    // Function to be called by mediator to set itself as the mediator for this class
    public func setMediator(mediator: MediatorProtocol) {
        self.mediator = mediator
    }
    
    // function to retrieve locations from Firestore, notifys mediator when complete
    public func configureLocations() {
        locations = []
        db.collection("Locations")
            .whereField("userID", isEqualTo: userIDkey)
            .getDocuments() { [self] querySnapshot, error in
                if error != nil {
                    print("Error in ProductManager - configureLocations(): \(String(describing: error))")
                }
                else {
                    let group = DispatchGroup()
                    for document in querySnapshot!.documents {
                        group.enter()
                        let location = try? document.data(as: Location.self)
                        if let location = location {
                            locations.append(location)
                        }
                        group.leave()
                    }
                    group.notify(queue: DispatchQueue.main) {
                        archiveCheck()
                        mediator?.notify(sender: self, event: .configuredLocations(locations: locations))
                    }
                }
            }
    }
    
    // Filters locations and returns an array of locations respective to the Product passed in
    public func filterAndSortLocations(by product: Product, includeArchive: Bool) -> [Location] {
        var filteredLocations = [Location]()
        let locationRefs = product.locations.sorted(by: { $0.key < $1.key })
        if locationRefs.count != 0 {
            for index in locationRefs.indices {
                filteredLocations.append(locations.first(where: { $0.name == locationRefs[index].value })!)
            }
            if !includeArchive {
                filteredLocations.removeLast()
            }
        }
        return filteredLocations
    }
    
    // Ensures that the archive location is present among a Users Locations
    // This is relevant to new Users or Users who have deleted all of their locations (essentially, Archive should never be deleted)
    // This should be used at account creation and account log in, AFTER configureLocations()
    public func archiveCheck() {
        if !locations.contains(where: { $0.name == "Archive" }) {
            let _ = try? db.collection("Locations").addDocument(from: ArchiveTemplate()) { error in
                if error != nil {
                    print("Error in archiveCheck: \(String(describing: error))")
                }
            }
        }
    }
    
    // Function for User to add new location
    public func addNewLocation(name: String, color: String, completion: () -> Void) {
        do {
            let _ = try db.collection("Locations").addDocument(from: Location(name: name, products: nil, color: color, userID: userIDkey))
        }
        catch {
            print("Error writing new location to 'Locations' in Firestore")
        }
    }
    
    public func getLocationStrings(for type: SelectionViewType?) -> [String] {
        print(locations)
        var locationStrings: [String] = []
        for location in locations {
            locationStrings.append(location.name)
        }
        if !locationStrings.isEmpty {
            if type == .locations {
                locationStrings.removeLast()
            }
        }
        return locationStrings
    }
}
