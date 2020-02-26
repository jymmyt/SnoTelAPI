//
//  SnowtelService.swift
//  Nimble
//
//  Created by Jim Terhorst on 2/12/20.
//

import Foundation
import Combine
import SwiftCSV

@available(iOS 13.0, *)
public class SnotelStore {
    @available(iOS 13.0, *)
    @available(iOSApplicationExtension 13.0, *)
    
    public static let shared = SnotelStore()
    private let urlSession = URLSession.shared
    private let baseAPIURL = "http://api.powderlin.es"
    private let baseNWSAPIURL = "https://wcc.sc.egov.usda.gov"
    private var subscriptions = Set<AnyCancellable>()

    private let jsonDecoder: MyDecoder = {
       let jsonDecoder = MyDecoder()
       return jsonDecoder
    }()
    
    public func testURL() {
        guard let url = self.generateURL() else {
            print("Failed to generate URL")
            return
        }
        
        self.urlSession.dataTask(with: url) { (data, response, error) in
            print("Responded with \(response.debugDescription)")
            do {
                let json = try JSONDecoder().decode(StationsResponse.self, from: data!)
                print("Decoded:\(json)")
            } catch let err {
                print("Decode failed:\(err)")
            }
        }.resume()
    }
    
    public func testNWSURL(triplet: String, hours: Int, _ completionHandler: @escaping(([Any]) -> Void)) {
        guard let url = self.generateNWSURL(triplet: triplet, hours: hours) else {
            print("Failed to generate URL")
            return
        }
        
        self.urlSession.dataTask(with: url) { (data, response, error) in
            print("Responded with \(response.debugDescription)")
            do {
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    let objects = try self.jsonDecoder.decode(SnowData.self, fromCSV: dataString)
                    completionHandler(objects)
                }
            } catch let err {
                print("Decode failed:\(err)")
                completionHandler([Any]())
            }
        }.resume()
    }
    
    
    @available(iOS 13.0, *)
    public func fetchStationDetails(triplet: String, hours: Int) -> Future<[SnowData], SnotelStoreAPIError> {
        return Future<[SnowData], SnotelStoreAPIError> {[unowned self] promise in
            // Generate the url.  In this case there is not much to do, but want to use
            // this same pattern for other API endpoints
            guard let url = self.generateNWSURL(triplet: triplet, hours: hours) else {
                return promise(
                    .failure(.urlError(
                        URLError(URLError.unsupportedURL)
                        )))
            }
            
            self.urlSession.dataTaskPublisher(for: url).tryMap { (data, response) -> [SnowData] in
                guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                    throw SnotelStoreAPIError.responseError((response as? HTTPURLResponse)?.statusCode ?? 500)
                }
                do {
                    if let dataString = String(data: data, encoding: .utf8) {
                        let objects = try self.jsonDecoder.decode(SnowData.self, fromCSV: dataString)
                        return objects
                    }
                } catch let err {
                    print("Decode failed:\(err)")
                    return [SnowData]()
                }
                return [SnowData]()
                }.receive(on: RunLoop.main)
                .sink(receiveCompletion: { (completion) in
                    if case let .failure(error) = completion {
                        switch error {
                        case let urlError as URLError:
                            promise(.failure(.urlError(urlError)))
                        case let decodingError as DecodingError:
                            promise(.failure(.decodingError(decodingError)))
                        case let apiError as SnotelStoreAPIError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(.genericError))
                        }
                    }
                }, receiveValue: { promise(.success($0))
                }).store(in: &self.subscriptions)
        }
    }
    
    @available(iOS 13.0, *)
    public func fetchStations() -> Future<[Station], SnotelStoreAPIError> {
        return Future<[Station], SnotelStoreAPIError> {[unowned self] promise in
            
            // Generate the url.  In this case there is not much to do, but want to use
            // this same pattern for other API endpoints
            guard let url = self.generateURL() else {
                return promise(
                    .failure(.urlError(
                        URLError(URLError.unsupportedURL)
                        )))
            }
            
            // The stations API we are using is at : "http://api.powderlin.es"
            // They do not provide data by the hour there, so that is why the NWS report API
            // was used to get details for snowfall/snowpack for the stations.
            self.urlSession.dataTaskPublisher(for: url).tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                    throw SnotelStoreAPIError.responseError((response as? HTTPURLResponse)?.statusCode ?? 500)
                }
                return data
            }.decode(type: StationsResponse.self, decoder: self.jsonDecoder)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion:
                { (completion) in
                    if case let .failure(error) = completion {
                        switch error {
                        case let urlError as URLError:
                            promise(.failure(.urlError(urlError)))
                        case let decodingError as DecodingError:
                            promise(.failure(.decodingError(decodingError)))
                        case let apiError as SnotelStoreAPIError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(.genericError))
                        }
                    }
                },
                receiveValue: { promise(.success($0))
            }).store(in: &self.subscriptions)
            
        }
    }
    
    
    // https://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customSingleStationReport/daily/549:NV:SNTL%7Cid=%22%22%7Cname/2013-01-15,2013-01-18/name,stationId,TAVG::value,TMAX::value,TMIN::value,PREC::value,PRCP::value,SNWD::value?fitToScreen=false
    public func generateNWSURL(triplet: String, from startDate: Date, to endDate: Date) -> URL? {
        guard let urlComponents = URLComponents(string:
            """
            \(baseNWSAPIURL)/reportGenerator/view_csv/customSingleStationReport/hourly/\
            \(triplet)%7Cid=%22%22%7Cname/\
            \(startDate.simpleDateString()),\(endDate.simpleDateString())/\
            WTEQ::value,WTEQ::delta,SNWD::value,SNWD::delta,PREC::value,TOBS::value
            """)
        else {
            return nil
        }
        
        return urlComponents.url
    }
    
    // The report generator takes a frequency(hourly for our uses here and in the example url below), the station triplet(713:CO:SNTL),
    // then the hours range, which in this case is "-23,0", which gets the most recent 24 hours, then the strings that specify the values
    // we are looking for in the report.
    // https://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customSingleStationReport/hourly/start_of_period/713:CO:SNTL%7Cid=%22%22%7Cname/-23,0/TAVG::value,TMAX::value,TMIN::value,PREC::value,PRCP::value,SNWD::value?fitToScreen=false
    
    public func generateNWSURL(triplet: String, hours: Int) -> URL? {
        let urlString = """
        \(baseNWSAPIURL)/reportGenerator/view_csv/customSingleStationReport/hourly/start_of_period/\
        \(triplet)%7Cid=%22%22%7Cname/-\(hours),0/\
        WTEQ::value,WTEQ::delta,SNWD::value,SNWD::delta,PREC::value,TOBS::value
        """
        guard let urlComponents = URLComponents(string: urlString) else {
            return nil
        }
        return urlComponents.url
    }
    
    private func generateURL() -> URL? {
        guard let urlComponents = URLComponents(string: "\(baseAPIURL)/stations") else {
            return nil
        }
        
        return urlComponents.url
    }
    
    
}

class MyDecoder: JSONDecoder {
    override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        let decodedValue = try super.decode(type, from: data)
        self.dateDecodingStrategy = .formatted(Date.snotelAPIDateFormatter)
        return decodedValue
    }
}
