//
//  SearchItemView.swift
//  GrocerEase
//
//  Created by Arushi Tyagi on 4/26/25.
//

import SwiftUI

@Observable
class SearchItemViewModel: ObservableObject {
    
    public var stores: [GroceryStore] = []
    public var results: [GroceryItem] = []
    public var status: String?
    @ObservationIgnored private var latitude: Double? = UserDefaults.standard.object(forKey: "userLatitude") as? Double
    @ObservationIgnored private var longitude: Double? = UserDefaults.standard.object(forKey: "userLongitude") as? Double
    @ObservationIgnored private var radius: Double? = UserDefaults.standard.object(forKey: "userSearchRadius") as? Double
    
    init() {
        Task {
            try? await fetchGroceryStores()
        }
    }
    
    private func fetchGroceryStores() async throws {
        guard let latitude = latitude, let longitude = longitude, let radius = radius else {
            throw "No location data available"
        }
        
        for source in PriceSource.allCases {
            status = "Finding \(source.rawValue) Stores"
            let sourceStores = try? await source.scraper.shared.getNearbyStores(latitude: latitude, longitude: longitude, radius: radius)
            stores.append(contentsOf: sourceStores ?? [])
        }
        status = nil
    }
    
    func fetchSearchResults(for text: String) async throws {
        if !text.isEmpty {
            for store in stores {
                status = "Searching \(store.brand) #\(store.id)"
                results.append(contentsOf: try await store.search(for: text))
            }
        } else {
            results = []
        }
        results.sort { $0.searchRank ?? 0 < $1.searchRank ?? 1 }
        status = nil
    }
}

struct SearchItemView: View {
    @Environment(\.dismiss) private var dismiss
    // See Helpers/DebouncedState.swift for explanation
    @DebouncedState(delay: 0.75) private var searchText: String = ""
    @State private var isSearching: Bool = false
    
    @StateObject private var viewModel: SearchItemViewModel = .init()
    
    var body: some View {
        NavigationView {
            VStack {
                if !viewModel.stores.isEmpty {
                    List(viewModel.results, id: \.id) { item in
                        NavigationLink {
                            EditItemView(item: item)
                        } label: {
                            HStack {
                                ProductImage(url: item.imageUrl)
                                
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                    Text("$" + String(format: "%.2f", item.price ?? 0.0) + " at \(item.store)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                    }
                    .listStyle(PlainListStyle())
                    .searchable(text: $searchText, isPresented: $isSearching, prompt: "Search")
                    .onChange(of: searchText) {
                        Task {
                            try? await viewModel.fetchSearchResults(for: searchText)
                        }
                    }
                    
                }
            }
            .navigationTitle("New Item")
            .toolbar {
                if let status = viewModel.status {
                    ToolbarItemGroup(placement: .bottomBar) {
                        HStack {
                            ProgressView()
                            Text(status)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        Text("hey!")
//                        EditItemView(item: nil)
                    } label: {
                        Image(systemName: "pencil")
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

//#Preview {
//    SearchItemView()
//}
