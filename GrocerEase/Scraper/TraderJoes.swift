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
    private var setupContinuation: CheckedContinuation<Void, Error>?
    
    // (example) maybe the site uses a bearer token
    private var authToken: Bool = false
    
    // MARK: – Init
    override init() {
        super.init()
        DispatchQueue.main.async { self.setupInvisibleWebView() }
    }
    
    // MARK: – Load initial page & grab token if needed
    func loadInitialPage() async throws {
        if authToken { return }
        return try await withCheckedThrowingContinuation { cont in
            self.setupContinuation = cont
            DispatchQueue.main.async {
                self.webView.load(URLRequest(url: self.initialUrl))
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard webView.url == initialUrl else { return }
        authToken = true
        self.setupContinuation?.resume(returning: ())
    }
    
    // MARK: – Search items
    func searchItems(query: String, store: GroceryStore) async throws -> [GroceryItem] {
      // no authToken needed here, TJ’s search is public
      let base = "https://www.traderjoes.com/home/search.model.json"
      var comps = URLComponents(string: base)!
      comps.queryItems = [
        .init(name: "q",      value: query),
        .init(name: "global", value: "yes")
      ]

      var request = URLRequest(url: comps.url!)
      request.httpMethod = "GET"
      request.setValue("*/*",  forHTTPHeaderField: "Accept")
      request.setValue("https://www.traderjoes.com/home/search?q=\(query)&global=yes",
                       forHTTPHeaderField: "Referer")
      request.setValue(Constants.UserAgent,
                       forHTTPHeaderField: "User-Agent")

      let cookies = await webView.getAllCookiesAsync()
      for (k,v) in HTTPCookie.requestHeaderFields(with: cookies) {
        request.setValue(v, forHTTPHeaderField: k)
      }

      let json = try await AF.request(request)
                        .serializingDecodable(JSON.self)
                        .value

      print("TJ raw JSON →", json)
        
      let docs = json["docs"].arrayValue  // ← match TJ’s JSON key
      return docs.map { doc in
        var item = GroceryItem(name: doc["name"].stringValue)
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
        do {
            try await loadInitialPage()
        } catch {
            throw error
        }
        return []
    }
}
