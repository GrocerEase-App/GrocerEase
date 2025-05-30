//
//  GrocerEaseApp.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 4/21/25.
//

import SwiftUI
import SwiftData

@main
struct GrocerEaseApp: App {
    var body: some Scene {
        WindowGroup {
            GroceryListsView()
        }.modelContainer(for: GroceryList.self)
    }
}
