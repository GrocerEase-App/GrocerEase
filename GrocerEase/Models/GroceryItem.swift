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
    @Attribute(.unique) var id = UUID()
    var name: String
    var quantity: Double
    var timestamp: Date
    var isCompleted: Bool
    var list: GroceryList?
    var parent: GroceryItem?
    @Relationship(deleteRule: .noAction) var store: GroceryStore
    @Relationship(deleteRule: .cascade, inverse: \GroceryItem.parent)
    var trackedItems: [GroceryItem] = []

    // Item Info
    var url: URL?
    var imageUrl: URL?
    var brand: String?
    var searchRank: Int?

    // Pricing
    var price: Double?  // price per package or unit of the item (approx if sold by weight)
    var unitPrice: Double?  // price per unit of the item as described in unitString
    var originalPrice: Double?  // price when not on sale, if applicable
    var originalUnitPrice: Double?  // unit price when not on sale, if applicable
    var unitString: String?  // weight or volume unit of the item, assume each if nil
    var unitQuantity: Double?  // weight or volume of one package of this item
    var expiration: Date?  // date after which price is no longer valid
    var soldByWeight: Bool?  // TODO: change to enum (individual item, prepackaged, weighed at checkout)

    // Identifiers
    var upc: String?  // universal barcode for branded items
    var sku: String?  // store-specific product identifier
    var plu: String?  // non brand-specific item identifier

    // Additional Info
    var snap: Bool?  // EBT eligible
    var location: String?  // description of item location (such as aisle number)
    var department: String?  // TODO: change to enum
    var inStock: Bool?  // TODO: change to enum (num left in stock, almost gone, etc.)
    var max: Int?  // maximum purchase quantity

    /// Returns a unit object from Foundation's measurement API based on
    /// unitString
    var unit: Unit? {
        if let unitString = self.unitString {
            return Unit(symbol: unitString)
        } else {
            return nil
        }
    }

    /// Returns the date at which the price is no longer considered up to date,
    /// but provides a default value of one week in the future.
    var expirationDefault: Date {
        if let expiration = self.expiration {
            return expiration
        } else {
            return Calendar.current.date(
                byAdding: .day,
                value: 7,
                to: timestamp
            )!
        }
    }

    /// Initialize a GroceryItem
    ///
    /// - Parameters:
    ///     - name: String with the item's name.
    ///     - store: The store reference where the item is sold.
    init(name: String, store: GroceryStore) {
        self.name = name
        self.quantity = 1.0
        self.price = 1.0
        self.timestamp = .now
        self.isCompleted = false
        self.store = store
    }

    func save(to list: GroceryList? = nil) {
        if self.list == nil {
            self.list = list ?? self.store.list
        }
        try? modelContext?.save()
    }

    // TODO: Refresh price function
}

extension GroceryItem {
    static let samples: [GroceryItem] = [
        .sample
    ]

    static var sample: GroceryItem {
        let item = GroceryItem(
            name:
                "Lucky Charms Cereal Frosted Toasted Oat With Marshmallows - 10.5 Oz",
            store: .sample
        )
        item.upc = "000000000000"
        item.sku = "12345"
        item.plu = "1000"
        item.snap = true
        item.location = "Aisle 5"
        item.department = "Breakfast & Cereal"
        item.inStock = true
        item.imageUrl = URL(
            string: "https://images.albertsons-media.com/is/image/ABS/970125858"
        )!
        item.price = 4.20
        item.unitPrice = 0.231
        item.originalPrice = 4.20
        item.originalUnitPrice = 0.231
        item.soldByWeight = false
        item.unitString = "OZ"
        return item
    }
}
