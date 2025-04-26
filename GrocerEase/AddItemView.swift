//
//  AddItemView.swift
//  GrocerEase
//
//  Created by Arushi Tyagi on 4/22/25.
//


import SwiftUI

struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var groceryList: [GroceryItem]
    @State private var itemName = ""
    @State private var quantity = ""
    @State private var price = ""
    @State private var store = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Name", text: $itemName)
                    TextField("Quantity", text: $quantity)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Store", text: $store)
                }
            }
            .navigationTitle("New Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if let priceValue = Double(price) {
                            let newItem = GroceryItem(name: itemName, quantity: quantity, price: priceValue, store: store)
                            groceryList.append(newItem)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
}
