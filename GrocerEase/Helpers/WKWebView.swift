//
//  WKWebView.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/13/25.
//

import UIKit
import WebKit

extension WKWebView {
    func getAllCookiesAsync() async -> [HTTPCookie] {
        await withCheckedContinuation { continuation in
            self.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                continuation.resume(returning: cookies)
            }
        }
    }
}
