//
//  SearchItemView.swift
//  GrocerEase
//
//  Created by Arushi Tyagi on 4/26/25.
//

import SwiftUI

struct SearchItemView: View {
    @Environment(\.dismiss) private var dismiss
    // See Helpers/DebouncedState.swift for explanation
    @DebouncedState(delay: 0.75) private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State var list: GroceryList

    @State private var status: String?
    var onSave: ((GroceryItem) -> Void)?

    @State private var groupedResults: [[GroceryItem]] = []

    func fetchSearchResults(for text: String) async throws {
        var allItems: [GroceryItem] = []

        if !text.isEmpty {
            for store in list.stores.filter({ $0.enabled }) {
                status = "Searching \(store.brand) #\(store.storeNum)"
                let items = try await store.search(for: text)
                allItems.append(contentsOf: items)
            }
        }

        status = nil

        var parent = Array(0..<allItems.count)

        // Union-Find helpers
        func find(_ x: Int) -> Int {
            if parent[x] != x {
                parent[x] = find(parent[x])  // path compression
            }
            return parent[x]
        }

        func union(_ x: Int, _ y: Int) {
            let rootX = find(x)
            let rootY = find(y)
            if rootX != rootY {
                parent[rootY] = rootX
            }
        }

        // Step 2: Build lookup tables
        var upcMap: [String: Int] = [:]
        var pluMap: [String: Int] = [:]
        var skuBrandMap: [String: Int] = [:]
        var nameMap: [String: Int] = [:]

        for (index, item) in allItems.enumerated() {
            if let upc = item.upc {
                if let existing = upcMap[upc] {
                    union(index, existing)
                } else {
                    upcMap[upc] = index
                }
            }
            if let plu = item.plu {
                if let existing = pluMap[plu] {
                    union(index, existing)
                } else {
                    pluMap[plu] = index
                }
            }
            if let sku = item.sku {
                let key = "\(item.store.brand)|\(sku)"
                if let existing = skuBrandMap[key] {
                    union(index, existing)
                } else {
                    skuBrandMap[key] = index
                }
            }
            if !item.name.isEmpty {
                if let existing = nameMap[item.name] {
                    union(index, existing)
                } else {
                    nameMap[item.name] = index
                }
            }
        }

        // Step 3: Group by root parent
        var clusters: [Int: [GroceryItem]] = [:]
        for (index, item) in allItems.enumerated() {
            let root = find(index)
            clusters[root, default: []].append(item)
        }

        // Step 4: Sort each group by item name or rank if needed, then sort outer array by rank of first item
        groupedResults = clusters.values.map { group in
            group.sorted { ($0.searchRank ?? 0) < ($1.searchRank ?? 0) }
        }.sorted {
            ($0.first?.searchRank ?? 0) < ($1.first?.searchRank ?? 0)
        }
    }

    var body: some View {
        let allItems = groupedResults.flatMap { $0 }
        let minPrice = allItems.compactMap(\.price).min()
        let minUnitPrice = allItems.compactMap(\.unitPrice).min()

        NavigationView {
            VStack {
                if !list.stores.isEmpty {
                    List {
                        ForEach(groupedResults, id: \.first?.id) { group in
                            if let item = group.first {
                                NavigationLink {
                                    if group.count == 1 {
                                        EditItemView(item: item) {
                                            onSave?($0)
                                            dismiss()
                                        }
                                    } else {
                                        switch list.autoSelect {
                                        case .none:
                                            SelectStoreView(group: group) {
                                                item in
                                                self.onSave?(item)
                                                dismiss()
                                            }

                                        case .closest:
                                            EditItemView(
                                                item: group.sorted {
                                                    let distance0 =
                                                        $0.store.distance
                                                        ?? .greatestFiniteMagnitude
                                                    let distance1 =
                                                        $1.store.distance
                                                        ?? .greatestFiniteMagnitude

                                                    if distance0 == distance1 {
                                                        return $0.store
                                                            .sortOrder
                                                            < $1.store.sortOrder
                                                    } else {
                                                        return distance0
                                                            < distance1
                                                    }
                                                }.first!
                                            )

                                        case .cheapest:
                                            EditItemView(
                                                item: group.sorted {
                                                    let price0 =
                                                        $0.price
                                                        ?? .greatestFiniteMagnitude
                                                    let price1 =
                                                        $1.price
                                                        ?? .greatestFiniteMagnitude

                                                    if price0 == price1 {
                                                        return $0.store
                                                            .sortOrder
                                                            < $1.store.sortOrder
                                                    } else {
                                                        return price0 < price1
                                                    }
                                                }.first!
                                            )

                                        case .custom:
                                            EditItemView(
                                                item: group.sorted {
                                                    $0.store.sortOrder
                                                        < $1.store.sortOrder
                                                }.first!
                                            )
                                        }

                                    }
                                } label: {
                                    if let cheapest = group.compactMap({
                                        $0.price != nil ? $0 : nil
                                    }).min(by: { $0.price! < $1.price! }) {
                                        HStack {
                                            ProductImageView(
                                                url: cheapest.imageUrl
                                            )

                                            VStack(alignment: .leading) {
                                                Text(item.name)

                                                let otherCount = group.count - 1
                                                let othersText =
                                                    otherCount > 0
                                                    ? " + \(otherCount) others"
                                                    : ""

                                                HStack(spacing: 4) {
                                                    if let price = item.price {
                                                        Text(
                                                            String(
                                                                format:
                                                                    "$%.2f each",
                                                                price
                                                            )
                                                        )
                                                        .foregroundStyle(
                                                            price == minPrice
                                                                ? .green
                                                                : .secondary
                                                        )
                                                    }

                                                    if let unitPrice = item
                                                        .unitPrice
                                                    {
                                                        Text(
                                                            "("
                                                                + String(
                                                                    format:
                                                                        "$%.2f / %@",
                                                                    unitPrice,
                                                                    item
                                                                        .unitString
                                                                        ?? "each"
                                                                ) + ")"
                                                        )
                                                        .foregroundStyle(
                                                            unitPrice
                                                                == minUnitPrice
                                                                ? .green
                                                                : .secondary
                                                        )
                                                    }
                                                }

                                                Text(
                                                    "at \(item.store.brand)\(othersText)"
                                                )
                                                .foregroundStyle(.secondary)
                                            }

                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .searchable(
                        text: $searchText,
                        isPresented: $isSearching,
                        prompt: "Search"
                    )
                    .onChange(of: searchText) {
                        Task {
                            try? await fetchSearchResults(for: searchText)
                        }
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let status = status {
                    ToolbarItemGroup(placement: .bottomBar) {
                        HStack {
                            ProgressView()
                            Text(status)
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

}

#Preview {
    SearchItemView(list: .sample)
}
