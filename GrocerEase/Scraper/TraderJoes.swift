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
import CoreLocation

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
                "storeCode": store.storeNum
            ]
        ]
        
        var request = try URLRequest(url: base, method: .post)
        request.setValue(Constants.UserAgent, forHTTPHeaderField: "User-Agent")
        request.httpBody = try JSON(body).rawData()
        
        let json = try await AF.request(request)
            .serializingDecodable(JSON.self)
            .value
        
        let items = json["data"]["products"]["items"].arrayValue.enumerated()
        return items.map { i, doc in
            let item = GroceryItem(name: doc["item_title"].stringValue, store: store)
            item.upc     = doc["upc"].string
            item.sku = doc["sku"].string
            item.inStock = doc["availability"].string == "1"
            item.price   = doc["price_range"]["minimum_price"]["final_price"]["value"].doubleValue
            item.unitString = doc["sales_uom_description"].string
            item.unitQuantity = doc["sales_size"].double
            if let weight = item.unitQuantity, let price = item.price {
                item.unitPrice = price / weight
            }
            if let categories = doc["category_hierarchy"].array {
                let names = categories.map { $0["name"].stringValue }
                item.department = names.last
            }
            item.soldByWeight = false
            item.url = URL(string: "https://www.traderjoes.com/\(doc["url_key"].stringValue)")
            item.imageUrl = URL(string: "https://www.traderjoes.com\(doc["primary_image"].stringValue)")
            item.searchRank = i
            return item
        }
    }
    
    
    // MARK: – Nearby stores
    func getNearbyStores(latitude: Double, longitude: Double, radius: Double, list: GroceryList) async throws -> [GroceryStore] {
        
        let body: [String: Any] = [
            "request":[
                "appkey":Constants.TraderJoesAPIKey,
                "formdata":[
                    "geoip":false,
                    "dataview":"store_default",
                    "limit":20,
                    "geolocs":[
                        "geoloc":[
                            [
                                "addressline":"",
                                "country":"",
                                "latitude":String(latitude),
                                "longitude":String(longitude)
                            ]
                        ]
                    ],
                    "searchradius":radius,
                    "where":[
                        "warehouse":[
                            "distinctfrom":"1"
                        ]
                    ],
                    "false":"0"
                ]
            ]
        ]
        
        let base = URL(string: "https://alphaapi.brandify.com/rest/locatorsearch")!
        
        var request = try URLRequest(url: base, method: .post)
        request.setValue(Constants.UserAgent, forHTTPHeaderField: "User-Agent")
        request.httpBody = try JSON(body).rawData()
        
        let json = try await AF.request(request)
            .serializingDecodable(JSON.self)
            .value
        
        if let stores = json["response"]["collection"].array {
            return stores.map { store in
                let address = [
                    store["address1"].stringValue,
                    store["address2"].stringValue,
                    store["city"].stringValue,
                    store["state"].stringValue,
                    store["postalcode"].stringValue
                ].joined(separator: ", ")
                
                return GroceryStore(
                    storeNum: store["clientkey"].stringValue,
                    brand: "Trader Joe's",
                    location: CLLocationCoordinate2D(latitude: Double(store["latitude"].stringValue)!, longitude: Double(store["longitude"].stringValue)!),
                    address: address,
                    source: .traderjoes,
                    list: list
                )
            }
        } else {
            return []
        }
    }
}
