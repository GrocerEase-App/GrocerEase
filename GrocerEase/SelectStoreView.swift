//
//  SelectStoreView.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/21/25.
//

import SwiftUI

struct SelectStoreView: View {
    let group: [GroceryItem]
    let onSave: ((GroceryItem) -> Void)?
    @State var sortBy: String = "Cheapest"
    
    var sortedGroup: [GroceryItem] {
        switch sortBy {
        case "Closest":
            return group.sorted {
                ($0.store.distance ?? .greatestFiniteMagnitude) <
                ($1.store.distance ?? .greatestFiniteMagnitude)
            }
        case "Cheapest":
            return group.sorted {
                ($0.price ?? .greatestFiniteMagnitude,
                 $0.store.distance ?? .greatestFiniteMagnitude) <
                ($1.price ?? .greatestFiniteMagnitude,
                 $1.store.distance ?? .greatestFiniteMagnitude)
            }
        default:
            return group
        }
    }

    var body: some View {
        let firstItem = group.first
        let minPrice = group.compactMap { $0.price }.min()
        let minUnitPrice = group.compactMap { $0.unitPrice }.min()
        let minDistance = group.compactMap { $0.store.distance }.min()

        VStack(alignment: .leading, spacing: 16) {
            // Product info at top
            
            if let firstItem = firstItem {
                HStack(alignment: .top, spacing: 12) {
                    ProductImage(url: firstItem.imageUrl, large: true)
                    
                    VStack(alignment: .leading) {
                        Text(firstItem.name)
                            .font(.headline)
                            .lineLimit(2)
                        if let brand = firstItem.brand {
                            Text(brand).font(.caption).foregroundStyle(.secondary)
                        }
                        
                    }
                }
                .padding(.horizontal)
            }
            
            Picker("Sort By", selection: $sortBy) {
                ForEach(["Cheapest", "Closest"], id: \.self) { option in
                        Text(option)
                }
                
            }.pickerStyle(.segmented).padding(.horizontal)

            // Store options
            List(sortedGroup, id: \.id) { item in
                NavigationLink {
                    EditItemView(item: item) { item in
                        onSave?(item)
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(item.store.brand) #\(item.store.storeNum)\(item.store.distance.map { String(format: " - %.1f miles", $0) } ?? "")")
                            .font(.subheadline)
                            .foregroundStyle(item.store.distance == minDistance && item.inStock != false ? .green : .primary)
                        if let address = item.store.address {
                            Text(address)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        HStack(spacing: 4) {
                            if let price = item.price {
                                Text(String(format: "$%.2f each", price))
                                    .foregroundStyle(price == minPrice && item.inStock != false ? .green : .secondary)
                            }

                            if let unitPrice = item.unitPrice {
                                Text("(" + String(format: "$%.2f / %@", unitPrice, item.unitString ?? "each") + ")")
                                    .foregroundStyle(unitPrice == minUnitPrice && item.inStock != false ? .green : .secondary)
                            }
                        }
                        .font(.caption)
                        if let inStock = item.inStock, !inStock {
                            LittleBadge(text: "Out of Stock", color: .red)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("Choose Store")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        SelectStoreView(group: [], onSave: nil)
    }
}
