//
//  TraderJoes.swift
//  GrocerEase
//
//  Created by Arushi Tyagi on 5/19/25.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON

final class TraderJoesScraper: NSObject, Scraper {
    
    // MARK: – Scraper protocol
    var webView: WKWebView!
    var hiddenWindow: UIWindow?
    static let shared = TraderJoesScraper()
    
    // MARK: – Your discovered values
    let initialUrl = URL(string: "https://www.traderjoes.com/")!
    
    // MARK: – Init
    override init() {
        super.init()
//        DispatchQueue.main.async { self.setupInvisibleWebView() }
    }
    
    // MARK: – Load initial page & grab token if needed
    func loadInitialPage() async throws {
        return
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        return
    }
    
    // MARK: – Search items
    func searchItems(query: String, store: GroceryStore) async throws -> [GroceryItem] {

        let base = "https://www.traderjoes.com/api/graphql"

        let body: [String: Any] = [
            "operationName": "SearchProducts",
            "query": "query SearchProducts($search: String, $pageSize: Int, $currentPage: Int, $storeCode: String = \"193\", $availability: String = \"1\", $published: String = \"1\") {\n  products(\n    search: $search\n    filter: {store_code: {eq: $storeCode}, published: {eq: $published}, availability: {match: $availability}}\n    pageSize: $pageSize\n    currentPage: $currentPage\n  ) {\n    items {\n      category_hierarchy {\n        id\n        url_key\n        description\n        name\n        position\n        level\n        created_at\n        updated_at\n        product_count\n        __typename\n      }\n      item_story_marketing\n      product_label\n      fun_tags\n      primary_image\n      primary_image_meta {\n        url\n        metadata\n        __typename\n      }\n      other_images\n      other_images_meta {\n        url\n        metadata\n        __typename\n      }\n      context_image\n      context_image_meta {\n        url\n        metadata\n        __typename\n      }\n      published\n      sku\n      url_key\n      name\n      item_description\n      item_title\n      item_characteristics\n      item_story_qil\n      use_and_demo\n      sales_size\n      sales_uom_code\n      sales_uom_description\n      country_of_origin\n      availability\n      new_product\n      promotion\n      price_range {\n        minimum_price {\n          final_price {\n            currency\n            value\n            __typename\n          }\n          __typename\n        }\n        __typename\n      }\n      retail_price\n      nutrition {\n        display_sequence\n        panel_id\n        panel_title\n        serving_size\n        calories_per_serving\n        servings_per_container\n        details {\n          display_seq\n          nutritional_item\n          amount\n          percent_dv\n          __typename\n        }\n        __typename\n      }\n      ingredients {\n        display_sequence\n        ingredient\n        __typename\n      }\n      allergens {\n        display_sequence\n        ingredient\n        __typename\n      }\n      created_at\n      first_published_date\n      last_published_date\n      updated_at\n      related_products {\n        sku\n        item_title\n        primary_image\n        primary_image_meta {\n          url\n          metadata\n          __typename\n        }\n        price_range {\n          minimum_price {\n            final_price {\n              currency\n              value\n              __typename\n            }\n            __typename\n          }\n          __typename\n        }\n        retail_price\n        sales_size\n        sales_uom_description\n        category_hierarchy {\n          id\n          name\n          __typename\n        }\n        __typename\n      }\n      __typename\n    }\n    total_count\n    page_info {\n      current_page\n      page_size\n      total_pages\n      __typename\n    }\n    __typename\n  }\n}\n",
            "variables": [
                "availability": "1",
                "currentPage": 0,
                "pageSize": 15,
                "published": "1",
                "search": query,
                "storeCode": store.id
            ]
        ]
        
        var request = try URLRequest(url: base, method: .post)
        request.setValue(Constants.UserAgent, forHTTPHeaderField: "User-Agent")
        request.httpBody = try JSON(body).rawData()
        
        let json = try await AF.request(request)
            .serializingDecodable(JSON.self)
            .value
        
        print("TJ raw JSON →", json)
        
        let items = json["data"]["products"]["items"].arrayValue  // ← match TJ’s JSON key
        return items.map { doc in
            let item = GroceryItem(name: doc["name"].stringValue)
            item.upc     = doc["upc"].stringValue
            item.price   = doc["price"].doubleValue
            item.inStock = doc["inventoryAvailable"].boolValue
            if let url = URL(string: doc["imageUrl"].stringValue) {
                item.imageUrl = url
            }
            item.store = store.brand
            return item
        }
    }
    
    
    // MARK: – Nearby stores
    func getNearbyStores(latitude: Double, longitude: Double, radius: Double) async throws -> [GroceryStore] {
        return []
    }
}
