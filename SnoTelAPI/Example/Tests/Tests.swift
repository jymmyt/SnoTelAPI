// https://github.com/Quick/Quick

import Quick
import Nimble
import SnoTelAPI
import SwiftCSV
import Combine

let SnowDataSampleCSV = """
#------------------------------------------------- WARNING --------------------------------------------
#
# The data you have obtained from this automated Natural Resources Conservation Service
# database are subject to revision regardless of indicated Quality Assurance level.
# Data are released on condition that neither the NRCS nor the United States Government
# may be held liable for any damages resulting from its use.
#
# Help and Tutorials: https://www.nrcs.usda.gov/wps/portal/wcc/home/dataAccessHelp/helpCenters/!ut/p/
#
# Support Contact: usdafpacbc@midatl.service-now.com
#
#------------------------------------------------------------------------------------------------------
#
# Reporting Frequency: Hourly
# Date Range: 2020-02-11 00:00 to 2020-02-13 11:00
#
# Data for the following site(s) are contained in this file:
#
#    SNOTEL 713: Red Mountain Pass, CO
#
# Data items provided in this file:
#
# Element Name                Value Type  Function Type  Function Duration  Base Data  Measurement Units   Sensor Depth  Element Code  Description
# Snow Water Equivalent       Value       None           Instantaneous      N/A        Inches              N/A           WTEQ          Depth of water that would theoretically result if the entire snowpack were melted instantaneously
# Snow Water Equivalent       Delta       None           Instantaneous      N/A        Inches              N/A           WTEQ          Depth of water that would theoretically result if the entire snowpack were melted instantaneously
# Snow Depth                  Value       None           Instantaneous      N/A        Inches              N/A           SNWD          Total snow depth
# Snow Depth                  Delta       None           Instantaneous      N/A        Inches              N/A           SNWD          Total snow depth
# Precipitation Accumulation  Value       None           Instantaneous      N/A        Inches              N/A           PREC          Water year accumulated precipitation
# Air Temperature Observed    Value       None           Instantaneous      N/A        Degrees fahrenheit  N/A           TOBS          Instantaneously observed air temperature
#
# Quality Control flags included:
#
# Flag    Name                Description
#  V      Valid               Validated Data
#  N      No Profile          No profile for automated validation
#  E      Edit                Edit, minor adjustment for sensor noise
#  B      Back Estimate       Regression-based estimate for homogenizing collocated Snow Course and Snow Pillow data sets
#  K      Estimate            Estimate
#  X      External Estimate   External estimate
#  S      Suspect             Suspect data
#
# Quality Assurance flags included:
#
# Flag    Name                Description
#  U      Unknown             Unknown
#  R      Raw                 No Human Review
#  P      Provisional         Preliminary Human Review
#  A      Approved            Processing and Final Review Completed
#
#------------------------------------------------------------------------------------------------------
#
# Red Mountain Pass (713)
# Colorado  SNOTEL Site - 11200 ft
# Reporting Frequency: Hourly; Date Range: 2020-02-11 00:00 to 2020-02-13 11:00
#
# As of: Feb 13, 2020 11:29:23 AM GMT-08:00
#
Date,Snow Water Equivalent (in),Change In Snow Water Equivalent (in),Snow Depth (in),Change In Snow Depth (in),Precipitation Accumulation (in),Air Temperature Observed (degF)
2020-02-11 00:00,16.9,0.0,65,0,17.0,5
2020-02-11 01:00,16.8,-0.1,65,0,17.0,5
2020-02-11 02:00,16.8,0.0,64,-1,17.0,8
2020-02-11 03:00,16.8,0.0,63,-1,17.0,8
2020-02-11 04:00,16.8,0.0,62,-1,17.0,7
2020-02-11 05:00,16.8,0.0,65,3,17.0,3
2020-02-11 06:00,16.8,0.0,65,0,17.1,3
2020-02-11 07:00,16.8,0.0,63,-2,17.0,4
2020-02-11 08:00,16.8,0.0,63,0,17.1,10
2020-02-11 09:00,16.8,0.0,62,-1,17.0,16
2020-02-11 10:00,16.8,0.0,63,1,17.0,21
2020-02-11 11:00,16.9,0.1,62,-1,17.0,24
2020-02-11 12:00,16.9,0.0,62,0,17.1,30
2020-02-11 13:00,16.9,0.0,62,0,17.0,29
2020-02-11 14:00,16.9,0.0,62,0,17.0,26
2020-02-11 15:00,16.9,0.0,62,0,17.0,25
2020-02-11 16:00,17.0,0.1,63,1,17.1,17
2020-02-11 17:00,16.9,-0.1,63,0,17.1,12
2020-02-11 18:00,16.9,0.0,63,0,17.1,8
2020-02-11 19:00,16.9,0.0,63,0,17.1,14
2020-02-11 20:00,16.9,0.0,63,0,17.1,10
2020-02-11 21:00,16.8,-0.1,63,0,17.1,6
2020-02-11 22:00,16.8,0.0,63,0,17.1,10
2020-02-11 23:00,16.8,0.0,63,0,17.1,6
2020-02-12 00:00,16.8,0.0,63,0,17.1,6
2020-02-12 01:00,16.8,0.0,63,0,17.1,7
2020-02-12 02:00,16.8,0.0,63,0,17.1,6
2020-02-12 03:00,16.8,0.0,63,0,17.1,8
2020-02-12 04:00,16.8,0.0,63,0,17.1,8
2020-02-12 05:00,16.8,0.0,62,-1,17.1,7
2020-02-12 06:00,16.8,0.0,63,1,17.1,7
2020-02-12 07:00,16.8,0.0,62,-1,17.1,10
2020-02-12 08:00,16.8,0.0,62,0,17.1,10
2020-02-12 09:00,16.8,0.0,62,0,17.1,13
2020-02-12 10:00,16.8,0.0,61,-1,17.1,17
2020-02-12 11:00,16.8,0.0,62,1,17.1,19
2020-02-12 12:00,16.9,0.1,61,-1,17.1,20
2020-02-12 13:00,16.9,0.0,61,0,17.1,24
2020-02-12 14:00,16.9,0.0,61,0,17.1,23
2020-02-12 15:00,16.9,0.0,61,0,17.1,19
2020-02-12 16:00,16.9,0.0,61,0,17.1,14
2020-02-12 17:00,16.9,0.0,61,0,17.1,10
2020-02-12 18:00,16.9,0.0,61,0,17.1,5
2020-02-12 19:00,16.9,0.0,61,0,17.1,3
2020-02-12 20:00,16.8,-0.1,60,-1,17.1,4
2020-02-12 21:00,16.8,0.0,61,1,17.1,10
2020-02-12 22:00,16.8,0.0,61,0,17.1,8
2020-02-12 23:00,16.8,0.0,61,0,17.1,10
2020-02-13 00:00,16.8,0.0,61,0,17.1,11
2020-02-13 01:00,16.8,0.0,62,1,17.1,11
2020-02-13 02:00,16.8,0.0,61,-1,17.1,10
2020-02-13 03:00,16.8,0.0,61,0,17.1,9
2020-02-13 04:00,16.8,0.0,61,0,17.1,10
2020-02-13 05:00,16.8,0.0,61,0,17.1,10
2020-02-13 06:00,16.8,0.0,61,0,17.1,9
2020-02-13 07:00,16.8,0.0,61,0,17.1,12
2020-02-13 08:00,16.8,0.0,61,0,17.1,14
2020-02-13 09:00,16.8,0.0,61,0,17.1,19
2020-02-13 10:00,16.9,0.1,60,-1,17.1,21
2020-02-13 11:00,16.9,0.0,60,0,17.1,24
"""

let SnowDataSampleString = """
    {
        "station_information":
            {
                "elevation":3950,
                "location": {"lat":47.74607,"lng":-121.09288},
                "name":"STEVENS PASS",
                "timezone":-8,
                "triplet":"791:WA:SNTL",
                "wind":false
            },
        "data": [
            {
                "Date":"2014-06-30",
                "Snow Water Equivalent (in)":"0.0",
                "Change In Snow Water Equivalent (in)":"0.0",
                "Snow Depth (in)":"0",
                "Change In Snow Depth (in)":"0",
                "Air Temperature Observed (degF)":"30"
            },
            {
                "Date":"2014-07-01",
                "Snow Water Equivalent (in)":"0.0",
                "Change In Snow Water Equivalent (in)":"0.0",
                "Snow Depth (in)":"0",
                "Change In Snow Depth (in)":"0",
                "Air Temperature Observed (degF)":"30"
            }
        ]

    }
"""



class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("Models") {

            let jsonDecoder = JSONDecoder()
            jsonDecoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "~", negativeInfinity: "-~", nan: "nan")
            
            context("SnowData") {
                
                it("can remove comments from csv") {
                    let lines = String.cleanCSV(string: SnowDataSampleCSV)
                    expect(lines.count) == 61
                }
                
                it("can convert csv to json") {
                    let lines = String.cleanCSV(string: SnowDataSampleCSV)
                    expect(lines.count) == 61
                    do {
                        let csv: CSV = try CSV(string: lines.joined(separator: "\n"), delimiter: ",")
                        
                        let snowDataPoints = try (csv.namedRows as [Dictionary]).map { (row) in
                            return try jsonDecoder.decode(SnowData.self, fromDict: row)
                        }
                        expect(snowDataPoints.count) == 60
                        expect(snowDataPoints[0].snowH20Equivalent) == 16.9
                    } catch let err {
                        fail("CSV instancing: \(err)")
                    }
                    
                }

                it("can generate NWS URL for Hour") {
                    if let url = SnoTelAPI.SnotelStore.shared.generateNWSURL(triplet:"713:CO:SNTL", hours:48) {
                        print("URL:\(url.absoluteString)")
                    } else {
                        fail("GenerateNWSURL Hourly")
                    }
                    expect("🐮") == "🐮"
                }
                
                it("can get data from NWS") {
                    var waiting = true
                    SnoTelAPI.SnotelStore.shared.testNWSURL(triplet: "713:CO:SNTL", hours: 48) {  ([Any]) in
                        print("")
                        waiting = false
                    }
                    expect(waiting).toEventually(equal(false), timeout: 100)

                    print("")
                }
                
                it ("can get promised data from NWS") {
                    var subscriptions = Set<AnyCancellable>()
                    var waiting = true
                    
                    SnotelStore.shared.fetchStationDetails(triplet: "713:CO:SNTL", hours: 48)
                    .sink(receiveCompletion: { (completion) in
                        if case let .failure(error) = completion {
                            fail("error: \(error)")
                            waiting = false
                        }
                        }, receiveValue: { (values) in
                            print(" Values \(values)")
                            let totalAccumulation = SnowData.totalSnow(for: values)
                            waiting = false
                        })
                    .store(in: &subscriptions)
                    
                    expect(waiting).toEventually(equal(false), timeout: 100)
                    
                }

                it("will eventually pass") {
                    var time = "passing"

                    DispatchQueue.main.async {
                        time = "done"
                    }

                    waitUntil { done in
                        Thread.sleep(forTimeInterval: 0.5)
                        expect(time) == "done"

                        done()
                    }
                }
            }
        }
        describe("API") {
            
        }
    }
}
