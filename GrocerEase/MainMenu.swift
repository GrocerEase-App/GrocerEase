//
//  MainMenu.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 4/27/25.
//

import SwiftUI

struct MainMenu: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State var list: GroceryList
    @Binding var showingPopover: Bool
    @State var showingDeleteAlert: Bool = false
    
    var body: some View {
        Menu {
            Button(list.showCompleted ? "Hide Completed" : "Show Completed") {
                withAnimation {
                    list.showCompleted.toggle()
                }
            }
            
            Button("List Settings") {
                showingPopover = true
            }

            Menu("Sort By") {
                Picker("Sort By", selection: $list.listOrder) {
                    ForEach(ListOrder.allCases, id: \.self) { order in
                        Text(order.rawValue)
                    }
                }
                Picker("Sort By", selection: $list.listDirection) {
                    ForEach(ListDirection.allCases, id: \.self) { direction in
                        Text(direction.rawValue)
                    }
                }
            }
            
            Divider()
            
            Button("Delete List", role: .destructive) {
                showingDeleteAlert = true
            }
            
        } label: {
            Image(systemName: "ellipsis.circle")
        }.alert("Delete List", isPresented: $showingDeleteAlert, actions: {
            Button("Cancel", role: .cancel) {
                showingDeleteAlert = false
            }
            Button("Delete", role: .destructive) {
                showingDeleteAlert = false
                withAnimation {
                    modelContext.delete(list)
                }
                dismiss()
            }
        }, message: {
            Text("Are you sure you want to permanently delete the list \(list.name) and " +
                 (list.items.count == 1 ? "its item?" : "all \(list.items.count) items it contains?"))
        })
    }
}
