//
//  Target.swift
//  GrocerEase
//
//  Created by tddaniel on 5/16/25.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON

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
    
    func getNearbyStores(latitude: Double, longitude: Double, radius: Double) async throws -> [GroceryStore] {
        do {
            try await loadInitialPage()
        } catch {
            throw error
        }
        return []
    }
    
    func searchItems(query: String, store: GroceryStore) async throws -> [GroceryItem] {
        throw "Not implemented"
    }
    
    
    
    
}
