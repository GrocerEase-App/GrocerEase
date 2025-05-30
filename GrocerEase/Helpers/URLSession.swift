//
//  URLSession.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/30/25.
//

import Foundation
import SwiftyJSON

extension URLSession {
    /// Get a valid JSON response from a URLRequest.
    ///
    /// - Parameter request: A URLRequest to perform.
    /// - Throws: An error if the response is not an HTTP response, the
    ///   statusCode is not 200, or the data is not valid JSON.
    func json(for request: URLRequest) async throws -> JSON {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            print("Failed here")
            throw "Failed to fetch data from URLRequest"
        }
        return try JSON(data: data)
    }
}
