//
//  CurrentLocationButton.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/14/25.
//

import CoreLocation
import SwiftUI

/// A button which retrieves the user's location as a CLLocationCoordinate2D
/// if allowed.
///
/// - Parameter onLocationSelected: The completion handler where the
///   requested CLLocationCoordinate2D is returned.
struct CurrentLocationButton: View {
    @State private var locationManager = LocationManager()
    var onLocationSelected: (CLLocationCoordinate2D) -> Void

    var body: some View {
        Button(action: {
            locationManager.requestLocation { coordinate in
                onLocationSelected(coordinate)
            }
        }) {
            HStack {
                Image(
                    systemName: locationManager.isDenied
                        ? "location.slash.fill" : "location.fill"
                )
                Text(
                    locationManager.isDenied
                        ? "Location Disabled" : "Use Current Location"
                )
            }
        }
        .disabled(locationManager.isDenied)
    }
}

#Preview {
    CurrentLocationButton { _ in }
}
