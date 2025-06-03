//
//  ListSettingsViewModel.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/30/25.
//

import CoreLocation
import SwiftData
import SwiftUI

@Observable
final class ListSettingsViewModel {
    var list: GroceryList
    var stores: [GroceryStore] = []
    var loadingText: String?
    var showingAlert = false

    let newList: Bool

    init(list: GroceryList?) {
        if let list {
            self.list = list
            self.stores = list.stores
            self.newList = false
        } else {
            self.list = GroceryList()
            self.newList = true
        }
    }

    var rejectSave: Bool {
        list.name.isEmpty || list.location == nil || stores.isEmpty
            || !stores.contains(where: \.enabled)
    }

    func fetchStores(from placemark: CLPlacemark) {
        guard let coordinate = placemark.location?.coordinate,
            let postalCode = placemark.postalCode
        else {
            return
        }

        list.location = coordinate
        list.address = placemark.formattedAddress
        list.zipcode = postalCode
        fetchStores()
    }

    func fetchStores() {
        Task {
            guard let location = list.location else {
                print("Tried to fetch stores before setting location")
                return
            }
            stores = []
            for source in PriceSource.allCases {
                await MainActor.run {
                    loadingText = "Finding \(source.rawValue) stores..."
                }
                let results = try? await source.scraper.shared.findStores(
                    for: list
                )
                stores.append(contentsOf: results ?? [])
            }
            for store in stores {
                await store.setLocation()
                store.setDistance(from: location)
            }
            sortByDistance()
            await MainActor.run {
                loadingText = nil
            }
        }
    }

    func sortByDistance() {
        stores.sort {
            ($0.distance ?? .greatestFiniteMagnitude)
                < ($1.distance ?? .greatestFiniteMagnitude)
        }
        saveOrder()
    }

    func sortByBrand() {
        stores.sort {
            let brandCompare = $0.brand.localizedCaseInsensitiveCompare(
                $1.brand
            )
            if brandCompare == .orderedSame {
                return ($0.distance ?? .greatestFiniteMagnitude)
                    < ($1.distance ?? .greatestFiniteMagnitude)
            }
            return brandCompare == .orderedAscending
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
}
