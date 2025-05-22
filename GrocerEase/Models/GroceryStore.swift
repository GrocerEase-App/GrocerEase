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
    
    var location: CLLocationCoordinate2D? // coordinates of store if available
    var address: String? // address of store if available
    var distance: Double? // distance from list.location to self.location
    
    var source: PriceSource // determines which scraper to use
    var enabled: Bool = true // determines if store will be searched for new items
    
    var list: GroceryList? // the list this store belongs to
    
    init(storeNum: String, brand: String, location: CLLocationCoordinate2D? = nil, address: String? = nil, source: PriceSource, list: GroceryList) {
        self.storeNum = storeNum
        self.brand = brand
        self.location = location
        self.address = address
        self.source = source
        self.list = list
        
        self.distance = location?.distanceInMiles(to: self.list!.location)
        
        if location == nil, let adr = self.address {
            Task {
                self.location = await CLLocationCoordinate2D(address: adr)
                self.distance = self.location?.distanceInMiles(to: self.list!.location)
                list.sortStores()
            }
        }
    }
    
    var scraper: Scraper {
        source.scraper.shared
    }
    
    func search(for query: String) async throws -> [GroceryItem] {
        return try await scraper.searchItems(query: query, store: self)
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
        source: .albertsons,
        list: .sample
    )
}
