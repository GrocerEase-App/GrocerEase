//
//  ManualEntryView.swift
//  GrocerEase
//
//  Created by Arushi Tyagi on 4/26/25.
//
import SwiftUI

struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
//    @Environment(\.isPresented) var isPresented
    @Binding var groceryList: [GroceryItem]
    var existingItem: GroceryItem? = nil
    var onSave: (() -> Void)? = nil
    
    @State private var itemName = ""
    @State private var quantity: Double = 0.0
    @State private var price: Double = 0.0
    @State private var store = ""
    
    var body: some View {
        
        Form {
            Section(header: Text("Item Details")) {
                TextField("Name", text: $itemName)
                TextField("Quantity", value: $quantity, format: .number)
                TextField("Price", value: $price, format: .number)
                TextField("Store", text: $store)
            }
        }
        .navigationTitle(existingItem == nil ? "Add Item" : "Edit " + existingItem!.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if let existing = existingItem,
                       let index = groceryList.firstIndex(where: { $0.id == existing.id }) {
                        groceryList[index].name = itemName
                        groceryList[index].quantity = quantity
                        groceryList[index].price = price
                        groceryList[index].store = store
                    } else {
                        let newItem = GroceryItem(name: itemName, quantity: quantity, price: price, store: store)
                        groceryList.append(newItem)
                    }
                    onSave?()
                    dismiss()
                }
            }
        }
        .onAppear {
            if let item = existingItem {
                itemName = item.name
                quantity = item.quantity
                price = item.price
                store = item.store
            }
            
        }
    }
}
