//
//  DateConversions.swift
//  Pods
//
//  Created by Jim Terhorst on 2/13/20.
//

import Foundation

extension Date {
    
    static let simpleDateFormat: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    func simpleDateString() -> String {
        return Date.simpleDateFormat.string(from: self)
    }
}
