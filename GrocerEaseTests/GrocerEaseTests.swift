//
//  GrocerEaseTests.swift
//  GrocerEaseTests
//
//  Created by Finlay Nathan on 4/21/25.
//

import Testing
@testable import GrocerEase

struct GrocerEaseTests {

    @Test func testSearchSafeway() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let store = GroceryStore(id: "799", brand: "Safeway", source: .albertsons)
        let results = try await store.source.scraper.shared.searchItems(query: "chips", store: store)
        #expect(!results.isEmpty)
        
    }
    
    @Test func testSearchTraderJoes() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let store = GroceryStore(id: "193", brand: "Trader Joe's", source: .traderjoes)
        let results = try await store.source.scraper.shared.searchItems(query: "chips", store: store)
        print(results)
        #expect(!results.isEmpty)
    }

}
