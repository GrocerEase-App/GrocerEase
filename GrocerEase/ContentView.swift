//
//  ContentView.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 4/21/25.
//

import SwiftUI

struct ContentView: View {
    @State private var groceryList: [GroceryItem] = []
    @State private var showAddItem = false

    var body: some View {
        NavigationView {
            List {
                ForEach(groceryList) { item in
                    HStack {
                        Button(action: {
                            if let index = groceryList.firstIndex(where: { $0.id == item.id }) {
                                groceryList[index].isCompleted.toggle()
                            }
                        }) {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        }
                        .buttonStyle(BorderlessButtonStyle())

                        VStack(alignment: .leading) {
                            Text(item.name)
                                .strikethrough(item.isCompleted, color: .gray)
                            Text("$\(String(format: "%.2f", item.price)) at \(item.store)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .onTapGesture {
                            // Edit item screen here
                        }
                    }
                }
                .onDelete(perform: deleteItem)
            }
            .navigationTitle("GrocerEase")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddItem.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddItem) {
                AddItemView(groceryList: $groceryList)
            }
        }
    }

    func deleteItem(at offsets: IndexSet) {
        groceryList.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}
