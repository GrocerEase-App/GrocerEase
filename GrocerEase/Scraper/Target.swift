//
//  Target.swift
//  GrocerEase
//
//  Created by tddaniel on 5/16/25.
//

import UIKit
import WebKit
import SwiftyJSON
import HTMLEntities
import CoreLocation

final class TargetScraper: NSObject, Scraper {
    
    var webView: WKWebView!
    var hiddenWindow: UIWindow?
    var apiKey: String?
    let initialUrl = URL(string: "https://www.target.com/")!
    
    private var setupContinuation: CheckedContinuation<Void, Error>?
    
    // Upon initialization, create the invisible web view.
    override init() {
        super.init()
        DispatchQueue.main.async {
            self.setupInvisibleWebView()
        }
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Ignore page loads unrelated to the initial request
        if webView.url != initialUrl {
            return
        }
        
        let js = """
        (function() {
            return document.documentElement.innerHTML;
        })()
        """
        
        webView.evaluateJavaScript(js) { result, error in
            if let error = error {
                self.setupContinuation?.resume(throwing: error)
                return
            }
            
            guard let htmlString = result as? String else {
                self.setupContinuation?.resume(throwing: "Couldn't parse Target homepage html")
                return
            }
            
            // Target has a few different API keys
            // The one that appears the most is the one we need
            let pattern = #"\\"apiKey\\":\\"(.*?)\\""#
            let regex = try! NSRegularExpression(pattern: pattern)
            let matches = regex.matches(in: htmlString, range: NSRange(htmlString.startIndex..., in: htmlString))

            let keys = matches.compactMap {
                Range($0.range(at: 1), in: htmlString).map { String(htmlString[$0]) }
            }

            let mostCommon = keys.reduce(into: [:]) { counts, key in
                counts[key, default: 0] += 1
            }.max(by: { $0.value < $1.value })?.key
            
            self.apiKey = mostCommon
            self.setupContinuation?.resume(returning: ())
        }
    }
    
    static var shared: TargetScraper = TargetScraper()
    
    func loadInitialPage() async throws {
        if apiKey != nil{
            return
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.setupContinuation = continuation
            DispatchQueue.main.async {
                self.webView.load(URLRequest(url: self.initialUrl))
            }
        }
    }
    
    func findStores(near location: CLLocationCoordinate2D, within radius: Double) async throws -> [GroceryStore] {
        do {
            try await loadInitialPage()
        } catch {
            throw error
        }
        
        guard let apiKey = self.apiKey else {
            throw "Target subscription key not found"
        }
        
        guard let visitorCookie = await webView.getAllCookiesAsync().first(where: {
            $0.name == "visitorId" &&
            $0.domain.contains("target.com")
        }) else {
            throw "No visitor_id found."
        }
        
        guard let zip = try await location.fetchZipCode() else {
            throw "Zip code required for Target scraper"
        }
        
        let visitorId = visitorCookie.value
        
        let baseURLString = "https://redsky.target.com/redsky_aggregations/v1/web/nearby_stores_v1"

        var components = URLComponents(string: baseURLString)
        components?.queryItems = [
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "within", value: "\(Int(radius))"),
            URLQueryItem(name: "place", value: zip),
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "visitor_id", value: visitorId),
            URLQueryItem(name: "channel", value: "WEB"),
            URLQueryItem(name: "page", value: "/")
            
        ]
        
        guard let finalUrl = components?.url else {
            throw "Couldn't generate search URL in Safeway Scraper"
        }
        var request = URLRequest(url: finalUrl)
        
        let headers: [String: String] = [
            "Accept": "application/json, text/plain, */*",
            "User-Agent": Constants.UserAgent
        ]
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let cookies: [HTTPCookie] = await webView.getAllCookiesAsync()
        for (key, value) in HTTPCookie.requestHeaderFields(with: cookies) {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let apiResponse = try await URLSession.shared.json(for: request)
        
        let stores = apiResponse["data"]["nearby_stores"]["stores"].arrayValue.map { store in
            // ---------- Build full address ----------
            var address: String? = nil
            if let line1   = store["mailing_address"]["address_line1"].string,
               let city    = store["mailing_address"]["city"].string,
               let state   = store["mailing_address"]["region"].string,  // “CA”
               let country = store["mailing_address"]["country_code"].string,
               let zip     = store["mailing_address"]["postal_code"].string
            {
                address = String(line1: line1, line2: nil, city: city, state: state, zip: zip, country: country)
            }
            
            // ---------- Return GroceryStore ----------
            return GroceryStore(
                storeNum:      store["store_id"].stringValue,        // e.g. "3410"
                brand:   "Target",   // e.g. "Scotts Valley"
                address: address,
                source:  .target                               // update to your enum case
            )
        }

        return stores
    }
    
    func search(_ query: String, at store: GroceryStore) async throws -> [GroceryItem] {
        
        // Make sure subscription key is present
        do {
            try await loadInitialPage()
        } catch {
            throw error
        }
        
        guard let apiKey = self.apiKey else {
            throw "Target subscription key not found"
        }
        
        // Set up API call
        // Unlike previous commit, we are building the request ourselves.
        // This method is more prone to issues if Safeway decides to update their
        // API, but makes calls a lot faster on our end.
        let baseURLString = "https://redsky.target.com/redsky_aggregations/v1/web/plp_search_v2"
        
        // Find the cookie named "visitor_id" for target.com
        guard let visitorCookie = await webView.getAllCookiesAsync().first(where: {
            $0.name == "visitorId" &&
            $0.domain.contains("target.com")
        }) else {
            throw "No visitor_id found."
        }
        let visitorId = visitorCookie.value
        
        guard let zip = try await store.list?.location?.fetchZipCode() else {
            throw "Zip Code required for Target Scraper"
        }
        
        // Add query params
        var components = URLComponents(string: baseURLString)
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "channel", value: "WEB"),
            URLQueryItem(name: "count", value: "24"),
            URLQueryItem(name: "default_purchasability_filter", value: "true"),
            URLQueryItem(name: "include_review_summarization", value: "true"),
            URLQueryItem(name: "keyword", value: query),
            URLQueryItem(name: "new_search", value: "true"),
            URLQueryItem(name: "offset", value: "0"),
            URLQueryItem(name: "page", value: "/s/\(query)"),
            URLQueryItem(name: "platform", value: "desktop"),
            URLQueryItem(name: "pricing_store_id", value: store.storeNum),
            URLQueryItem(name: "scheduled_delivery_store_id", value: store.storeNum),
            URLQueryItem(name: "spellcheck", value: "true"),
            URLQueryItem(name: "store_ids", value: store.storeNum),
            URLQueryItem(name: "useragent", value: Constants.UserAgent),
            URLQueryItem(name: "visitor_id", value: visitorId),
            URLQueryItem(name: "zip", value: zip)
        ]
        
        // Finalize URL
        guard let finalUrl = components?.url else {
            throw "Couldn't generate search URL in Target Scraper"
        }
        var request = URLRequest(url: finalUrl)
        
        // Add headers to request
        let headers: [String: String] = [
            "Accept": "application/json, text/plain, */*",
            "User-Agent": Constants.UserAgent
        ]
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add cookies to request
        let cookies: [HTTPCookie] = await webView.getAllCookiesAsync()
        for (key, value) in HTTPCookie.requestHeaderFields(with: cookies) {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let apiResponse = try await URLSession.shared.json(for: request)
    
        // Map the products to a list of GroceryItems
        // This will need to be heavily expanded once we've finalized the GroceryItem model
        // Target.com parser — mirrors your Safeway mapping style
        let products = apiResponse["data"]["search"]["products"].arrayValue.enumerated()
        let items = products.map { i, product in
            let newItem = GroceryItem(
                name: product["item"]["product_description"]["title"].stringValue.htmlUnescape(), store: store
            )
            
            // --- Identifiers -------------------------------------------------------
            newItem.upc = nil                                   // Target feed has no UPC
            newItem.sku = product["tcin"].stringValue
            newItem.plu = nil                                   // Not applicable
            
            // --- SNAP eligibility --------------------------------------------------
            newItem.snap = product["item"]["compliance"]["is_snap_eligible"].boolValue
            
            // --- Location (not in this endpoint) -----------------------------------
            newItem.location = nil
            
            // --- Inventory status --------------------------------------------------
            newItem.inStock = nil                               // Stock not returned
            
            // --- Pricing -----------------------------------------------------------
            newItem.price = product["price"]["current_retail"].doubleValue
            newItem.unitPrice = nil                             // No unit-price field
            newItem.originalPrice = product["price"]["reg_retail"].doubleValue
            newItem.originalUnitPrice = nil
            newItem.unitString = nil                            // Assume “each” if nil
            
            // --- Limits / sales units ---------------------------------------------
            newItem.max = nil                                   // No max-purchase key
            newItem.soldByWeight = nil                          // Not indicated
            
            // --- Image -------------------------------------------------------------
            if let urlString = product["item"]["enrichment"]["images"]["primary_image_url"].string,
               let url = URL(string: urlString) {
                newItem.imageUrl = url
            }
            
            // --- Department (optional mapping) -------------------------------------
            if let deptId = product["item"]["merchandise_classification"]["department_id"].int {
                newItem.department = String(deptId)             // Map to enum if desired
            }
            
            // --- Store brand -------------------------------------------------------
            newItem.searchRank = i
            
            return newItem
        }

            
        return items
    }
    
    
    
    
}
