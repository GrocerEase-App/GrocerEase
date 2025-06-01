//
//  Kroger.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/23/25.
//

import WebKit
import CoreLocation
import SwiftyJSON

final class KrogerScraper: NSObject, Scraper {
    
    var webView: WKWebView!
    var hiddenWindow: UIWindow?
    
    static var shared = KrogerScraper()
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        return
    }
    
    func loadInitialPage() async throws {
        return
    }
    
    func search(_ query: String, at store: GroceryStore) async throws -> [GroceryItem] {
        return []
    }
    
    func findStores(near location: CLLocationCoordinate2D, within radius: Double) async throws -> [GroceryStore] {
        return []
    }
    
}
