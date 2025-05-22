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
    @State var newList: Bool
    @State var loadingStores = false
    
    func move(from source: IndexSet, to destination: Int) {
        list.stores.move(fromOffsets: source, toOffset: destination)
    }
    
    init(list: GroceryList? = nil) {
        if let list = list {
            self.list = list
            newList = false
        } else {
            self.list = GroceryList()
            newList = true
        }
    }
    
    private func fetchStores() {
        guard list.location != nil else { return }
        Task {
            loadingStores = true
            try? await list.fetchStores()
            loadingStores = false
        }
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
                        }).disabled((loadingStores))
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
            
            
            
            
            Section("Shopping Preferences") {
                VStack(alignment: .leading) {
                    HStack() {
                        Text("Maximum stores to visit")
                        Spacer()
                        Text(list.maxStores == 0 ? "Unlimited" : "\(list.maxStores)")
                            .foregroundStyle(.secondary)
                    }
                    
                    Slider(value: .convert($list.maxStores), in: 0...10, step: 1)
                }
                
                Picker("Automatically select store when a product is found at multiple stores", selection: Binding(get: {
                    list.autoSelect.rawValue
                }, set: {
                    list.autoSelect = AutoSelect(rawValue: $0)!
                })) {
                    ForEach(AutoSelect.allCases, id: \.rawValue) { index in
                        Text(index.rawValue)
                            }
                        }
//                        .pickerStyle(.segmented)
            }
            
            Section {
                if list.location == nil {
                    Text("Select a location above to view stores")
                } else if loadingStores {
                    HStack {
                        ProgressView()
                        Text("Finding nearby stores...")
                    }
                } else if list.stores.isEmpty {
                    Text("No stores found, please try a different location")
                } else {
                    ForEach(list.stores) { store in
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
                    }.onMove(perform: move)
                }
            } header: {
                HStack {
                    Text("Stores").font(.footnote)
                    Spacer()
                    if !loadingStores && !list.stores.isEmpty {
                        Button("Sort by distance") {
                            list.stores.sort { $0.distance ?? 1000 < $1.distance ?? 1000 }
                        }.font(.footnote)
                        EditButton().font(.footnote)
                    }
                }.buttonStyle(BorderlessButtonStyle()).font(.caption)
                
            } footer: {
                Text("Stores closer to the top of this list will be considered first when items are offered at the same price. If you disable a store, it will not be searched, but existing items will not be removed.")
            }
        }
        .navigationTitle(list.name == "" ? "New List" : list.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if newList {
                        modelContext.insert(list)
                    }
                    try? modelContext.save()
                    dismiss()
                }.disabled(list.invalidList)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        LocationSettings()
    }
}
