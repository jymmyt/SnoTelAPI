//
//  Station.swift
//  Nimble
//
//  Created by Jim Terhorst on 2/12/20.
//

import Foundation

//public struct StationsResponse: Codable {
//    public let stations: [Station]
//}

typealias StationsResponse = [Station]

public struct Station: Codable, Equatable, Hashable {
    public let elevation: Double
    public let location: Location
    public let name: String
    public let timezone: Int
    public let triplet: String
    public let wind: Bool
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.triplet)
    }
    
    public static func == (lhs: Station, rhs: Station) -> Bool {
        return lhs.triplet == rhs.triplet
    }
    
    public func contains(query: String?) -> Bool {
        guard let query = query else { return true }
        guard !query.isEmpty else { return true }
        let lowerCasedQuery = query.lowercased()
        return name.lowercased().contains(lowerCasedQuery) || triplet.lowercased().contains(lowerCasedQuery)
    }
}

public struct Location: Codable {
    public let lat: Double
    public let lng: Double
}
