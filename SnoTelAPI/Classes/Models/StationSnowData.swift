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
    public let date: Date
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
    
    static public func keyMap() -> Dictionary<String, String> {
        return [
            "Date": "date",
            "Snow Water Equivalent (in)": "snowH20Equivalent",
            "Change In Snow Water Equivalent (in)": "snowH20EquivalentDelta",
            "Snow Depth (in)": "snowDepth",
            "Change In Snow Depth (in)": "snowDepthDelta",
            "Precipitation Accumulation (in)": "precipAccumulation",
            "Air Temperature Observed (degF)": "airTemperature",
        ] as Dictionary<String, String>
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
            
            if let acc = snowDataItem.snowDepthDelta, acc > 0.0, let h2oEquivalentDelta = snowDataItem.snowH20EquivalentDelta, h2oEquivalentDelta > 0.0 {
                
                // print("Accumulation: \(acc) \(snowDataItem.precipAccumulation) \(snowDataItem.snowH20EquivalentDelta)")
                totalSnow += acc // > 0.0 ? acc : 0.0
            }
        }
    }
    
    public static func snowDataByDate(for snowData: [SnowData]) -> Dictionary<String, [SnowData]> {
        let groupedData = Dictionary(grouping: snowData) { (snowData) -> String in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: snowData.date)
        }
        return groupedData
    }
    
        
}
