//
//  CLPlacemark.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/21/25.
//

import CoreLocation

extension CLPlacemark {
    /// Address string based on the address contained by the placemark.
    var formattedAddress: String {
        String(
            line1: self.subThoroughfare.flatMap { houseNumber in
                self.thoroughfare.map { "\(houseNumber) \($0)" }
            } ?? self.thoroughfare,
            line2: nil,
            city: self.locality,
            state: self.administrativeArea,
            zip: self.postalCode,
            country: self.country
        )
    }
}
