//
//  Item.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 4/21/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
