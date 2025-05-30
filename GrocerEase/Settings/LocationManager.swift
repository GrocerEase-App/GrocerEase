//
//  LocationManager.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/29/25.
//

import CoreLocation
import SwiftUI

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    /// Describes whether location services access has been explicitly denied by the user.
    var isDenied = false

    private let manager = CLLocationManager()
    private var callback: ((CLLocationCoordinate2D) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        updateAuthorizationStatus(manager.authorizationStatus)
    }

    /// Initiate a location request with the given completion handler.
    ///
    /// - Parameter onLocationSelected: The completion handler where the
    ///   requested CLLocationCoordinate2D is returned.
    func requestLocation(
        onLocationSelected: @escaping (CLLocationCoordinate2D) -> Void
    ) {
        self.callback = onLocationSelected

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .restricted, .denied:
            isDenied = true
        @unknown default:
            isDenied = true
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateAuthorizationStatus(manager.authorizationStatus)
        if !isDenied {
            manager.requestLocation()
        }
    }

    private func updateAuthorizationStatus(_ status: CLAuthorizationStatus) {
        isDenied = (status == .denied || status == .restricted)
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let coordinate = locations.first?.coordinate {
            callback?(coordinate)
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Safe to ignore, too many false positives to report to user
        // Usually does not indicate process failure
        print("Location error: \(error.localizedDescription)")
    }
}
