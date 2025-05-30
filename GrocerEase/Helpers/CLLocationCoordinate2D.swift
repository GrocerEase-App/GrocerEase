//
//  CLLocationCoordinate2D.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/21/25.
//

import CoreLocation

extension CLLocationCoordinate2D: Codable {

    /// Defines the keys that must be encoded for a complete persistent copy of the object.
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
        let latitude = try container.decode(
            CLLocationDegrees.self,
            forKey: .latitude
        )
        let longitude = try container.decode(
            CLLocationDegrees.self,
            forKey: .longitude
        )
        self.init(latitude: latitude, longitude: longitude)
    }

    /// Initialize a CLLocationCoordinate2D based on an address string if possible.
    ///
    /// - Parameter address: A String representing a fully qualified street address.
    /// - Returns: A new CLLocationCoordinate2D based on the address if available or nil.
    init?(address: String) async {
        let geocoder = CLGeocoder()

        do {
            let placemarks: [CLPlacemark] =
                try await withCheckedThrowingContinuation { continuation in
                    geocoder.geocodeAddressString(address) {
                        placemarks,
                        error in
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

    /// Calculates distance in miles from self to another coordinate.
    ///
    /// - Parameter other: Another CLLocationCoordinate2D to calculate distance to.
    /// - Returns: The distance in miles between the coordinates as a Double.
    func distanceInMiles(to other: CLLocationCoordinate2D?) -> Double? {
        guard let other = other else { return nil }
        let fromLocation = CLLocation(
            latitude: self.latitude,
            longitude: self.longitude
        )
        let toLocation = CLLocation(
            latitude: other.latitude,
            longitude: other.longitude
        )
        let meters = fromLocation.distance(from: toLocation)
        return Measurement(value: meters, unit: UnitLength.meters)
            .converted(to: .miles)
            .value
    }

    /// Returns a CLPlacemark based on coordinate if possible in order to retrieve an address.
    ///
    /// - Returns: The most relevant CLPlacemark if available or nil.
    func placemark() async -> CLPlacemark? {
        let location = CLLocation(
            latitude: self.latitude,
            longitude: self.longitude
        )
        return await withCheckedContinuation { continuation in
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                if let placemark = placemarks?.first, error == nil {
                    continuation.resume(returning: placemark)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    /// Returns the zip code of the CLLocationCoordinate2D as a String if possible.
    func fetchZipCode() async -> String? {
        if let placemark = await self.placemark() {
            return placemark.postalCode
        } else {
            return nil
        }
    }
}
