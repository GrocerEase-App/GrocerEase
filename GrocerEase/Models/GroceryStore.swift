//
//  GroceryStore.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/13/25.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class GroceryStore: Equatable {
    var id = UUID()
    var storeNum: String // store identifier
    var brand: String // store brand name
    var sortOrder: Int = 0 // order within list
    
    var location: CLLocationCoordinate2D? // coordinates of store if available
    var address: String? // address of store if available
    var distance: Double? // distance from list.location to self.location
    
    var source: PriceSource // determines which scraper to use
    var enabled: Bool = true // determines if store will be searched for new items
    
    var list: GroceryList? // the list this store belongs to
    
    init(storeNum: String, brand: String, location: CLLocationCoordinate2D? = nil, address: String? = nil, source: PriceSource) {
        self.storeNum = storeNum
        self.brand = brand
        self.location = location
        self.address = address
        self.source = source
    }
    
    func setLocation() async {
        if self.location == nil, let adr = self.address {
            self.location = await CLLocationCoordinate2D(address: adr)
        }
    }
    
    func setDistance(from origin: CLLocationCoordinate2D) {
        if let location = self.location {
            self.distance = origin.distanceInMiles(to: location)
        }
    }
    
    var scraper: Scraper {
        source.scraper.shared
    }
    
    func search(for query: String) async throws -> [GroceryItem] {
        return try await scraper.search(query, at: self)
    }
    
    static func == (lhs: GroceryStore, rhs: GroceryStore) -> Bool {
        lhs.id == rhs.id && lhs.brand == rhs.brand
    }
}

extension GroceryStore {
    static let sample: GroceryStore = .init(
        storeNum: "2607",
        brand: "Safeway",
        location: CLLocationCoordinate2D(latitude: 36.9821234, longitude: -122.0074933), // Safeway on Mission St
        address: "117 Morrissey Blvd, Santa Cruz, CA 95062",
        source: .albertsons
    )
}
