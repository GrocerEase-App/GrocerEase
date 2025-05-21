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
    @Relationship(deleteRule: .noAction) var storeRef: GroceryStore
    @Relationship(deleteRule: .cascade) var subItems: [GroceryItem] = []
    
    var upc: String? // universal barcode for branded items
    var sku: String? // store-specific product identifier
    var plu: String? // non brand-specific item identifier
    var snap: Bool? // EBT eligible
    var locationShort: String? // short description of item location
    var locationLong: String? // long description of item location
    var inStock: Bool?
    var price: Double? // if sold by weight, this value should be approx price per package or item (if applicable)
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
    var weight: Double?
    var searchRank: Int?
    
    var unit: Unit? {
        if let unitString = self.unitString {
            return Unit(symbol: unitString)
        } else {
            return nil
        }
    }
    
    var expirationDefault: Date {
        if let expiration = self.expiration {
            return expiration
        } else {
            return Calendar.current.date(byAdding: .day, value: 7, to: timestamp)!
        }
    }
    
    init(name: String, storeRef: GroceryStore) {
        self.name = name
        self.quantity = 1.0
        self.price = 1.0
        self.store = "Default"
        self.timestamp = .now
        self.isCompleted = false
        self.storeRef = storeRef
    }
}

extension GroceryItem {
    static let samples: [GroceryItem] = [
        .sample
    ]
    
    static var sample: GroceryItem {
        let item = GroceryItem(name: "Lucky Charms Cereal Frosted Toasted Oat With Marshmallows - 10.5 Oz", storeRef: GroceryStore(id: "123", brand: "Safeway", address: "123 Main St", source: .albertsons))
        item.upc = "000000000000"
        item.sku = "12345"
        item.plu = "1000"
        item.snap = true
        item.locationShort = "Aisle 5"
        item.department = "Breakfast & Cereal"
        item.inStock = true
        item.imageUrl = URL(string: "https://images.albertsons-media.com/is/image/ABS/970125858")!
        item.price = 4.20
        item.unitPrice = 0.231
        item.originalPrice = 4.20
        item.originalUnitPrice = 0.231
        item.soldByWeight = false
        item.unitString = "OZ"
        return item
    }
}
