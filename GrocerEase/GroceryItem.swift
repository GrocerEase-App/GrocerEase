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
}
