//
//  Constants.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/13/25.
//

enum Constants {
    static let UserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.4 Safari/605.1.15"
}

enum PriceSource: String, CaseIterable, Codable {
    case albertsons = "Albertsons"
    case traderjoes = "Trader Joe's"
//    case target = "Target"
    
    var scraper: Scraper.Type {
        switch self {
        case .albertsons:
            return SafewayScraper.self
//        case .target:
//            return TargetScraper.self
        case .traderjoes:
            return TraderJoesScraper.self
        }
    }
}
