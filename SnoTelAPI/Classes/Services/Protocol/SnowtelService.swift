//
//  SnowtelService.swift
//  Nimble
//
//  Created by Jim Terhorst on 2/12/20.
//

import Foundation
import Combine

@available(iOSApplicationExtension 13.0, *)
protocol SnotelService {
    @available(iOS 13.0, *)
    func fetchStations() -> Future<[Station], SnotelStoreAPIError>
//    func fetchMovie(id: Int) -> Future<Movie, MovieStoreAPIError>
//    func searchMovie(query: String, params: [String: String]?) -> Future<[Movie], MovieStoreAPIError>
    
}


