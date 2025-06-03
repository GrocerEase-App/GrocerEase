//
//  String.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/13/25.
//

import CoreLocation
import Foundation

/// Adds support for throwing a String as an error with itself as the error
/// description.
extension String: @retroactive LocalizedError {
    public var errorDescription: String? { return self }
}

extension String {
    /// Initialize String containing a street address based on its components.
    init(
        line1: String? = nil,
        line2: String? = nil,
        city: String? = nil,
        state: String? = nil,
        zip: String? = nil,
        country: String? = nil
    ) {
        // Street part (line1 + line2)
        let street = [line1, line2]
            .compactMap { $0 }
            .joined(separator: " ")

        // City/state/zip with comma between city and state
        var cityStateZip = ""
        if let city = city {
            cityStateZip += city
        }
        if let state = state {
            if !cityStateZip.isEmpty {
                cityStateZip += ", "
            }
            cityStateZip += state
        }
        if let zip = zip {
            if !cityStateZip.isEmpty {
                cityStateZip += " "
            }
            cityStateZip += zip
        }

        // Combine all parts with proper commas
        var address = ""
        if !street.isEmpty {
            address += street
        }
        if !cityStateZip.isEmpty {
            if !address.isEmpty { address += ", " }
            address += cityStateZip
        }
        if let country = country, !country.isEmpty {
            if !address.isEmpty { address += ", " }
            address += country
        }
        self.init(stringLiteral: address)
    }

}
