//
//  ListsView.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/21/25.
//

import SwiftUI
import SwiftData

struct ListsView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: [SortDescriptor(\GroceryList.name)]) var lists: [GroceryList]
    //    @State var selectedList: GroceryList?
    @State var newListSheetPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            List(lists, id: \.id) { list in
                NavigationLink(list.name) {
                    ContentView(list: list)
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
                    LocationSettings()
                }
            }
        }
        
    }
}

#Preview {
    ListsView()
}
