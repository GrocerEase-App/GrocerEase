//
//  LocationSearchView.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/14/25.
//

import CoreLocation
import MapKit
import SwiftUI

/// Provides a search interface for addresses or an option to select one based
/// on the user's current location.
///
/// - Parameter onLocationSelected: Completion handler returning a CLPlacemark
///   for the selected location
struct LocationSearchView: View {
    @State private var viewModel = LocationSearchViewModel()
    @State private var searchFocused = false
    @DebouncedState private var searchText = ""
    @Environment(\.dismiss) var dismiss

    var onLocationSelected: (CLPlacemark?) -> Void

    var body: some View {
        VStack {
            if viewModel.completions.isEmpty || searchText.isEmpty {
                VStack {
                    CurrentLocationButton { coordinate in
                        Task {
                            let result = await viewModel.resolve(coordinate)
                            onLocationSelected(result)
                            dismiss()
                        }
                    }

                    Text("or").padding(16)

                    Button("Enter an address") {
                        searchFocused = true
                    }.disabled(searchFocused)
                }
                .padding(24)
            } else {
                List(viewModel.completions, id: \.self) { completion in
                    Button {
                        Task {
                            if let result = await viewModel.resolve(completion)
                            {
                                onLocationSelected(result)
                                dismiss()
                            }
                        }
                    } label: {
                        VStack(alignment: .leading) {
                            Text(completion.title).bold()
                            Text(completion.subtitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Search Location")
        .searchable(
            text: $searchText,
            isPresented: $searchFocused,
            prompt: "Search an address, city, or ZIP code"
        )
        .onChange(of: searchText) {
            viewModel.search(for: searchText)
        }
    }
}

#Preview {
    NavigationView {
        LocationSearchView { _ in }
    }
}
