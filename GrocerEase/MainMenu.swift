//
//  MainMenu.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 4/27/25.
//

import SwiftUI

struct MainMenu: View {
    var list: GroceryList
    @Binding var listOrder: ListOrder
    @Binding var listDirection: ListDirection
    @Binding var showingPopover: Bool
    
    var body: some View {
        Menu {
            Button(list.showCompleted ? "Hide Completed" : "Show Completed") {
                list.showCompleted.toggle()
            }
            
            Button("List Settings") {
                showingPopover = true
            }

            Menu("Sort By") {
                Picker("Sort By", selection: $listOrder) {
                    ForEach(ListOrder.allCases, id: \.self) { order in
                        Text(order.rawValue)
                    }
                }
                Picker("Sort By", selection: $listDirection) {
                    ForEach(ListDirection.allCases, id: \.self) { direction in
                        Text(direction.rawValue)
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}
