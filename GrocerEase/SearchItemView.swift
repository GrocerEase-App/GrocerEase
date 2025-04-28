//
//  SearchItemView.swift
//  GrocerEase
//
//  Created by Arushi Tyagi on 4/26/25.
//

import SwiftUI

struct SearchItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var groceryList: [GroceryItem]
    @State private var showManualEntry = false
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            
            List(["Sponsored Products"], id: \.self) { item in
                Text(item)
            }
            .searchable(text: $searchText, prompt: "Search")
            .navigationTitle("New Item")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        EditItemView(groceryList: $groceryList, existingItem: nil) {
                            showManualEntry = false
                        }
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
