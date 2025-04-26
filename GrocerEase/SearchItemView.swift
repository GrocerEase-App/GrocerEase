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

    var body: some View {
        NavigationView {
            VStack {
                Text("(Placeholder for API Search Results)")
                    .font(.headline)
                    .padding()
                Spacer()
            }
            .navigationTitle("New Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showManualEntry.toggle()
                    }) {
                        Image(systemName: "pencil")
                    }
                }
            }
            .sheet(isPresented: $showManualEntry) {
                ManualEntryView(groceryList: $groceryList, existingItem: nil) {
                    showManualEntry = false
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
