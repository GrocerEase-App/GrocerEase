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
    var storeNum: String
    var brand: String
    var location: CLLocationCoordinate2D?
    var address: String?
    var source: PriceSource
    var enabled: Bool = true
    var list: GroceryList?
    var distance: Double?
    
    init(storeNum: String, brand: String, location: CLLocationCoordinate2D? = nil, address: String? = nil, source: PriceSource, list: GroceryList) {
        self.storeNum = storeNum
        self.brand = brand
        self.address = address
        self.location = location
        self.source = source
        self.list = list
        self.distance = location?.distanceInMiles(to: self.list!.location)
        if location == nil, let adr = self.address {
            Task {
                self.location = await CLLocationCoordinate2D(address: adr)
                self.distance = self.location?.distanceInMiles(to: self.list!.location)
            }
        }
    }
    
    var scraper: Scraper {
        source.scraper.shared
    }
    
    func search(for query: String) async throws -> [GroceryItem] {
        // Object oriented programming at its finest :)
        return try await scraper.searchItems(query: query, store: self)
    }
    
    static func == (lhs: GroceryStore, rhs: GroceryStore) -> Bool {
        lhs.id == rhs.id && lhs.brand == rhs.brand
    }
}
