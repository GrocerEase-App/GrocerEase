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
    var quantity: Double
    var timestamp: Date
    var isCompleted: Bool
    var list: GroceryList?
    var parent: GroceryItem?
    @Relationship(deleteRule: .noAction) var store: GroceryStore
    @Relationship(deleteRule: .cascade, inverse: \GroceryItem.parent) var trackedItems: [GroceryItem] = []
    
    var upc: String? // universal barcode for branded items
    var sku: String? // store-specific product identifier
    var plu: String? // non brand-specific item identifier
    var snap: Bool? // EBT eligible
    var location: String? // description of item location (such as aisle number)
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
    
    init(name: String, store: GroceryStore, listRef: GroceryList? = nil) {
        self.name = name
        self.quantity = 1.0
        self.price = 1.0
        self.timestamp = .now
        self.isCompleted = false
        self.store = store
        self.list = listRef
    }
}

extension GroceryItem {
    static let samples: [GroceryItem] = [
//        .sample
    ]
    
//    static var sample: GroceryItem {
//        let item = GroceryItem(name: "Lucky Charms Cereal Frosted Toasted Oat With Marshmallows - 10.5 Oz", storeRef: GroceryStore(storeNum: "123", brand: "Safeway", address: "123 Main St", source: .albertsons))
//        item.upc = "000000000000"
//        item.sku = "12345"
//        item.plu = "1000"
//        item.snap = true
//        item.locationShort = "Aisle 5"
//        item.department = "Breakfast & Cereal"
//        item.inStock = true
//        item.imageUrl = URL(string: "https://images.albertsons-media.com/is/image/ABS/970125858")!
//        item.price = 4.20
//        item.unitPrice = 0.231
//        item.originalPrice = 4.20
//        item.originalUnitPrice = 0.231
//        item.soldByWeight = false
//        item.unitString = "OZ"
//        return item
//    }
}
