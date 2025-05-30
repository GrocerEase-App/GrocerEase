//
//  ListSettingsView.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/14/25.
//

import CoreLocation
import MapKit
import SwiftData
import SwiftUI

/// Provides a form to create or edit a GroceryList
///
/// - Parameter list: An existing GroceryList object to edit
struct ListSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel: ListSettingsViewModel

    init(list: GroceryList? = nil) {
        _viewModel = State(wrappedValue: ListSettingsViewModel(list: list))
    }

    func saveAction() {
        if viewModel.stores.count(where: { $0.enabled }) > 8
            && !viewModel.showingAlert
        {
            viewModel.showingAlert = true
        } else {
            if viewModel.newList {
                for store in viewModel.stores {
                    store.list = viewModel.list
                }
                modelContext.insert(viewModel.list)
            }
            try? modelContext.save()
            dismiss()
        }
    }

    var body: some View {
        Form {
            Section("List Details") {
                HStack {
                    Text("Name")
                    TextField("New List", text: $viewModel.list.name)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.secondary)
                }
            }

            if viewModel.newList {
                Section {
                    NavigationLink {
                        LocationSearchView { placemark in
                            if let placemark {
                                viewModel.fetchStores(from: placemark)
                            }
                        }
                    } label: {
                        HStack {
                            Text("Location")
                            Spacer()
                            Text(viewModel.list.address ?? "Not Set")
                                .foregroundStyle(.secondary)
                        }
                    }.disabled(viewModel.loadingText != nil)

                    VStack(alignment: .leading) {
                        HStack {
                            Text("Radius")
                            Spacer()
                            Text(
                                "\(String(format: "%.0f", viewModel.list.radius)) mile"
                                    + (viewModel.list.radius == 1 ? "" : "s")
                            )
                            .foregroundStyle(.secondary)
                        }

                        Slider(
                            value: $viewModel.list.radius,
                            in: 1...50,
                            step: 1,
                            onEditingChanged: { value in
                                if !value {
                                    viewModel.fetchStores()
                                }
                            }
                        )
                    }.disabled((viewModel.loadingText != nil))
                } header: {
                    Text("Location")
                } footer: {
                    Text(
                        "Choose an origin location, such as your home, and a search radius to find nearby stores. Distance will be taken into consideration when calculating the most cost efficient store to visit. This location will be shared with stores. This cannot be changed later."
                    )
                }
            } else {
                Section("Location") {
                    Text(
                        "Showing stores within \(String(format: "%.0f", viewModel.list.radius)) mile\(viewModel.list.radius == 1 ? "" : "s") of \(viewModel.list.address ?? "unknown")"
                    )
                }
            }

            Section {
                Picker(
                    "Automatically select store when a product is found at multiple stores",
                    selection: Binding(
                        get: {
                            viewModel.list.autoSelect.rawValue
                        },
                        set: {
                            viewModel.list.autoSelect = AutoSelect(
                                rawValue: $0
                            )!
                        }
                    )
                ) {
                    ForEach(AutoSelect.allCases, id: \.rawValue) { index in
                        Text(index.rawValue)
                    }
                }
            } header: {
                Text("Shopping Preferences")
            } footer: {
                Text(
                    "The order of stores in the list below will be used as a tiebreaker. When custom is selected, the highest store in the list below will be chosen regardless of price or distance."
                )
            }

            Section {
                if viewModel.list.location == nil {
                    Text("Select a location above to view stores")
                } else if let loadingStores = viewModel.loadingText {
                    HStack {
                        ProgressView()
                        Text(loadingStores)
                    }
                } else if viewModel.stores.isEmpty {
                    Text("No stores found, please try a different location")
                } else {
                    ForEach(
                        viewModel.stores.sorted(by: {
                            $0.sortOrder < $1.sortOrder
                        }),
                        id: \.id
                    ) { store in
                        StoreRowView(store: store)
                    }.onMove { indices, newOffset in
                        var reordered = viewModel.stores.sorted(by: {
                            $0.sortOrder < $1.sortOrder
                        })
                        reordered.move(
                            fromOffsets: indices,
                            toOffset: newOffset
                        )
                        for (index, store) in reordered.enumerated() {
                            store.sortOrder = index
                        }
                        viewModel.stores = reordered
                    }
                }
            } header: {
                HStack {
                    Text("Stores").font(.footnote)
                    Spacer()
                    if viewModel.loadingText == nil && !viewModel.stores.isEmpty
                    {
                        Menu("Options") {
                            Button(
                                "Sort by Brand",
                                action: viewModel.sortByBrand
                            ).textCase(nil)
                            Button(
                                "Sort by Distance",
                                action: viewModel.sortByDistance
                            ).textCase(nil)
                            Divider()
                            Button("Enable All", action: viewModel.selectAll)
                                .textCase(nil)
                            Button("Disable All", action: viewModel.deselectAll)
                                .textCase(nil)
                            Divider()
                            EditButton().font(.footnote).textCase(nil)
                        }
                    }
                }
                .buttonStyle(BorderlessButtonStyle()).font(.caption)
            } footer: {
                if !viewModel.newList {
                    Text(
                        "If you disable a store, it will not be searched, but existing items will not be removed."
                    )
                }
            }
        }
        .navigationTitle(
            viewModel.list.name == "" ? "New List" : viewModel.list.name
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: saveAction)
                    .disabled(viewModel.rejectSave)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert(
            "Too Many Stores",
            isPresented: $viewModel.showingAlert,
            actions: {
                Button(
                    "Continue Anyway",
                    role: .destructive,
                    action: saveAction
                )
                Button("Reselect Stores", role: .cancel) {}
            },
            message: {
                Text(
                    "Stores of the same brand within a close radius often have similar prices. Results will load faster if you only select a couple stores per brand."
                )
            }
        )
    }
}

#Preview {
    NavigationView {
        ListSettingsView()
    }
}
