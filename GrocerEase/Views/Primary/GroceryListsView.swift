//
//  GroceryListsView.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/21/25.
//

import SwiftData
import SwiftUI

struct GroceryListsView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: [SortDescriptor(\GroceryList.name)]) var lists: [GroceryList]
    @State var newListSheetPresented: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                if lists.isEmpty {
                    VStack(spacing: 10) {
                        Text("Welcome to GrocerEase! 👋").font(.title2)
                        Text(
                            "Add your first list by pressing the \(Image(systemName: "plus")) button in the top right corner."
                        )
                    }.padding()
                } else {
                    List(lists, id: \.id) { list in
                        NavigationLink {
                            GroceryListView(list: list)
                        } label: {
                            Text(list.name)
                                .badge(
                                    list.items.count(where: { !$0.isCompleted })
                                )
                        }
                    }
                }
            }
            .navigationTitle("GrocerEase")
            .toolbar {
                ToolbarItem {
                    Button {
                        newListSheetPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $newListSheetPresented) {
                NavigationStack {
                    ListSettingsView()
                }
            }
        }
    }
}

#Preview {
    GroceryListsView()
}
