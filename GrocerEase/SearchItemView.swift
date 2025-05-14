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
    // See Helpers/DebouncedState.swift for explanation
    @DebouncedState(delay: 0.75) private var searchText: String = ""
    @State private var isLoading: Bool = false
    @State private var isSearching: Bool = false
    
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
                        isLoading = true
                        self.searchResults = try await SafewayScraper.shared.searchItems(query: searchText, storeId: "3132")
                        isLoading = false
                    } catch {
                        print("❌ Failed: \(error)")
                        isLoading = false
                    }
                }
            }
            .navigationTitle("New Item")
            .toolbar {
                if isLoading {
                    ToolbarItemGroup(placement: .bottomBar) {
                        HStack {
                            ProgressView()
                            Text("Searching Safeway #3132")
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
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

//#Preview {
//    SearchItemView()
//}
