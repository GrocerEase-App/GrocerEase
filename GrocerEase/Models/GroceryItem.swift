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
    var quantity: String
    var price: Double
    var store: String
    var timestamp: Date
    var isCompleted: Bool
    var imageUrl: String?
    
    init(name: String, quantity: String = "", price: Double = 0.0, store: String = "", timestamp: Date = .now, isCompleted: Bool = false, imageUrl: String? = nil) {
        self.name = name
        self.quantity = quantity
        self.price = price
        self.store = store
        self.timestamp = timestamp
        self.isCompleted = isCompleted
        self.imageUrl = imageUrl
    }
}

extension GroceryItem {
    static let samples: [GroceryItem] = [
        .init(name: "Apples", quantity: "3", price: 2.5, store: "Safeway"),
        .init(name: "Bananas", quantity: "5", price: 1.8, store: "Trader Joe's"),
        .init(name: "Oranges", quantity: "4", price: 3.0, store: "Publix"),
    ]
}
