//
//  SearchItemView.swift
//  GrocerEase
//
//  Created by Arushi Tyagi on 4/26/25.
//

import SwiftUI

// TEMPORARY struct for search results
// This can and should be replaced with GroceryItem eventually
struct SearchResult: Identifiable {
    let id = UUID()
    var name: String
    var imageUrl: URL?
    var price: Double?
}

struct SearchItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var groceryList: [GroceryItem]
    @State private var showManualEntry = false
    // See Helpers/DebouncedState.swift for explanation
    @DebouncedState(delay: 1.0) private var searchText: String = ""
    
    @State private var searchResults: [SearchResult] = []
    
    var body: some View {
        NavigationView {
            
            List(searchResults, id: \.id) { item in
                HStack {
                    AsyncImage(url: item.imageUrl) { image in
                        image.resizable()
                            .frame(width: 50, height: 50)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 50, height: 50)

                    VStack(alignment: .leading) {
                        Text(item.name)
                        Text("$" + String(format: "%.2f", item.price ?? 0.00) + " at Safeway")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search")
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
                        // Absolute nightmare JSON parsing. We will implement SwiftyJSON to clean this up later.
                        // Effectively, this calls the scraper on the search query and retrieves the names, prices,
                        // and images for the results then feeds them into the UI.
                        let scraper = HeadlessSafewayScraper(searchQuery: searchText)
                        let result = try await scraper.run()
                        let dictionary = try! JSONSerialization.jsonObject(with: JSONSerialization.data(withJSONObject: result, options: []), options: []) as! [String: Any]
                        let items = ((dictionary["primaryProducts"] as! [String: Any])["response"] as! [String: Any])["docs"] as! [[String: Any]]
                        let results: [SearchResult] = items.map { item in
                            SearchResult(name: "\((item["name"] as! String))", imageUrl: URL(string:"\((item["imageUrl"] as! String))"), price: item["price"] as? Double)
                        }
                        self.searchResults = results
                    } catch {
                        print("❌ Failed: \(error)")
                    }
                }
            }
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
