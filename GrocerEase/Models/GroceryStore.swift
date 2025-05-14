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
    
    init(id: String, brand: String, latitude: Double? = nil, longitude: Double? = nil, address: String? = nil) {
        self.id = id
        self.brand = brand
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
}
