//
//  StringUtilities.swift
//  Pods
//
//  Created by Jim Terhorst on 2/13/20.
//

import Foundation



public extension String {
    
    
    // Date,Snow Water Equivalent (in),Change In Snow Water Equivalent (in),Snow Depth (in),Change In Snow Depth (in),Change In Air Temperature Average (degF),Air Temperature Average Previous Year's Value (degF)
    
    // Date,Snow Water Equivalent (in),Change In Snow Water Equivalent (in),Snow Depth (in),Change In Snow Depth (in),Change In Air Temperature Average (degF),Air Temperature Average (degF),Precipitation Accumulation (in)
    
    static func cleanCSV(string: String, keyMap: Dictionary<String, String>) -> [String] {
        var lines = string.split { $0.isNewline }.map(String.init)
        if lines.count > 0 {
            lines = lines.filter({ (line) -> Bool in
                return !line.starts(with: "#")
            })
            let header = lines[0].components(separatedBy: ",")
            let titles = header.map { (title) -> String in
                return keyMap[title] ?? ""
            }
            lines.replaceSubrange(0...0, with: [titles.joined(separator: ",")])
            return lines
        } else {
            return [String]()
        }
    }
}
