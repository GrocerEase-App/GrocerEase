//
//  Item.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 4/21/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var name: String
    var quantity: Int
    var price: Double
    var store: String
    var timestamp: Date
    
    init(name: String, quantity: Int = 1, price: Double = 0.0, store: String = "", timestamp: Date = .now) {
        self.name = name
        self.quantity = quantity
        self.price = price
        self.store = store
        self.timestamp = timestamp
    }
}
