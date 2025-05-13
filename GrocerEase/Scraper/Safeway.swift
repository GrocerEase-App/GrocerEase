//
//  Safeway.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/12/25.
//

import UIKit
import WebKit

// Architectural Technical Debt Consideration:
// This code will likely be reused! Once we figure out what parts of the following
// code can be applied to other scrapers, it should be moved to a separate file to
// be reused to avoid redundancy/double-maintenance.

final class HeadlessSafewayScraper: NSObject, WKScriptMessageHandler {
    private var webView: WKWebView!
    private let searchQuery: String
    private let handlerName = "xhrHandler"
    private var continuation: CheckedContinuation<Any, Error>?
    private var hiddenWindow: UIWindow?

    // Initializer for this class, requires a search query.
    // At some point, will also probably require a store ID.
    // Right now, it defaults to prices at "closest" store based on IP.
    init(searchQuery: String) {
        self.searchQuery = searchQuery
        super.init()
    }

    // ChatGPT's janky async/await wrapper. Probably can be improved with proper Swift 6.
    func run() async throws -> Any {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            self.setupInvisibleWebView()
        }
    }

    private func setupInvisibleWebView() {
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()

        // This is the JavaScript that intercepts the API call.
        // It's implementation can probably be improved.
        // IMPORTANT: This only works for XHR requests! (which Safeway uses)
        // I haven't tested it with JS "fetch()" requests, which will likely
        // require a different implementation for websites that use it.
        let xhrHook = """
        (function() {
            const open = XMLHttpRequest.prototype.open;
            const send = XMLHttpRequest.prototype.send;
            const setRequestHeader = XMLHttpRequest.prototype.setRequestHeader;

            XMLHttpRequest.prototype.open = function(method, url) {
                this._method = method;
                this._url = url;
                this._requestHeaders = {};
                open.apply(this, arguments);
            };

            XMLHttpRequest.prototype.setRequestHeader = function(header, value) {
                this._requestHeaders[header] = value;
                setRequestHeader.apply(this, arguments);
            };

            XMLHttpRequest.prototype.send = function(body) {
                this._body = body;
                this.addEventListener('load', () => {
                    try {
                        webkit.messageHandlers.xhrHandler.postMessage({
                            method: this._method,
                            url: this._url,
                            headers: this._requestHeaders,
                            body: typeof this._body === 'string' ? this._body : null,
                            status: this.status
                        });
                    } catch (e) {}
                });
                send.apply(this, arguments);
            };
        })();
        """

        // Attach the script to the headless browser
        let script = WKUserScript(source: xhrHook, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(script)
        userContentController.add(self, name: handlerName)

        // IMPORTANT: Make sure to store cookies between requests!
        // "nonPersistent" means it won't store cookies after the scraping is complete
        // but it will store them throughout the process, which is exactly what we need.
        config.userContentController = userContentController
        config.websiteDataStore = .nonPersistent()
        
        // Create the headless browser instance
        webView = WKWebView(frame: .zero, configuration: config)
        
        // ALSO IMPORTANT: A believable user agent is crucial for getting the API to accept us!
        webView.customUserAgent = """
        Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.4 Safari/605.1.15
        """

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

        loadInitialPage()
    }

    // Make the initial request to gather necessary cookies
    // You can find this URL by simply making a search on Safeway's website, then
    // copying it from the URL bar. Then replace the query with a variable as shown.
    private func loadInitialPage() {
        guard let encoded = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.safeway.com/shop/search-results.html?q=\(encoded)&tab=products") else {
            continuation?.resume(throwing: NSError(domain: "Invalid query", code: 0))
            return
        }
        let request = URLRequest(url: url)
        DispatchQueue.main.async {
            self.webView.load(request)
        }
    }

    // This is the function that the JavaScript from before is able to call.
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // First, we want to gather necessary information from the call.
        guard message.name == handlerName, // First, make sure the correct handler is being called.
              let body = message.body as? [String: Any], // Currently unused.
              let urlString = body["url"] as? String, // This is the url of the request
              
              // We want to check if the returned URL is the relavant API enpoint.
              // Doesn't need to match entirely, but needs to be specific enough to be unique!
              // If the endpoint matches, keep going, otherwise ignore the call and return.
              urlString.contains("/pgmsearch/v1/search/products"),
              
              // Safeway makes relative calls, so we have to add the host, subdomain, and scheme.
              // Other platforms may not need this, so be careful not to add it if not necessary.
              let url = URL(string: "https://www.safeway.com" + urlString),
              let method = body["method"] as? String // HTTP method, although it will almost certainly be GET
        else {
            return
        }

        // Debug print, should remove in production
        print("🎣 Intercepted XHR for \(url)")

        // For security reasons, we can't intercept the result of the request (as far as I can tell).
        // However, we can send it again ourselves! So far Safeway has let me repeat requests without limit.
        // So here we start building our own API request with our bot protection bypass cookies injected.
        var request = URLRequest(url: url) // Create request with URL
        request.httpMethod = method // Set method (although like I said, almost always GET)

        // Inject headers from our intercepted request
        if let headers = body["headers"] as? [String: String] {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        // Inject body from our intercepted request (for Safeway, this is unused)
        if let requestBody = body["body"] as? String {
            request.httpBody = requestBody.data(using: .utf8)
        }

        // Next we need to get the cookies from the headless browser
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            
            // Inject the cookies into the request
            let cookieHeader = HTTPCookie.requestHeaderFields(with: cookies)
            for (key, value) in cookieHeader {
                request.setValue(value, forHTTPHeaderField: key)
            }

            // Execute ("resume") the request
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                // This really needs to be cleaned up. It should only ever return JSON or Error.
                // TODO: Implement SwiftyJSON library and better error handling.
                
                if let error = error {
                    self.continuation?.resume(throwing: error)
                    return
                }

                guard let data = data else {
                    self.continuation?.resume(throwing: NSError(domain: "No data", code: 0))
                    return
                }

                if let json = try? JSONSerialization.jsonObject(with: data) {
                    self.continuation?.resume(returning: json)
                } else if let raw = String(data: data, encoding: .utf8) {
                    self.continuation?.resume(returning: raw)
                } else {
                    self.continuation?.resume(throwing: NSError(domain: "Unparseable response", code: 0))
                }
            }.resume()
        }
    }
}
