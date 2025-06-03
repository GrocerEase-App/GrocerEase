//
//  GroceryListView.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 4/21/25.
//

import SwiftData
import SwiftUI

struct GroceryListView: View {
    @Environment(\.modelContext) var modelContext
    @State var list: GroceryList
    @State private var showingSearchSheet = false
    @State private var showingLocationSheet: Bool = false

    private var sortedGroceryList: [GroceryItem] {
        let items = list.items
            .filter { list.showCompleted || !$0.isCompleted }
            .sorted(by: {
                switch list.listOrder {
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

        return list.listDirection == .ascending ? items : items.reversed()
    }

    var body: some View {

        VStack {
            if list.items.isEmpty {
                VStack(spacing: 10) {
                    Text("Your new list is ready to go!").font(.title2)
                    Text(
                        "Add your first item by pressing the \(Image(systemName: "plus")) button in the top right corner."
                    )
                }.padding()

            } else if list.items.count(where: { !$0.isCompleted }) == 0
                && !list.showCompleted
            {
                VStack {
                    Button("Show Completed") {
                        withAnimation {
                            list.showCompleted = true
                        }
                    }
                }
            } else {
                List {
                    ForEach(sortedGroceryList) { item in
                        NavigationLink {
                            EditItemView(item: item)
                        } label: {
                            HStack {
                                Button {
                                    withAnimation {
                                        if let index = list.items.firstIndex(
                                            where: { $0.id == item.id })
                                        {
                                            list.items[index].isCompleted
                                                .toggle()
                                        }
                                    }
                                } label: {
                                    Image(
                                        systemName: item.isCompleted
                                            ? "largecircle.fill.circle"
                                            : "circle"
                                    )
                                }
                                .imageScale(.large)
                                .padding(.trailing)
                                .buttonStyle(BorderlessButtonStyle())

                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .foregroundStyle(
                                            item.isCompleted
                                                ? .secondary : .primary
                                        )
                                    //                                        .strikethrough(item.isCompleted, color: .gray)
                                    Text(
                                        "$\(String(format: "%.2f", item.price ?? 0.0)) at \(item.store.brand)"
                                    )
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                }

                            }
                        }

                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let item = sortedGroceryList[index]
                            if let originalIndex = list.items.firstIndex(
                                where: { $0.id == item.id })
                            {
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
                GroceryListMenu(
                    list: list,
                    showingPopover: $showingLocationSheet
                )
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
                ListSettingsView(list: list)
            }

        }

    }
}

#Preview {
    NavigationView {
        GroceryListView(list: .sample)
    }
}
