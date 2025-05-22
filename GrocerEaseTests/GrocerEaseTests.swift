//
//  GrocerEaseTests.swift
//  GrocerEaseTests
//
//  Created by Finlay Nathan on 4/21/25.
//

import Testing
@testable import GrocerEase
import Foundation
import CoreLocation

struct GrocerEaseTests {

    @Test func testSearchSafeway() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let list = GroceryList()
        let store = GroceryStore(storeNum: "799", brand: "Safeway", source: .albertsons, list: list)
        let results = try await store.source.scraper.shared.searchItems(query: "chips", store: store)
        #expect(!results.isEmpty)
        
    }
    
    @Test func testSearchTraderJoes() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let list = GroceryList()
        let store = GroceryStore(storeNum: "193", brand: "Trader Joe's", source: .traderjoes, list: list)
        let results = try await store.source.scraper.shared.searchItems(query: "chips", store: store)
        print(results)
        #expect(!results.isEmpty)
    }
    
    @Test func testSearchTarget() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let list = GroceryList()
        let store = GroceryStore(storeNum: "3410", brand: "Target", source: .target, list: list)
        let results = try await store.source.scraper.shared.searchItems(query: "chips", store: store)
        print(results.map{$0.name})
        #expect(!results.isEmpty)
    }
    
    @Test func findStoreTarget() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let list = GroceryList()
        let results = try await TargetScraper.shared.getNearbyStores(latitude: 0, longitude: 0, radius: 10, list: list)
        print(results.map{$0.address})
        #expect(!results.isEmpty)
    }
    
    @Test func testLocationDistance() async throws {
        let point1 = CLLocationCoordinate2D(latitude: 32.6514, longitude: -161.4333)
        let point2 = CLLocationCoordinate2D(latitude: 37.3318, longitude: -122.0310)
        let distance = point1.distanceInMiles(to: point2)
        if let distance = distance {
            #expect(Int(distance) == 2242)
        } else {
            #expect(Bool(false))
        }
    }
    
    @Test func addressToLocation() async throws {
        let location = await CLLocationCoordinate2D(address: "117 Morrissey Blvd, Santa Cruz, CA, US 95060")
        if let location = location {
            #expect(location.latitude == 36.9821234 && location.longitude == -122.0074933)
        } else {
            #expect(Bool(false))
        }
    }
    
    @Test func addressPartsToString() async throws {
        let formatted = String(
            line1: "123 Main St",
            line2: "Apt 4B",
            city: "Boston",
            state: "MA",
            zip: "02118",
            country: "USA"
        )
        #expect(formatted == "123 Main St Apt 4B, Boston, MA 02118, USA")
    }
    
    @Test func placemarkToAddressString() async throws {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.geocodeAddressString("1 Infinite Loop")
        let placemark = placemarks.first
        if let placemark = placemark {
            #expect(placemark.formattedAddress == "1 Infinite Loop, Cupertino, CA 95014, United States")
        }
    }
    
    @Test func testGetTraderJoesStores() async throws {
        // Inconsistent behavior: network request fails or receives unreadable response
        // Cannot replicate outside simulator
        let list: GroceryList = .sample
        let stores = try await TraderJoesScraper.shared.getNearbyStores(latitude: list.location!.latitude, longitude: list.location!.longitude, radius: 10, list: list)
        print(stores.map{$0.address})
        #expect(!stores.isEmpty)
    }

}
