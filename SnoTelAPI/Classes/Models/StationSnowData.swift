//
//  StationSnowData.swift
//  Pods
//
//  Created by Jim Terhorst on 2/12/20.
//

import Foundation

public struct StationSnowData: Codable {
    public let stationInformation: Station
    public let data : [SnowData]
}

public struct SnowData: Codable, Convertable, Equatable, Hashable {
    public let date: String
    public let snowH20Equivalent: Double?
    public let snowH20EquivalentDelta: Double?
    public let snowDepth: Double?
    public let snowDepthDelta: Double?
    public let airTemperature: Double?
    public let precipAccumulation: Double?
    
    static public func doubleProperties() -> [String] {
        return [
            "snowH20Equivalent",
            "snowH20EquivalentDelta",
            "snowDepth",
            "snowDepthDelta",
            "airTemperature",
            "precipAccumulation"
        ]
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.date)
    }
    
    public static func == (lhs: SnowData, rhs: SnowData) -> Bool {
        return lhs.date == rhs.date
    }
    
    public static func totalSnow(for snowData: [SnowData]) -> Double {
        let totalSnow = 0.0
        return snowData.reduce(into: totalSnow) { (totalSnow, snowDataItem) in
            if let acc = snowDataItem.precipAccumulation {
                print("Accumulation: \(acc)")
                totalSnow += acc // > 0.0 ? acc : 0.0
            }
        }
    }
    
}
