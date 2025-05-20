//
//  GrocerEaseTests.swift
//  GrocerEaseTests
//
//  Created by Finlay Nathan on 4/21/25.
//

import Testing
@testable import GrocerEase
import Foundation
import TinyGraphQL

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
    
    @Test func testGraphQl() async throws {
        let originalquery = """
            query SearchProducts(
              $search,
              $pageSize,
              $currentPage,
              $storeCode,
              $availability,
              $published
            ) {
              products(
                search: $search
                filter: {
                  store_code: {eq: $storeCode},
                  published: {eq: $published},
                  availability: {match: $availability}
                }
                pageSize: $pageSize
                currentPage: $currentPage
              ) {
                items {
                  sku
                  name
                  retail_price
                  primary_image
                }
                total_count
              }
            }
            """
            
        let variables: [String : String] = ["storeCode": "232", "availability": "1", "published": "1", "search": "bagel", "currentPage": "1", "pageSize": "15"]
        
        let graphQL = GraphQL(
            url: URL(string: "https://www.traderjoes.com/api/graphql")!,
            headers: ["Content-Type": "application/json"]
        )
        
        let query = Query("SearchProducts", variables) {
            Mutation("products", ["search": ]){
                Field("filter"){
                    "store_code"
                    "published"
                    "availability"
                }
                "pageSize"
                "currentPage"
            }
            Field("items"){
                "sku"
                "name"
                "retail_price"
                "primary_image"
            }
            "total_count"
        }

        let urlRequest = graphQL.request(for: query)

        URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, error in
            print(data)
        }
        
    }

}
