//
//  CurrentLocationButton.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/14/25.
//

import SwiftUI
import CoreLocation
import MapKit

// NOT CURRENTLY WORKING

struct CurrentLocationButton: View {
    @StateObject private var locationManager = LocationManager()
    var onLocationSelected: (CLLocationCoordinate2D, String, String?) -> Void
    
    var body: some View {
        Button(action: {
            locationManager.requestCurrentLocation(onLocationSelected: onLocationSelected)
        }) {
            HStack {
                Image(systemName: locationManager.locationServicesDenied ? "location.slash.fill" : "location.fill")
                Text(locationManager.locationServicesDenied ? "Location Disabled in Settings" : "Use Current Location")
            }
            
          
        }
        .disabled(locationManager.locationServicesDenied)
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var locationServicesDenied = false
    @Published var isRequesting = false
    
    var onLocationSelected: ((CLLocationCoordinate2D, String, String?) -> Void)?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check immediately for denied status to update UI
        let status = manager.authorizationStatus
        if status == .denied || status == .restricted {
            self.locationServicesDenied = true
        }
    }
    
    func requestCurrentLocation(onLocationSelected: ((CLLocationCoordinate2D, String, String?) -> Void)? = nil) {
        let status = manager.authorizationStatus
        
        switch status {
        case .notDetermined:
            isRequesting = true
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            locationServicesDenied = true
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        @unknown default:
            locationServicesDenied = true
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard isRequesting else { return }
        isRequesting = false
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationServicesDenied = false
            manager.requestLocation()
        case .restricted, .denied:
            locationServicesDenied = true
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let address = [placemark.name,
                               placemark.locality,
                               placemark.administrativeArea,
                               placemark.postalCode,
                               placemark.country]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                DispatchQueue.main.async {
                    self.onLocationSelected?(location.coordinate, address, placemark.postalCode)
                }
                
            } else if let error = error {
                print(error)
                DispatchQueue.main.async {
                    self.onLocationSelected?(location.coordinate, "\(location.coordinate.latitude), \(location.coordinate.longitude)", nil)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Failed to get location: \(error.localizedDescription)")
    }
}



#Preview {
    CurrentLocationButton(onLocationSelected: {_,_,_ in })
}
