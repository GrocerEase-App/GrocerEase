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
    @State private var showingSearchSheet = false
    @State private var listOrder: ListOrder = .name
    @State private var listDirection: ListDirection = .ascending
    @State private var showingLocationSheet: Bool = false
    
    private var sortedGroceryList: [GroceryItem] {
        let list = list.items
            .filter { self.list.showCompleted || !$0.isCompleted }
            .sorted(by: {
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
        
        VStack {
            if list.items.isEmpty {
                VStack(spacing: 10) {
                    Text("Your new list is ready to go!").font(.title2)
                    Text("Add your first item by pressing the \(Image(systemName: "plus")) button in the top right corner.")
                }.padding()
            } else {
                List {
                    ForEach(sortedGroceryList) { item in
                        NavigationLink {
                            EditItemView(item: item)
                        } label: {
                            HStack {
                                Button {
                                    withAnimation {
                                        if let index = list.items.firstIndex(where: { $0.id == item.id }) {
                                            list.items[index].isCompleted.toggle()
                                        }
                                    }
                                } label: {
                                    Image(systemName: item.isCompleted ? "largecircle.fill.circle" : "circle")
                                }
                                .imageScale(.large)
                                .padding(.trailing)
                                .buttonStyle(BorderlessButtonStyle())
                                
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .foregroundStyle(item.isCompleted ? .secondary : .primary)
//                                        .strikethrough(item.isCompleted, color: .gray)
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
                                list.items.remove(at: originalIndex)
                                modelContext.delete(list.items[originalIndex])
                            }
                        }
                    }
                }
            }
        }
        
        
        .navigationTitle(list.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                MainMenu(list: list, listOrder: $listOrder, listDirection: $listDirection, showingPopover: $showingLocationSheet)
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
            SearchItemView(list: list) { item in
                
            }
        }
        .sheet(isPresented: $showingLocationSheet) {
            NavigationStack {
                LocationSettings(list: list)
            }
            
        }
        
        
    }
}

#Preview {
    NavigationView {
        ContentView(list: .sample)
    }
}
