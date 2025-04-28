//
//  GroceryItem.swift
//  GrocerEase
//
//  Created by Arushi Tyagi on 4/26/25.
//

import Foundation

struct GroceryItem: Identifiable {
    let id = UUID()
    var name: String
    var quantity: String
    var price: Double
    var store: String
    var isCompleted: Bool = false
    var dateAdded = Date.now
}

extension GroceryItem {
    static let samples: [GroceryItem] = [
        .init(name: "Apples", quantity: "3", price: 2.5, store: "Safeway"),
        .init(name: "Bananas", quantity: "5", price: 1.8, store: "Trader Joe's"),
        .init(name: "Oranges", quantity: "4", price: 3.0, store: "Publix"),
    ]
}
