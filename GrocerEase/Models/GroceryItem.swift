//
//  GroceryItem.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 4/21/25.
//

import Foundation
import SwiftData

@Model
final class GroceryItem: Identifiable {
    var id = UUID()
    var name: String
    var quantity: Double // TODO: change to Double
    var timestamp: Date
    var isCompleted: Bool
    var store: String // TODO: change to GroceryStore reference
    
    var upc: String? // universal barcode for branded items
    var sku: String? // store-specific product identifier
    var plu: String? // non brand-specific item identifier
    var snap: Bool? // EBT eligible
    var locationShort: String? // short description of item location
    var locationLong: String? // long description of item location
    var inStock: Bool?
    var price: Double
    var unitPrice: Double?
    var originalPrice: Double? // price when not on sale, if applicable
    var originalUnitPrice: Double?
    var unitString: String? // assume each if nil
    var max: Int? // maximum purchase quantity
    var imageUrl: URL?
    var department: String? // TODO: change to enum
    var soldByWeight: Bool?
    var expiration: Date? // date after which price is no longer valid,
    var url: URL?
    var brand: String?
    var equivalentItems: [GroceryItem]?
    
    var unit: Unit? {
        if let unitString = self.unitString {
            return Unit(symbol: unitString)
        } else {
            return nil
        }
    }
    
    init(name: String, quantity: Double = 0.0, price: Double = 0.0, store: String = "") {
        self.name = name
        self.quantity = quantity
        self.price = price
        self.store = store
        self.timestamp = .now
        self.isCompleted = false
        self.expiration = Calendar.current.date(byAdding: .day, value: 7, to: Date())
    }
}

extension GroceryItem {
    static let samples: [GroceryItem] = [
        .init(name: "Apples", quantity: 3, price: 2.5, store: "Safeway"),
        .init(name: "Bananas", quantity: 5, price: 1.8, store: "Trader Joe's"),
        .init(name: "Oranges", quantity: 4, price: 3.0, store: "Publix"),
    ]
}
