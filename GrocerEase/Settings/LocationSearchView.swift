//
//  LocationSearchView.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/14/25.
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
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results.filter {
            $0.subtitle.contains("United States") || !$0.subtitle.isEmpty
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("❌ Search completer failed: \(error)")
    }
    
    func search(for query: String) {
        searchCompleter.queryFragment = query
    }
}

struct LocationSearchView: View {
    @State private var viewModel = LocationSearchViewModel()
    @State private var searchFocused: Bool = false
    @DebouncedState private var searchText: String = ""
    @Environment(\.dismiss) var dismiss
    
    var onLocationSelected: (CLLocationCoordinate2D, String, String?) -> Void
    
    var body: some View {
        VStack {
            if viewModel.completions.isEmpty || searchText.isEmpty {
                VStack {
                    CurrentLocationButton(onLocationSelected: onLocationSelected)
                    Text("or")
                        .padding(16)
                    
                    Button("Enter an address") {
                        searchFocused = true
                    }.disabled(searchFocused)
                }.padding(24)
            } else {
                List {
                    ForEach(viewModel.completions, id: \.self) { completion in
                        Button {
                            Task {
                                let request = MKLocalSearch.Request(completion: completion)
                                let search = MKLocalSearch(request: request)
                                let response = try await search.start()
                                DispatchQueue.main.async {
                                    let location = response.mapItems.first!
                                    let placemark = location.placemark
                                    let address = [placemark.name,
                                                   placemark.locality,
                                                   placemark.administrativeArea,
                                                   placemark.postalCode,
                                                   placemark.country]
                                        .compactMap { $0 }
                                        .joined(separator: ", ")
                                    self.onLocationSelected(location.placemark.coordinate, address, placemark.postalCode)
                                    dismiss()
                                }
                            }
                        } label: {
                            VStack(alignment: .leading) {
                                Text(completion.title).bold()
                                Text(completion.subtitle).font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                }.listStyle(.plain)
            }
            
        }.navigationTitle("Search Location")
            .searchable(text: $searchText, isPresented: $searchFocused, prompt: "Search an address, city, or ZIP code")
            .onChange(of: searchText) {
                viewModel.search(for: searchText)
            }
        
        
    }
    
}

#Preview {
    NavigationView {
        LocationSearchView { _,_,_  in}
    }
}

