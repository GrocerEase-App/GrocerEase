//
//  ContentView.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 4/21/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedCategory = "Produce"
    @State private var newItem = ""
    @State private var groceryList: [String: [String]] = [:]

    // list of all  categories
    private let allCategories = [
        "Produce", "Meat", "Dairy", "Bakery", "Snacks", "Frozen", "Beverages",
        "Canned Goods", "Condiments", "Grains", "Household", "Personal Care", "Other"
    ]

    // dictionary of predefined suggestions for each category
    private let categorizedSuggestions: [String: [String]] = [
        "Produce": ["Apple", "Banana", "Carrots", "Lettuce"],
        "Meat": ["Chicken", "Beef", "Turkey", "Bacon"],
        "Dairy": ["Milk", "Yogurt", "Cheese", "Butter"],
        "Bakery": ["Bread", "Bagel", "Croissant"],
        "Snacks": ["Chips", "Cookies", "Crackers"],
        "Frozen": ["Frozen Pizza", "Ice Cream", "Frozen Vegetables"],
        "Beverages": ["Soda", "Juice", "Coffee", "Tea"],
        "Canned Goods": ["Canned Beans", "Tomato Paste", "Canned Corn"],
        "Condiments": ["Ketchup", "Mustard", "Mayonnaise"],
        "Grains": ["Rice", "Pasta", "Quinoa"],
        "Household": ["Toilet Paper", "Paper Towels", "Trash Bags"],
        "Personal Care": ["Soap", "Shampoo", "Toothpaste"],
        "Other": []
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                Text("🛒 Grocery List")
                    .font(.title3.bold())
                    .padding(.horizontal)

                // Category picker + custom text input + add button
                HStack {
                    // Dropdown to select category
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(allCategories, id: \.self) { Text($0) }
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                    // text input field to enter custom item
                    TextField("Custom item...", text: $newItem)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    // Plus button to add custom item
                    Button(action: addItemToList) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(newItem.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)

                // Suggestions for selected category
                
                // unwrap array of suggestions for selected category
                if let suggestions = categorizedSuggestions[selectedCategory], !suggestions.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        // horizontally lay inside scroll view
                        HStack {
                            // each item is a button
                            ForEach(suggestions, id: \.self) { item in
                                Button(action: {
                                    groceryList[selectedCategory, default: []].append(item)
                                }) {
                                    Text(item)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // List of items grouped by category
                List {
                    // loop thorugh categories in grocerlist dictionary
                    ForEach(groceryList.keys.sorted(), id: \.self) { category in
                        Section(header: Text(category).font(.headline)) { // each category becomes a section in the list with a header
                            // loop through array of items in that category
                            ForEach(groceryList[category] ?? [], id: \.self) { item in
                                HStack { // item name, trash icon
                                    Text(item)
                                    Spacer()
                                    Button(action: {
                                        deleteItem(item, from: category)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("GrocerEase")
        }
    }

    // Add user's custom item to selected category
    private func addItemToList() {
        let trimmed = newItem.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        groceryList[selectedCategory, default: []].append(trimmed)
        newItem = "" // reset input
    }

    // Delete item from specific category
    private func deleteItem(_ item: String, from category: String) {
        if let index = groceryList[category]?.firstIndex(of: item) {
            groceryList[category]?.remove(at: index)
            // remove category if now empty
            if groceryList[category]?.isEmpty ?? false {
                groceryList.removeValue(forKey: category)
            }
        }
    }
}

#Preview {
    ContentView()
}
