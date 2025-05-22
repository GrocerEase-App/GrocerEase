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
    @State var list: GroceryList
    //    @State private var groceryList: [GroceryItem] = GroceryItem.samples
    @State private var showingSearchSheet = false
    //    @State private var selectedItem: GroceryItem?
    @State private var listOrder: ListOrder = .name
    @State private var listDirection: ListDirection = .ascending
    @State private var showingLocationSheet: Bool = false
    
    private var sortedGroceryList: [GroceryItem] {
        let list = list.items.sorted(by: {
            switch listOrder {
            case .name:
                return $0.name < $1.name
            case .date:
                return $0.timestamp < $1.timestamp
            case .price:
                return $0.price ?? 0.0 < $1.price ?? 0.0
            case .store:
                return $0.store.brand < $1.store.brand
            }
        })
        
        return listDirection == .ascending ? list : list.reversed()
    }
    
    var body: some View {
        
        List {
            ForEach(sortedGroceryList) { item in
                NavigationLink {
                    EditItemView(item: item)
                } label: {
                    HStack {
                        Button(action: {
                            if let index = list.items.firstIndex(where: { $0.id == item.id }) {
                                list.items[index].isCompleted.toggle()
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
                            Text("$\(String(format: "%.2f", item.price ?? 0.0)) at \(item.store.brand)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                    }
                }
                
                
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let item = sortedGroceryList[index]
                    if let originalIndex = list.items.firstIndex(where: {$0.id == item.id}) {
                        modelContext.delete(list.items[originalIndex])
                    }
                }
            }
        }
        .navigationTitle(list.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                MainMenu(listOrder: $listOrder, listDirection: $listDirection, showingPopover: $showingLocationSheet)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showingSearchSheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingSearchSheet) {
            SearchItemView(list: list) {
                $0.list = self.list
                modelContext.insert($0)
                try? modelContext.save()
            }
        }
        .sheet(isPresented: $showingLocationSheet) {
            NavigationStack {
                LocationSettings(list: list)
            }
            
        }
        
        
    }
}

//
//#Preview {
//    ContentView()
//}
