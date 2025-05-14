//
//  ContentView.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 4/21/25.
//

import SwiftUI

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
    @State private var groceryList: [GroceryItem] = GroceryItem.samples
    @State private var showSearchItem = false
    @State private var selectedItem: GroceryItem?
    @State private var listOrder: ListOrder = .name
    @State private var listDirection: ListDirection = .ascending
    @State private var showingPopover: Bool = false
    @State private var locationDescription: String?
    
    private var sortedGroceryList: [GroceryItem] {
        let list = groceryList.sorted(by: {
            switch listOrder {
            case .name:
                return $0.name < $1.name
            case .date:
                return $0.timestamp < $1.timestamp
            case .price:
                return $0.price < $1.price
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
                            Text("$\(String(format: "%.2f", item.price)) at \(item.store)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .onTapGesture {
                            selectedItem = item
                        }
                    }
                }
                .onDelete(perform: deleteItem)
            }
            .navigationTitle("GrocerEase")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    MainMenu(listOrder: $listOrder, listDirection: $listDirection, showingPopover: $showingPopover)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showSearchItem.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $selectedItem) { item in
                NavigationView {
                    EditItemView(groceryList: $groceryList, existingItem: item) {
                        selectedItem = nil
                    }
                }
                
            }
            .sheet(isPresented: $showSearchItem) {
                SearchItemView(groceryList: $groceryList)
            }
            .sheet(isPresented: $showingPopover) {
                LocationPickerPopover { coord in
                    locationDescription = "Lat: \(coord.latitude), Lon: \(coord.longitude)"
                    showingPopover = false
                }
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
