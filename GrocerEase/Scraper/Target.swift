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
            const html = document.documentElement.innerHTML;
            const apiMatch = html.match(/"apiKey":"(.*?)"/);
            
            return {
                api: apiMatch ? apiMatch[1] : null
            };
        })()
        """

        webView.evaluateJavaScript(js) { result, error in
            if let error = error {
                self.setupContinuation?.resume(throwing: error)
                return
            }

            guard let dict = result as? [String: Any],
                  let api = dict["api"] as? String else {
//                if !self.firstLoadComplete {
//                    self.firstLoadComplete = true
//                    return
//                } else {
                    self.setupContinuation?.resume(throwing: "Couldn't retrieve required Target API keys")
                    return
//                }
            }

            self.apiKey = api
            print(self.apiKey)
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
        return []
    }
    
    func searchItems(query: String, store: GroceryStore) async throws -> [GroceryItem] {
        throw "Not implemented"
    }
    
    
 
    
}
