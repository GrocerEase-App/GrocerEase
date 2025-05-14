//
//  LocationPicker.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/14/25.
//

import SwiftUI
import CoreLocation
import MapKit

// ChatGPT code, very experimental

struct LocationPickerPopover: View {
    @StateObject private var viewModel = LocationPickerViewModel()
    @State private var radius: Double = 10 // Default radius
    
    var onLocationSelected: ((CLLocationCoordinate2D) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Location")
                .font(.headline)
            
            Button("Use Current Location") {
                viewModel.useCurrentLocation()
            }
            .disabled(viewModel.isResolvingLocation)

            Divider()

            TextField("Enter address or ZIP", text: $viewModel.searchText, onCommit: {
                viewModel.geocodeSearch()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .disabled(viewModel.isResolvingLocation)

            if let resolved = viewModel.resolvedLocationDescription {
                Text("📍 \(resolved)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            VStack {
                Text("Search Radius: \(Int(radius)) miles")
                Slider(value: $radius, in: 1...100, step: 1)
            }
            .padding(.vertical)

            if viewModel.selectedCoordinate != nil {
                Button("Continue") {
                    if let coord = viewModel.selectedCoordinate {
                        onLocationSelected?(coord)
                        UserDefaults.standard.set(coord.latitude, forKey: "userLatitude")
                        UserDefaults.standard.set(coord.longitude, forKey: "userLongitude")
                        UserDefaults.standard.set(radius, forKey: "userSearchRadius")
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
            }

            if let error = viewModel.errorMessage {
                Text("⚠️ \(error)")
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Spacer()
        }
        .padding()
        .frame(width: 300)
    }
}

class LocationPickerViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var searchText = ""
    @Published var resolvedLocationDescription: String?
    @Published var selectedCoordinate: CLLocationCoordinate2D?
    @Published var errorMessage: String?
    @Published var isResolvingLocation = false

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func useCurrentLocation() {
        errorMessage = nil
        isResolvingLocation = true
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            errorMessage = "Location permission denied"
            isResolvingLocation = false
        default:
            locationManager.requestLocation()
        }
    }

    func geocodeSearch() {
        guard !searchText.isEmpty else { return }
        errorMessage = nil
        isResolvingLocation = true

        geocoder.geocodeAddressString(searchText) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                self?.isResolvingLocation = false

                if let error = error {
                    self?.errorMessage = "Geocoding failed: \(error.localizedDescription)"
                    return
                }

                guard let location = placemarks?.first?.location else {
                    self?.errorMessage = "Location not found"
                    return
                }

                self?.selectedCoordinate = location.coordinate
                self?.resolvedLocationDescription = placemarks?.first?.name ?? self?.searchText
            }
        }
    }

    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isResolvingLocation = false
        if let location = locations.first {
            selectedCoordinate = location.coordinate
            resolvedLocationDescription = "Current Location"
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isResolvingLocation = false
        errorMessage = "Failed to get location: \(error.localizedDescription)"
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        } else if manager.authorizationStatus == .denied {
            errorMessage = "Location permission denied"
            isResolvingLocation = false
        }
    }
}
