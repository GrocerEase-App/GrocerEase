//
//  ScraperTests.swift
//  GrocerEaseTests
//
//  Created by Finlay Nathan on 6/2/25.
//

import Testing
@testable import GrocerEase

@Suite(.serialized) // Tests must not be run in parallel due to async architecture.
struct ScraperTests {
    
    func testFindStores(source: PriceSource) async throws -> [GroceryStore] {
        return try await source.scraper.shared.findStores(for: GroceryList.sample)
    }
    
    @Test func testFindStoresAlbertsons() async throws {
        let stores = try await testFindStores(source: .albertsons)
        #expect(!stores.isEmpty)
    }
    
    @Test func testSearchAlbertsons() async throws {
        let store = GroceryStore(storeNum: "799", brand: "Safeway", source: .albertsons)
        let items = try await store.search(for: "Banana")
        #expect(!items.isEmpty)
    }
    
    @Test func testFindStoresTarget() async throws {
        let stores = try await testFindStores(source: .albertsons)
        #expect(!stores.isEmpty)
    }
    
    @Test func testSearchTarget() async throws {
        let store = GroceryStore(storeNum: "3410", brand: "Target", source: .target)
        store.list = GroceryList.sample
        let items = try await store.search(for: "Banana")
        #expect(!items.isEmpty)
    }
    
    @Test func testFindStoresTraderJoes() async throws {
        let stores = try await testFindStores(source: .albertsons)
        #expect(!stores.isEmpty)
    }
    
    @Test func testSearchTraderJoes() async throws {
        let store = GroceryStore(storeNum: "193", brand: "Trader Joe's", source: .traderjoes)
        let items = try await store.search(for: "Banana")
        #expect(!items.isEmpty)
    }

}
