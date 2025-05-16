//
//  GroceryStore.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/13/25.
//

import Foundation
import SwiftData

@Model
final class GroceryStore {
    var id: String
    var brand: String
    var latitude: Double?
    var longitude: Double?
    var address: String?
    var source: PriceSource
    
    init(id: String, brand: String, latitude: Double? = nil, longitude: Double? = nil, address: String? = nil, source: PriceSource) {
        self.id = id
        self.brand = brand
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.source = source
    }
    
    func search(for query: String) async throws -> [GroceryItem] {
        // Object oriented programming at its finest :)
        return try await source.scraper.shared.searchItems(query: query, storeId: id)
    }
}
