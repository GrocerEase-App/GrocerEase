//
//  LocationSettings.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/14/25.
//

import SwiftUI
import CoreLocation
import MapKit

struct LocationSettings: View {
    @Environment(\.dismiss) private var dismiss
    @State private var toggleOn: Bool = true
    @State private var coordinates: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: UserDefaults.standard.object(forKey: "userLatitude") as? Double ?? 0.0, longitude: UserDefaults.standard.object(forKey: "userLongitude") as? Double ?? 0.0)
    @State private var locationDescription: String? = UserDefaults.standard.object(forKey: "userLocationDescription") as? String ?? "Not Set"
    @State private var radius: Double = UserDefaults.standard.object(forKey: "userSearchRadius") as? Double ?? 10.0
    
//    var onLocationSelected: ((CLLocationCoordinate2D, Double) -> Void)?
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        LocationSearchView { coords, desc in
                            coordinates = coords
                            locationDescription = desc
                        }
                    } label: {
                        HStack {
                            Text("Location")
                            Spacer()
                            Text(locationDescription ?? "Not Set")
                                .foregroundStyle(.secondary)
                         
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        HStack() {
                            Text("Radius")
//                            TextField("", value: $radius, format: .number)
//                                .multilineTextAlignment(.trailing)
//                                .onSubmit {
//                                    if radius < 1 {
//                                        radius = 1
//                                    } else if radius > 100 {
//                                        radius = 100
//                                    }
//                                }
//                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(String(format: "%.0f", radius)) miles")
                                .foregroundStyle(.secondary)
                        }
                        
                        Slider(value: $radius, in: 1...100, step: 1)
                    }
                } header: {
                    Text("Location")
                } footer: {
                    Text("Choose an origin location, such as your home, and a search radius to find nearby stores. Distance will be taken into consideration when calculating the most cost efficient store to visit.")
                }
                
                Section {
                    ForEach(["Safeway", "Trader Joe's", "Target", "CVS", "Costco", "Whole Foods"].sorted(), id: \.self) { store in
                        HStack {
                            Toggle(isOn: $toggleOn) {
                                Text(store)
                            }
                        }
                    }
                    
                } header: {
                    Text("Stores")
                } footer: {
                    Text("Store selection not yet implemented.")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        UserDefaults.standard.set(coordinates?.latitude, forKey: "userLatitude")
                        UserDefaults.standard.set(coordinates?.longitude, forKey: "userLongitude")
                        UserDefaults.standard.set(radius, forKey: "userSearchRadius")
                        UserDefaults.standard.set(locationDescription, forKey: "userLocationDescription")
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            
        }
    }
}



#Preview {
    LocationSettings()
}

