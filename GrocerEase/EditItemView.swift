//
//  ManualEntryView.swift
//  GrocerEase
//
//  Created by Arushi Tyagi on 4/26/25.
//
import SwiftUI

struct EditItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var groceryList: [GroceryItem]
    var existingItem: GroceryItem? = nil 
    var onSave: (() -> Void)? = nil
    
    @State private var itemName = ""
    @State private var quantity = ""
    @State private var price = ""
    @State private var store = ""
    
    var body: some View {
        
        Form {
            Section(header: Text("Item Details")) {
                TextField("Name", text: $itemName)
                TextField("Quantity", text: $quantity)
                TextField("Price", text: $price)
                    .keyboardType(.decimalPad)
                TextField("Store", text: $store)
            }
        }
        .navigationTitle(existingItem == nil ? "Add Item" : "Edit " + existingItem!.name)
        .toolbar {
            if existingItem != nil {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    if let priceValue = Double(price) {
                        if let existing = existingItem,
                           let index = groceryList.firstIndex(where: { $0.id == existing.id }) {
                            groceryList[index].name = itemName
                            groceryList[index].quantity = quantity
                            groceryList[index].price = priceValue
                            groceryList[index].store = store
                        } else {
                            let newItem = GroceryItem(name: itemName, quantity: quantity, price: priceValue, store: store)
                            groceryList.append(newItem)
                        }
                        onSave?()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let item = existingItem {
                itemName = item.name
                quantity = item.quantity
                price = String(item.price)
                store = item.store
            }
            
        }
    }
}
