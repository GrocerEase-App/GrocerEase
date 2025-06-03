//
//  StoreRowView.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/29/25.
//

import SwiftUI

/// Displays a list row for a single GroceryStore.
///
/// Provides a toggle to enable or disable the store and a button to view the
/// store in Apple Maps or Google Maps.
///
/// - Parameter store: The GroceryStore to display.
struct StoreRowView: View {
    var store: GroceryStore

    var body: some View {
        Toggle(
            isOn: Binding(get: { store.enabled }, set: { store.enabled = $0 })
        ) {
            VStack(alignment: .leading) {
                Text(
                    "\(store.brand) #\(store.storeNum) | \(String(format: "%.2f", store.distance ?? 0)) mile\(store.distance == 1 ? "" : "s")"
                )
                if let address = store.address {
                    Text(address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    StoreRowView(store: .sample)
}
