//
//  CLLocationCoordinate2D.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/21/25.
//

import CoreLocation

extension CLLocationCoordinate2D: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    init?(address: String) async {
        let geocoder = CLGeocoder()
        
        do {
            let placemarks: [CLPlacemark] = try await withCheckedThrowingContinuation { continuation in
                geocoder.geocodeAddressString(address) { placemarks, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: placemarks ?? [])
                    }
                }
            }
            
            if let coordinate = placemarks.first?.location?.coordinate {
                self = coordinate
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func fetchZipCode() async throws -> String? {
        let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let geocoder = CLGeocoder()
        
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let postalCode = placemarks?.first?.postalCode {
                    continuation.resume(returning: postalCode)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func distanceInMiles(to other: CLLocationCoordinate2D?) -> Double? {
        guard let other = other else { return nil }
        let fromLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let toLocation = CLLocation(latitude: other.latitude, longitude: other.longitude)
        let meters = fromLocation.distance(from: toLocation)
        return Measurement(value: meters, unit: UnitLength.meters)
            .converted(to: .miles)
            .value
    }
}
