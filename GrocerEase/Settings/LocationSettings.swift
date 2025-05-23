//
//  LocationSettings.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/14/25.
//

import SwiftUI
import CoreLocation
import MapKit
import SwiftData

struct LocationSettings: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.editMode) var editMode
    
    @State var list: GroceryList
    @State var stores: [GroceryStore] = []
    @State var newList: Bool
    @State var loadingStores: String?
    @State var showingAlert = false
    
    var rejectSave: Bool {
        list.name == "" || list.location == nil || stores.isEmpty || !stores.contains(where: {$0.enabled})
    }
    
    func saveAndExit() {
        if stores.filter({ $0.enabled }).count > 8 && !showingAlert {
            showingAlert = true
        } else {
            if newList {
                for store in stores {
                    store.list = self.list
                }
                modelContext.insert(list)
            }
            try? modelContext.save()
            dismiss()
        }
    }
    
    init(list: GroceryList? = nil) {
        if let list = list {
            self.list = list
            self.stores = list.stores
            newList = false
        } else {
            self.list = GroceryList()
            newList = true
        }
    }
    
    private func fetchStores() {
        Task {
            guard let location = list.location else {
                print("Tried to fetch stores before setting location")
                return
            }
            self.stores.removeAll()
            for source in PriceSource.allCases {
                loadingStores = "Finding \(source.rawValue) stores..."
                let scraper = source.scraper.shared
                let results = try? await scraper.findStores(for: list)
                stores.append(contentsOf: results ?? [])
            }
            for store in self.stores {
                await store.setLocation()
                store.setDistance(from: location)
            }
            self.sortByDistance()
            loadingStores = nil
        }
    }
    
    func sortByDistance() {
        stores.sort { $0.distance ?? .greatestFiniteMagnitude < $1.distance ?? .greatestFiniteMagnitude }
        saveOrder()
    }
    
    func sortByBrand() {
        stores.sort {
            let brandComparison = $0.brand.localizedCaseInsensitiveCompare($1.brand)
            if brandComparison == .orderedSame {
                return ($0.distance ?? .greatestFiniteMagnitude) < ($1.distance ?? .greatestFiniteMagnitude)
            } else {
                return brandComparison == .orderedAscending
            }
        }
        saveOrder()
    }

    
    func saveOrder() {
        for (index, store) in stores.enumerated() {
                store.sortOrder = index
            }
    }
    
    func selectAll() {
        stores.forEach { $0.enabled = true }
    }
    
    func deselectAll() {
        stores.forEach { $0.enabled = false }
    }
    
    var body: some View {
        
        Form {
            
            Section("List Details") {
                HStack {
                    Text("Name")
                    TextField("New List", text: $list.name)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.secondary)
                }
            }
            
            if newList {
                Section {
                    NavigationLink {
                        LocationSearchView { coords, desc, zip in
                            list.location = coords
                            list.address = desc
                            list.zipcode = zip
                            fetchStores()
                        }
                    } label: {
                        HStack {
                            Text("Location")
                            Spacer()
                            Text(list.address ?? "Not Set")
                                .foregroundStyle(.secondary)
                            
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        HStack() {
                            Text("Radius")
                            Spacer()
                            Text("\(String(format: "%.0f", list.radius)) mile" + (list.radius == 1 ? "" : "s"))
                                .foregroundStyle(.secondary)
                        }
                        
                        Slider(value: $list.radius, in: 1...50, step: 1, onEditingChanged: { value in
                            if !value {
                                fetchStores()
                            }
                        }).disabled((loadingStores != nil))
                    }
                    
                    
                } header: {
                    Text("Location")
                } footer: {
                    Text("Choose an origin location, such as your home, and a search radius to find nearby stores. Distance will be taken into consideration when calculating the most cost efficient store to visit. This location will be shared with stores. This cannot be changed later.")
                }
            } else {
                Section("Location") {
                    Text("Showing stores within \(String(format: "%.0f", list.radius)) mile\(list.radius == 1 ? "" : "s") of \(list.address ?? "unknown")")
                }
            }
            
            
            
            
            Section {
//                VStack(alignment: .leading) {
//                    HStack() {
//                        Text("Maximum stores to visit")
//                        Spacer()
//                        Text(list.maxStores == 0 ? "Unlimited" : "\(list.maxStores)")
//                            .foregroundStyle(.secondary)
//                    }
//                    
//                    Slider(value: .convert($list.maxStores), in: 0...10, step: 1)
//                }
                
                Picker("Automatically select store when a product is found at multiple stores", selection: Binding(get: {
                    list.autoSelect.rawValue
                }, set: {
                    list.autoSelect = AutoSelect(rawValue: $0)!
                })) {
                    ForEach(AutoSelect.allCases, id: \.rawValue) { index in
                        Text(index.rawValue)
                    }
                }
            } header: {
                Text("Shopping Preferences")
            } footer: {
                Text("The order of stores in the list below will be used as a tiebreaker. When custom is selected, the highest store in the list below will be chosen regardless of price or distance.")
            }
            
            Section {
                if list.location == nil {
                    Text("Select a location above to view stores")
                } else if let loadingStores = loadingStores {
                    HStack {
                        ProgressView()
                        Text(loadingStores)
                    }
                } else if stores.isEmpty {
                    Text("No stores found, please try a different location")
                } else {
                    
                    ForEach(stores.sorted(by: { $0.sortOrder < $1.sortOrder }), id: \.id) { store in
                        Toggle(isOn: Binding(
                            get: { store.enabled },
                            set: { newValue in
                                store.enabled = newValue
                            }
                        )) {
                            Button {
                                print("hey")
                            } label: {
                                VStack(alignment: .leading) {
                                    Text("\(store.brand) #\(store.storeNum) | \(String(format: "%.2f", store.distance ?? 0)) mile" + (store.distance ?? 0 == 1 ? "" : "s"))
                                    if let address = store.address {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                }
                            }
                        }
                    }.onMove { indices, newOffset in
                        var reordered = stores.sorted(by: { $0.sortOrder < $1.sortOrder })
                        reordered.move(fromOffsets: indices, toOffset: newOffset)

                        for (index, store) in reordered.enumerated() {
                            store.sortOrder = index
                        }
                        
                        stores = reordered
                    }
                    
                }
            } header: {
                HStack {
                    Text("Stores").font(.footnote)
                    Spacer()
                    if true {//loadingStores == nil && !stores.isEmpty {
                        Menu("Edit") {
                            Button("Sort by Brand", action: sortByBrand).textCase(nil)
                            Button("Sort by Distance", action: sortByDistance).textCase(nil)
                            Divider()
                            Button("Enable All", action: selectAll).textCase(nil)
                            Button("Disable All", action: deselectAll).textCase(nil)
                            Divider()
                            EditButton().font(.footnote).textCase(nil)
                        }
                    }
                }
                .buttonStyle(BorderlessButtonStyle()).font(.caption)
                
            } footer: {
                if !newList {
                    Text("If you disable a store, it will not be searched, but existing items will not be removed.")
                }
            }
        }
        .navigationTitle(list.name == "" ? "New List" : list.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveAndExit()
                }.disabled(rejectSave)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert("Too Many Stores", isPresented: $showingAlert, actions: {
            Button("Continue Anyway", role: .destructive) {
                saveAndExit()
            }
            Button("Reselect Stores", role: .cancel) {}
        }, message: {
            Text("Stores of the same brand within a close radius often have similar prices. The app will run faster if you only select a couple stores per brand.")
        })
    }
}

#Preview {
    NavigationView {
        LocationSettings()
    }
}
