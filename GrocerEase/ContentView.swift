//
//  ContentView.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 4/21/25.
//

import SwiftUI
import SwiftData

enum ListOrder: String, CaseIterable {
    case name = "Name"
    case date = "Date Added"
    case price = "Price"
    case store = "Store"
}

enum ListDirection: String, CaseIterable {
    case ascending = "Ascending"
    case descending = "Descending"
}

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: [SortDescriptor(\GroceryItem.price, order: .reverse), SortDescriptor(\GroceryItem.name)]) var groceryList: [GroceryItem]
//    @State private var groceryList: [GroceryItem] = GroceryItem.samples
    @State private var showingSearchSheet = false
//    @State private var selectedItem: GroceryItem?
    @State private var listOrder: ListOrder = .name
    @State private var listDirection: ListDirection = .ascending
    @State private var showingLocationSheet: Bool = false
    
    private var searchOptionsSet: Bool {
        let uds = UserDefaults.standard
        if let _ = uds.object(forKey: "userLatitude") as? Double,
           let _ = uds.object(forKey: "userLongitude") as? Double,
           let _ = uds.object(forKey: "userSearchRadius") as? Double
        {
            return true
        } else {
            return false
            
        }
    }
    
    @State private var showingAlert: Bool = false
    
    private var sortedGroceryList: [GroceryItem] {
        let list = groceryList.sorted(by: {
            switch listOrder {
            case .name:
                return $0.name < $1.name
            case .date:
                return $0.timestamp < $1.timestamp
            case .price:
                return $0.price ?? 0.0 < $1.price ?? 0.0
            case .store:
                return $0.store < $1.store
            }
        })
        
        return listDirection == .ascending ? list : list.reversed()
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedGroceryList) { item in
                    NavigationLink {
                        EditItemView(item: item)
                    } label: {
                        HStack {
                            Button(action: {
                                if let index = groceryList.firstIndex(where: { $0.id == item.id }) {
                                    groceryList[index].isCompleted.toggle()
                                }
                            }) {
                                Image(systemName: item.isCompleted ? "largecircle.fill.circle" : "circle")
                            }
                            .imageScale(.large)
                            .padding(.trailing)
                            .buttonStyle(BorderlessButtonStyle())
                            
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .strikethrough(item.isCompleted, color: .gray)
                                Text("$\(String(format: "%.2f", item.price ?? 0.0)) at \(item.store)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                        }
                    }
                    

                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let item = groceryList[index]
                        modelContext.delete(item)
//                        let itemToDelete = sortedGroceryList[index]
//                        if let originalIndex = groceryList.firstIndex(where: { $0.id == itemToDelete.id }) {
//                            groceryList.remove(at: originalIndex)
//                        }
                    }
                }
            }
            .navigationTitle("GrocerEase")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    MainMenu(listOrder: $listOrder, listDirection: $listDirection, showingPopover: $showingLocationSheet)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if !searchOptionsSet {
                            showingAlert = true
                        } else {
                            showingSearchSheet = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingSearchSheet) {
                SearchItemView()
            }
            .sheet(isPresented: $showingLocationSheet) {
                LocationSettings()
            }
            .alert("Setup Incomplete", isPresented: $showingAlert) {
                Button("Configure Location") {
                    showingLocationSheet = true
                }
                Button("Enter Item Manually") {
                    // TODO: Make this work
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You need to select an origin location before you can search for items or continue to manual entry.")
            }
            
            
        }
    }
}


#Preview {
    ContentView()
}
