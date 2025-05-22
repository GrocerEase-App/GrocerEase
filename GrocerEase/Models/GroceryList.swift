//
//  GroceryList.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/21/25.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class GroceryList: Identifiable {
    var id = UUID()
    var name: String = ""
    var location: CLLocationCoordinate2D?
    var address: String?
    var zipcode: String?
    var radius: Double = 5
    var maxStores: Int = 0
    var autoSelect: AutoSelect = AutoSelect.none
    @Relationship(deleteRule: .cascade, inverse: \GroceryItem.list) var items: [GroceryItem] = []
    @Relationship(deleteRule: .cascade, inverse: \GroceryStore.list) var stores: [GroceryStore] = []
    
    init() { }
    
    var invalidList: Bool {
        name == "" || location == nil || stores.isEmpty || !stores.contains(where: {$0.enabled})
    }
    
    func fetchStores() async throws {
        guard let location = self.location else {
            print("Tried to fetch stores before setting location")
            return
        }
        self.stores.removeAll()
        var newStores: [GroceryStore] = []
        for source in PriceSource.allCases {
            let scraper = source.scraper.shared
            newStores.append(contentsOf: try await scraper.getNearbyStores(latitude: location.latitude, longitude: location.longitude, radius: radius, list: self))
        }
        self.stores.append(contentsOf: newStores)
        self.stores.sort { $0.distance ?? 1000 < $1.distance ?? 1000 }
    }
}

extension GroceryList {
    static let sample: GroceryList = {
        let list = GroceryList()
        list.name = "Sample List"
        list.location = CLLocationCoordinate2D(latitude: 37.000212813403806, longitude: -122.06235820026123) // Baskin Auditorium
        list.zipcode = "95064"
        list.address = "1156 High St Santa Cruz, CA 95064"
        return list
    }()
}
