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
                if let data = data {
                    if let dataString = String(data: data, encoding: .utf8) {
                        let lines = String.cleanCSV(string: dataString)
                        let objects = try JSONDecoder().decode(SnowData.self, fromCSV: lines.joined(separator: "\n"))
                        completionHandler(objects)
                    }
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
                        let lines = String.cleanCSV(string: dataString)
                        let objects = try JSONDecoder().decode(SnowData.self, fromCSV: lines.joined(separator: "\n"))
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
    
    
    // https://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customSingleStationReport/daily/549:NV:SNTL%7Cid=%22%22%7Cname/2013-01-15,2013-01-18/name,stationId,WTEQ::value,WTEQ::delta,SNWD::value,SNWD::delta,TAVG::delta,TAVG::prevValue?fitToScreen=false
    
    
    public func generateNWSURL(triplet: String, from startDate: Date, to endDate: Date) -> URL? {
        
        guard let urlComponents = URLComponents(string:
            """
            \(baseNWSAPIURL)/reportGenerator/view_csv/customSingleStationReport/hourly/
            \(triplet)|id=""|name/
            \(startDate.simpleDateString()),\(endDate.simpleDateString())/
            WTEQ::value,WTEQ::delta,SNWD::value,SNWD::delta,TAVG::delta,TAVG::prevValue
            """)
        else {
            return nil
        }
        
        return urlComponents.url
    }
    
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
        return decodedValue
    }
}
