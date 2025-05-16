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
        status = nil
    }
}

struct SearchItemView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var groceryList: [GroceryItem]
    @State private var showManualEntry = false
    // See Helpers/DebouncedState.swift for explanation
    @DebouncedState(delay: 0.75) private var searchText: String = ""
    @State private var isSearching: Bool = false
    
    @StateObject private var viewModel: SearchItemViewModel = .init()
    
    var body: some View {
        NavigationView {
            
            List(viewModel.results, id: \.id) { item in
                HStack {
                    if item.imageUrl != nil, let imageUrl = item.imageUrl {
                        AsyncImage(url: URL(string: imageUrl)!) { image in
                            image.resizable()
                                .frame(width: 50, height: 50)
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 50, height: 50)
                    }
                    
                    
                    VStack(alignment: .leading) {
                        Text(item.name)
                        Text("$" + String(format: "%.2f", item.price) + " at Safeway")
                            .foregroundStyle(.secondary)
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
                        EditItemView(groceryList: $groceryList, existingItem: nil) {
                            showManualEntry = false
                        }
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
