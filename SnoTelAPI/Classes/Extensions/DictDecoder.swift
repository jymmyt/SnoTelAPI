//
//  DictDecoder.swift
//  Nimble
//
//  Created by Jim Terhorst on 2/13/20.
//  From : https://stackoverflow.com/questions/46327302/init-an-object-conforming-to-codable-with-a-dictionary-array/46327303
//

import Foundation
import SwiftCSV

public protocol Convertable {
    static func doubleProperties() -> [String]
}

public extension JSONDecoder {
    func decode<T>(_ type: T.Type, fromDict data: Dictionary<String, Any>) throws -> T where T : Codable, T: Convertable {
        var dataDecodable = Dictionary<String, Any>()
        
        // Best i can do with a generic way to do this.  The model is required to
        // advertise its doubles, so that we can swap the type that comes back as a String
        // from the guvmint api.
        let doubleKeys = type.doubleProperties()
        data.keys.forEach { (key) in
            if doubleKeys.contains(key) {
                dataDecodable[key] = Double(data[key] as! String)
            } else {
                dataDecodable[key] = data[key]
            }
        }
        
        let json = try JSONSerialization.data(withJSONObject: dataDecodable)
        return try self.decode(type.self, from: json)
    }
    
    func decode<T>(_ type: T.Type, fromCSV data: String) throws -> [T] where T: Codable, T: Convertable {
        let csvData = try CSV(string: data).namedRows
        let typedArray = try csvData.map { (dataAsDict) -> T in
            return try self.decode(type, fromDict: dataAsDict)
        }
        return typedArray
    }
}
    
