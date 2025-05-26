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
    @Attribute(.unique) var id = UUID()
    var name: String = ""
    var location: CLLocationCoordinate2D?
    var address: String?
    var zipcode: String?
    var radius: Double = 5
    var maxStores: Int = 0
    var autoSelect: AutoSelect = AutoSelect.none
    var showCompleted: Bool = false
    @Relationship(deleteRule: .cascade, inverse: \GroceryItem.list) var items: [GroceryItem] = []
    @Relationship(deleteRule: .cascade, inverse: \GroceryStore.list) var stores: [GroceryStore] = []
    
    init() { }
    
    func sortStores() {
        self.stores.sort { $0.distance ?? .greatestFiniteMagnitude < $1.distance ?? .greatestFiniteMagnitude }
    }
    
    func save() {
        modelContext?.insert(self)
        try? modelContext?.save()
    }
}

extension GroceryList {
    static let sample: GroceryList = {
        let list = GroceryList()
        list.name = "Sample List"
        list.location = CLLocationCoordinate2D(latitude: 37.000212813403806, longitude: -122.06235820026123) // Baskin Auditorium
        list.zipcode = "95064"
        list.address = "1156 High St Santa Cruz, CA 95064"
        list.items.append(GroceryItem.sample)
        list.stores.append(.sample)
        return list
    }()
}
