//
//  WholeFoods.swift
//  GrocerEase
//
//  Created by saamorro on 5/19/25.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON
import CoreLocation

final class WholeFoodsScraper: NSObject, Scraper {
    
    
    var webView: WKWebView!
    var hiddenWindow: UIWindow?
    let initialUrl = URL(string: "https://www.wholefoodsmarket.com/")!
    private var setupContinuation: CheckedContinuation<Void, Error>?
    var firstLoadComplete = false
    static var shared = WholeFoodsScraper()
    
    override init() {
        super.init()
        DispatchQueue.main.async {
            self.setupInvisibleWebView()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard webView.url == initialUrl else { return }
        firstLoadComplete = true
        self.setupContinuation?.resume(returning: ())
    }
    
    
    
    func loadInitialPage() async throws {
        if firstLoadComplete { return }
        return try await withCheckedThrowingContinuation { cont in
            self.setupContinuation = cont
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

    // Whole Foods doesn't require xapiKey, so we skip that check.

    let baseURL = "https://www.wholefoodsmarket.com/stores/search"
    
    var request = URLRequest(url: URL(string: baseURL)!)
    request.httpMethod = "POST"
    
    let headers: [String: String] = [
        "Accept": "application/json, text/plain, */*",
        "Content-Type": "application/json",
        "User-Agent": Constants.UserAgent
    ]
    
    for (key, value) in headers {
        request.setValue(value, forHTTPHeaderField: key)
    }

    // Add cookies from WebView
    let cookies = await webView.getAllCookiesAsync()
    for (key, value) in HTTPCookie.requestHeaderFields(with: cookies) {
        request.setValue(value, forHTTPHeaderField: key)
    }

    // Build POST body with location
    let body: [String: Any] = [
        "lat": location.latitude,
        "lng": location.longitude
    ]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)

    // Make request
    let apiResponse = try await AF.request(request).serializingDecodable(JSON.self).value

    // Parse and map stores
    let stores = apiResponse.arrayValue.compactMap { store -> GroceryStore? in
        let distance = store["distance"]["equivalentMeters"].doubleValue
        guard distance <= radius else { return nil }

        let id = store["storeId"].stringValue
        let brand = "wholefoods"
        let addressJSON = store["location"]["address"]

        guard let line1 = addressJSON["line1"].string,
              let city = addressJSON["city"].string,
              let state = addressJSON["state"].string,
              let zip = addressJSON["postalCode"].string,
              let country = addressJSON["country"].string else {
            return nil
        }

        let address = String(line1: line1, line2: nil, city: city, state: state, zip: zip, country: country)

        return GroceryStore(
            storeNum: id,
            brand: brand,
            address: address,
            source: .wholeFoods
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
        
        guard firstLoadComplete else {
            throw "Whole Foods subscription key not found"
        }
        let baseURLString = "https://www.wholefoodsmarket.com/api/search"
        
        var components = URLComponents(string: baseURLString)
        components?.queryItems = [
            URLQueryItem(name: "text", value: query),
            URLQueryItem(name: "store", value: store.storeNum),
            URLQueryItem(name: "limit", value: "30"),
            URLQueryItem(name: "offset", value: "0")
        ]
        guard let finalUrl = components?.url else {
            throw "Couldn't generate search URL in Whole Foods Scraper"
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
        
        // Execute the request using this beautiful combination of Alamofire and SwiftyJSON
        let apiResponse = try await AF.request(request).serializingDecodable(JSON.self).value
        let products = apiResponse["results"].arrayValue
        let items = products.map { product in
            let newItem = GroceryItem(name: product["name"].stringValue, store: store)
            newItem.price = product["regularPrice"].doubleValue
            newItem.url = product["slug"].url
            newItem.brand = product["brand"].stringValue
            if let url = URL(string: product["imageThumbnail"].stringValue) {
                newItem.imageUrl = url
            }
            
            return newItem
            
        }
        return items
    }
    
}
