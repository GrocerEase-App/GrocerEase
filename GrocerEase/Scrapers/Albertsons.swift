//
//  Albertsons.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/12/25.
//

import CoreLocation
import SwiftyJSON
import UIKit
import WebKit

/// Albertsons Scraper implementation based on Scraper interface.
///
/// This class contains comments that explain the process of properly
/// implenenting Scraper
final class AlbertsonsScraper: NSObject, Scraper {

    // Define views
    var webView: WKWebView!
    var hiddenWindow: UIWindow?

    // Albertsons specific API keys that need to be retrieved
    var xapiKey: String?
    var apimKey: String?

    let initialUrl = URL(string: "https://www.albertsons.com/")!

    // Albertsons specific variable, explained later
    var firstLoadComplete = false

    // These are wrappers for Swift async
    private var setupContinuation: CheckedContinuation<Void, Error>?
    private var resultContinuation: CheckedContinuation<[GroceryItem], Error>?

    // The scraper is a singleton class, meaning it will be reused for
    // subsequent requests, speeding up requests and reducing space complexity.
    // This means we will have to check for cookie expiration though!
    static let shared = AlbertsonsScraper()

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

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Ignore page loads unrelated to the initial request
        if webView.url != initialUrl {
            return
        }

        // Script to extract necessary API keys from Albertsons website
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

        // Run script and save results
        webView.evaluateJavaScript(js) { result, error in
            if let error = error {
                self.setupContinuation?.resume(throwing: error)
                return
            }

            guard let dict = result as? [String: Any],
                let xapi = dict["xapi"] as? String,
                let apim = dict["apim"] as? String
            else {
                if !self.firstLoadComplete {
                    self.firstLoadComplete = true
                    return
                } else {
                    self.setupContinuation?.resume(
                        throwing:
                            "Couldn't retrieve required Albertsons API keys"
                    )
                    return
                }
            }

            self.xapiKey = xapi
            self.apimKey = apim
            self.setupContinuation?.resume(returning: ())
        }
    }

    func search(_ query: String, at store: GroceryStore) async throws
        -> [GroceryItem]
    {
        // Make sure subscription key is present
        do {
            try await loadInitialPage()
        } catch {
            throw error
        }

        guard let apimKey = self.apimKey else {
            throw "Albertsons subscription key not found"
        }

        // Set up API call
        let baseURLString =
            "https://www.albertsons.com/abs/pub/xapi/pgmsearch/v1/search/products"

        // Generate request ID: 3 random digits + milliseconds since epoch
        // This is specific to Albertsons
        let randomPrefix = String(format: "%03d", Int.random(in: 0...999))
        let msSinceEpoch = Int(Date().timeIntervalSince1970 * 1_000_000)
        let requestID = "\(randomPrefix)\(msSinceEpoch)"

        // Build URL query
        var components = URLComponents(string: baseURLString)
        components?.queryItems = [
            URLQueryItem(name: "request-id", value: requestID),
            URLQueryItem(name: "url", value: "https://www.albertsons.com"),
            URLQueryItem(name: "pageurl", value: "https://www.albertsons.com"),
            URLQueryItem(name: "pagename", value: "search"),
            URLQueryItem(name: "rows", value: "30"),
            URLQueryItem(name: "start", value: "0"),
            URLQueryItem(name: "search-type", value: "keyword"),
            URLQueryItem(name: "storeid", value: store.storeNum),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "sort", value: ""),
            URLQueryItem(name: "dvid", value: "web-4.1search"),
            URLQueryItem(name: "channel", value: "instore"),
        ]

        // Finalize URL
        guard let finalUrl = components?.url else {
            throw "Couldn't generate search URL in Albertsons Scraper"
        }
        var request = URLRequest(url: finalUrl)

        // Add headers to request
        let headers: [String: String] = [
            "Ocp-Apim-Subscription-Key": apimKey,
            "Accept": "application/json, text/plain, */*",
            "User-Agent": Constants.UserAgent,
        ]
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Add cookies to request
        let cookies: [HTTPCookie] = await webView.getAllCookiesAsync()
        for (key, value) in HTTPCookie.requestHeaderFields(with: cookies) {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Execute the request using the helper method in URLSession.swift
        let apiResponse = try await URLSession.shared.json(for: request)

        // Map the products to a list of GroceryItems
        // This will need to be heavily expanded once we've finalized the GroceryItem model
        let products = apiResponse["primaryProducts"]["response"]["docs"]
            .arrayValue.enumerated()
        let items = products.map { i, product in
            let newItem = GroceryItem(
                name: product["name"].stringValue,
                store: store
            )
            newItem.upc = product["upc"].stringValue
            newItem.sku = product["pid"].stringValue
            newItem.snap = product["snapEligible"].boolValue
            newItem.location = product["aisleLocation"].stringValue
            // newItem.locationLong = "\(product[""])" tbh i dont even know what to put here
            // albertsons literally has inch by inch coordinates of where the product is located
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

    func findStores(
        near location: CLLocationCoordinate2D,
        within radius: Double
    ) async throws -> [GroceryStore] {
        // Make sure subscription key is present
        do {
            try await loadInitialPage()
        } catch {
            throw error
        }

        guard let xapiKey = self.xapiKey else {
            throw "API key not set for Albertsons scraper."
        }

        // Similar process to search()

        let baseURLString =
            "https://www.albertsons.com/abs/pub/xapi/storeresolver/v2/all"

        var components = URLComponents(string: baseURLString)
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(location.latitude)),
            URLQueryItem(name: "longitude", value: String(location.longitude)),
            URLQueryItem(name: "excludeBanners", value: "none"),
            URLQueryItem(name: "size", value: "20"),
            URLQueryItem(name: "radius", value: String(radius)),
        ]

        guard let finalUrl = components?.url else {
            throw "Couldn't generate search URL in Albertsons Scraper"
        }
        var request = URLRequest(url: finalUrl)

        let headers: [String: String] = [
            "Ocp-Apim-Subscription-Key": xapiKey,
            "Accept": "application/json, text/plain, */*",
            "User-Agent": Constants.UserAgent,
        ]
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let cookies: [HTTPCookie] = await webView.getAllCookiesAsync()
        for (key, value) in HTTPCookie.requestHeaderFields(with: cookies) {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let apiResponse = try await URLSession.shared.json(for: request)

        let stores = apiResponse["instore"]["stores"].arrayValue.map { store in
            var address: String? = nil
            if let line1 = store["address"]["line1"].string,
                let city = store["address"]["city"].string,
                let state = store["address"]["state"].string,
                let country = store["address"]["country"].string,
                let zipcode = store["address"]["zipcode"].string
            {
                address = String(
                    line1: line1,
                    line2: nil,
                    city: city,
                    state: state,
                    zip: zipcode,
                    country: country
                )
            }
            return GroceryStore(
                storeNum: store["locationId"].stringValue,
                brand: store["domainName"].stringValue,
                address: address,
                source: .albertsons
            )
        }

        return stores

    }

}
