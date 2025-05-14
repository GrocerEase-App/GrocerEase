//
//  String.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/13/25.
//

import Foundation

extension String: @retroactive LocalizedError {
    public var errorDescription: String? { return self }
}
