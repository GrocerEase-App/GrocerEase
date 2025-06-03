//
//  LocationSearchViewModel.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/29/25.
//

import SwiftUI
import MapKit

@Observable
class LocationSearchViewModel: NSObject, MKLocalSearchCompleterDelegate {
    var completions: [MKLocalSearchCompletion] = []

    private let searchCompleter: MKLocalSearchCompleter = {
        let completer = MKLocalSearchCompleter()
        completer.resultTypes = [.address]
        return completer
    }()

    override init() {
        super.init()
        searchCompleter.delegate = self
    }

    func search(for query: String) {
        searchCompleter.queryFragment = query
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results.filter {
            $0.subtitle.contains("United States") || !$0.subtitle.isEmpty
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("❌ Search completer failed: \(error)")
    }

    func resolve(_ completion: MKLocalSearchCompletion) async -> CLPlacemark? {
        do {
            let request = MKLocalSearch.Request(completion: completion)
            let search = MKLocalSearch(request: request)
            let response = try await search.start()

            guard let item = response.mapItems.first else { return nil }
            return item.placemark
        } catch {
            print("❌ Failed to resolve search completion: \(error)")
            return nil
        }
    }

    func resolve(_ coordinate: CLLocationCoordinate2D) async -> CLPlacemark? {
        return await coordinate.placemark()
    }
}
