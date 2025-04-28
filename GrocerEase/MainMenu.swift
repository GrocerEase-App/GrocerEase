//
//  MainMenu.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 4/27/25.
//

import SwiftUI

struct MainMenu: View {
    @Binding var listOrder: ListOrder
    @Binding var listDirection: ListDirection
    
    var body: some View {
        Menu {
            Text("Show Completed")
            
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
            
            Text("Edit Range")
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}
