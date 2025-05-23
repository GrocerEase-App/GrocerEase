//
//  Scraper.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/13/25.
//

import WebKit
import CoreLocation

protocol Scraper: WKNavigationDelegate {
    var webView: WKWebView! { get set }
    var hiddenWindow: UIWindow? { get set }
    static var shared: Self { get }
    
    func setupInvisibleWebView()
    
    func loadInitialPage() async throws -> Void
    
    func findStores(for list: GroceryList) async throws -> [GroceryStore]
    
    func findStores(near location: CLLocationCoordinate2D, within radius: Double) async throws -> [GroceryStore]

    func search(_ query: String, at store: GroceryStore) async throws -> [GroceryItem]
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    
}

extension Scraper {
    func findStores(for list: GroceryList) async throws -> [GroceryStore] {
        guard let location = list.location else {
            throw "Location not set before calling findStores(for:)"
        }
        return try await self.findStores(near: location, within: list.radius)
    }
    
    func setupInvisibleWebView() {
        let config = WKWebViewConfiguration()
        
        // IMPORTANT: Make sure to store cookies between requests!
        // "nonPersistent" means it won't store cookies after the scraping is complete
        // but it will store them throughout the process, which is exactly what we need.
        config.websiteDataStore = .nonPersistent()
        
        // Create the headless browser instance
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        
        // ALSO IMPORTANT: A believable user agent is crucial for getting the API to accept us!
        webView.customUserAgent = Constants.UserAgent
        
        // A bunch of view garbage that makes the browser invisible to the user.
        let rootVC = UIViewController()
        rootVC.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: rootVC.view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: rootVC.view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: rootVC.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: rootVC.view.trailingAnchor)
        ])
        
        hiddenWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        hiddenWindow?.rootViewController = rootVC
        hiddenWindow?.windowLevel = UIWindow.Level.alert + 1
        hiddenWindow?.isHidden = false
    }
}
