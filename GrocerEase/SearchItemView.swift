//
//  SearchItemView.swift
//  GrocerEase
//
//  Created by Arushi Tyagi on 4/26/25.
//

import SwiftUI

struct SearchItemView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var groceryList: [GroceryItem]
    @State private var showManualEntry = false
    // See Helpers/DebouncedState.swift for explanation
    @DebouncedState(delay: 0.75) private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var searchStore: String?
    @State private var loadingText: String?
    
    @State private var searchResults: [GroceryItem] = []
    
    var body: some View {
        NavigationView {
            
            List(searchResults, id: \.id) { item in
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
                // If search text is empty, clear the results
                if searchText == "" {
                    self.searchResults = []
                    return
                }
                // Otherwise, make an async call to the Safeway Scraper
                // Eventually, this will need to call ALL the scrapers at once in a succinct way
                // Some will have to be called multiple times (e.g. Safeway on Mission and on Morrissey)
                Task {
                    do {
                        loadingText = "Finding Safeway Stores..."
                        let stores = try await SafewayScraper.shared.getNearbyStores(latitude: UserDefaults.standard.double(forKey: "userLatitude"), longitude: UserDefaults.standard.double(forKey: "userLongitude"), radius: UserDefaults.standard.double(forKey: "userSearchRadius"))
                        print(stores.map {$0.id})
                        self.searchStore = stores.first!.id
                        loadingText = "Searching Safeway #\(self.searchStore ?? "unknown")"
                        self.searchResults = try await SafewayScraper.shared.searchItems(query: searchText, storeId: self.searchStore!)
                        loadingText = nil
                    } catch {
                        print("❌ Failed: \(error)")
                        loadingText = nil
                    }
                }
            }
            .navigationTitle("New Item")
            .toolbar {
                if loadingText != nil {
                    ToolbarItemGroup(placement: .bottomBar) {
                        HStack {
                            ProgressView()
                            Text(loadingText ?? "Loading complete")
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
