//
//  Safeway.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/12/25.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON

// Much simplified from previous commit!
final class SafewayScraper: NSObject, Scraper {
    
    var webView: WKWebView!
    var hiddenWindow: UIWindow?
    var xapiKey: String?
    var apimKey: String?
    let initialUrl = URL(string: "https://www.safeway.com/")!
    var firstLoadComplete = false
    
    // These are wrappers for Swift async
    private var setupContinuation: CheckedContinuation<Void, Error>?
    private var resultContinuation: CheckedContinuation<[GroceryItem], Error>?
    
    // The scraper is now a singleton class, meaning it will be reused for
    // subsequent requests, speeding up requests and reducing space complexity.
    // This means we will have to check for cookie expiration though!
    static let shared = SafewayScraper()
    
    // Upon initialization, create the invisible web view.
    override init() {
        super.init()
        DispatchQueue.main.async {
            self.setupInvisibleWebView()
        }
        
    }
    
    // I'm not sure if this is the best way to do this. Sets up an async callback
    // for when the subscription key has been retrieved.
    func loadInitialPage() async throws {
        if xapiKey != nil && apimKey != nil {
            return
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.setupContinuation = continuation
            DispatchQueue.main.async {
                self.webView.load(URLRequest(url: self.initialUrl))
            }
        }
    }
    
    func searchItems(query: String, store: GroceryStore) async throws -> [GroceryItem] {
        // Make sure subscription key is present
        do {
            try await loadInitialPage()
        } catch {
            throw error
        }
        
        guard let apimKey = self.apimKey else {
            throw "Safeway subscription key not found"
        }
        
        // Set up API call
        // Unlike previous commit, we are building the request ourselves.
        // This method is more prone to issues if Safeway decides to update their
        // API, but makes calls a lot faster on our end.
        let baseURLString = "https://www.safeway.com/abs/pub/xapi/pgmsearch/v1/search/products"
        
        // Generate request ID: 3 random digits + milliseconds since epoch
        let randomPrefix = String(format: "%03d", Int.random(in: 0...999))
        let msSinceEpoch = Int(Date().timeIntervalSince1970 * 1000000)
        let requestID = "\(randomPrefix)\(msSinceEpoch)"
        
        // Add query params
        var components = URLComponents(string: baseURLString)
        components?.queryItems = [
            URLQueryItem(name: "request-id", value: requestID),
            URLQueryItem(name: "url", value: "https://www.safeway.com"),
            URLQueryItem(name: "pageurl", value: "https://www.safeway.com"),
            URLQueryItem(name: "pagename", value: "search"),
            URLQueryItem(name: "rows", value: "30"),
            URLQueryItem(name: "start", value: "0"),
            URLQueryItem(name: "search-type", value: "keyword"),
            URLQueryItem(name: "storeid", value: store.storeNum),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "sort", value: ""),
            URLQueryItem(name: "dvid", value: "web-4.1search"),
            URLQueryItem(name: "channel", value: "instore")
        ]
        
        // Finalize URL
        guard let finalUrl = components?.url else {
            throw "Couldn't generate search URL in Safeway Scraper"
        }
        var request = URLRequest(url: finalUrl)
        
        // Add headers to request
        let headers: [String: String] = [
            "Ocp-Apim-Subscription-Key": apimKey,
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
        
        // Execute the request using this beautiful combination of Alamofire and SwiftyJSON
        let apiResponse = try await AF.request(request).serializingDecodable(JSON.self).value
        
        // Map the products to a list of GroceryItems
        // This will need to be heavily expanded once we've finalized the GroceryItem model
        let products = apiResponse["primaryProducts"]["response"]["docs"].arrayValue.enumerated()
        let items = products.map { i, product in
            let newItem = GroceryItem(name: product["name"].stringValue, store: store)
            newItem.upc = product["upc"].stringValue
            newItem.sku = product["pid"].stringValue
            newItem.snap = product["snapEligible"].boolValue
            newItem.location = product["aisleLocation"].stringValue
            // newItem.locationLong = "\(product[""])" tbh i dont even know what to put here
            // safeway literally has inch by inch coordinates of where the product is located
            newItem.inStock = product["inventoryAvailable"].stringValue == "1"
            newItem.price = product["price"].doubleValue
            newItem.unitPrice = product["pricePer"].doubleValue
            newItem.originalPrice = product["basePrice"].doubleValue
            newItem.originalUnitPrice = product["basePricePer"].doubleValue
            newItem.unitString = product["unitQuantity"].stringValue
            newItem.max = product["maxPurchaseQty"].intValue
            newItem.soldByWeight = product["sellByWeight"].stringValue != "I"
            newItem.department = product["departmentName"].string
            if let url = URL(string: product["imageUrl"].stringValue) {
                newItem.imageUrl = url
            }
            newItem.searchRank = i
            
            return newItem
        }
        
        return items
        
    }
    
    func getNearbyStores(latitude: Double, longitude: Double, radius: Double, list: GroceryList) async throws -> [GroceryStore] {
        // Make sure subscription key is present
        do {
            try await loadInitialPage()
        } catch {
            throw error
        }
        
        guard let xapiKey = self.xapiKey else {
            throw "Safeway subscription key not found"
        }
        
        let baseURLString = "https://www.safeway.com/abs/pub/xapi/storeresolver/v2/all"

        var components = URLComponents(string: baseURLString)
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "excludeBanners", value: "none"),
            URLQueryItem(name: "size", value: "20"),
            URLQueryItem(name: "radius", value: String(radius))
        ]
        
        guard let finalUrl = components?.url else {
            throw "Couldn't generate search URL in Safeway Scraper"
        }
        var request = URLRequest(url: finalUrl)
        
        let headers: [String: String] = [
            "Ocp-Apim-Subscription-Key": xapiKey,
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
        
        let apiResponse = try await AF.request(request).serializingDecodable(JSON.self).value
        
        let stores = apiResponse["instore"]["stores"].arrayValue.map { store in
            var address: String? = nil
            if let line1 = store["address"]["line1"].string,
               let city = store["address"]["city"].string,
               let state = store["address"]["state"].string,
               let country = store["address"]["country"].string,
               let zipcode = store["address"]["zipcode"].string
            {
                address = "\(line1), \(city), \(state), \(country) \(zipcode)"
            }
            return GroceryStore(storeNum: store["locationId"].stringValue, brand: store["domainName"].stringValue, address: address, source: .albertsons, list: list)
        }
        
        return stores
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Ignore page loads unrelated to the initial request
        if webView.url != initialUrl {
            return
        }

        let js = """
        (function() {
            const html = document.documentElement.innerHTML;
            const xapiMatch = html.match(/"xapiSubscriptionKey":"(.*?)"/);
            const apimMatch = html.match(/"apimProgramSubscriptionKey":"(.*?)"/);
            return {
                xapi: xapiMatch ? xapiMatch[1] : null,
                apim: apimMatch ? apimMatch[1] : null
            };
        })()
        """

        webView.evaluateJavaScript(js) { result, error in
            if let error = error {
                self.setupContinuation?.resume(throwing: error)
                return
            }

            guard let dict = result as? [String: Any],
                  let xapi = dict["xapi"] as? String,
                  let apim = dict["apim"] as? String else {
                if !self.firstLoadComplete {
                    self.firstLoadComplete = true
                    return
                } else {
                    self.setupContinuation?.resume(throwing: "Couldn't retrieve required Safeway API keys")
                    return
                }
            }

            self.xapiKey = xapi
            self.apimKey = apim
            self.setupContinuation?.resume(returning: ())
        }
    }
}
