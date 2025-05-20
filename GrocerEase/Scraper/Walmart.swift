//
//  Walmart.swift
//  GrocerEase
//
//  Created by saamorro on 5/19/25.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON

final class WalmartScraper: NSObject, Scraper {
    
    
    
    var webView: WKWebView!
    var hiddenWindow: UIWindow?
    let initialUrl = URL(string: "https://www.walmart.com")!
    private var setupContinuation: CheckedContinuation<Void, Error>?
    var firstLoadComplete = false
    static var shared = WalmartScraper()
    
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
    
    func getNearbyStores(latitude: Double, longitude: Double, radius: Double) async throws -> [GroceryStore] {
        return []
    }
    
    func searchItems(query: String, store: GroceryStore) async throws -> [GroceryItem] {
        return []
    }
    
    
}
