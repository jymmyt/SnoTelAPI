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
# Date Range: 2020-02-17 00:00 to 2020-02-19 04:00
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
# Reporting Frequency: Hourly; Date Range: 2020-02-17 00:00 to 2020-02-19 04:00
#
# As of: Feb 19, 2020 4:36:18 AM GMT-08:00
#
Date,Snow Water Equivalent (in),Change In Snow Water Equivalent (in),Snow Depth (in),Change In Snow Depth (in),Precipitation Accumulation (in),Air Temperature Observed (degF)
2020-02-17 00:00,17.3,0.0,60,0,17.5,28
2020-02-17 01:00,17.3,0.0,59,-1,17.4,27
2020-02-17 02:00,17.3,0.0,60,1,17.4,27
2020-02-17 03:00,17.3,0.0,60,0,17.4,26
2020-02-17 04:00,17.3,0.0,60,0,17.4,26
2020-02-17 05:00,17.3,0.0,60,0,17.4,24
2020-02-17 06:00,17.3,0.0,60,0,17.4,24
2020-02-17 07:00,17.3,0.0,60,0,17.4,24
2020-02-17 08:00,17.3,0.0,60,0,17.4,27
2020-02-17 09:00,17.3,0.0,60,0,17.4,28
2020-02-17 10:00,17.3,0.0,59,-1,17.4,30
2020-02-17 11:00,17.3,0.0,59,0,17.4,30
2020-02-17 12:00,17.3,0.0,59,0,17.4,28
2020-02-17 13:00,17.3,0.0,59,0,17.4,30
2020-02-17 14:00,17.3,0.0,59,0,17.4,32
2020-02-17 15:00,17.3,0.0,59,0,17.4,31
2020-02-17 16:00,17.4,0.1,59,0,17.5,23
2020-02-17 17:00,17.3,-0.1,60,1,17.5,16
2020-02-17 18:00,17.3,0.0,60,0,17.5,15
2020-02-17 19:00,17.3,0.0,60,0,17.5,16
2020-02-17 20:00,17.2,-0.1,60,0,17.5,17
2020-02-17 21:00,17.2,0.0,60,0,17.5,13
2020-02-17 22:00,17.2,0.0,60,0,17.5,11
2020-02-17 23:00,17.2,0.0,60,0,17.5,9
2020-02-18 00:00,17.3,0.1,60,0,17.5,9
2020-02-18 01:00,17.2,-0.1,60,0,17.5,10
2020-02-18 02:00,17.2,0.0,60,0,17.5,10
2020-02-18 03:00,17.2,0.0,60,0,17.5,11
2020-02-18 04:00,17.2,0.0,60,0,17.5,14
2020-02-18 05:00,17.2,0.0,60,0,17.5,11
2020-02-18 06:00,17.2,0.0,60,0,17.5,8
2020-02-18 07:00,17.2,0.0,60,0,17.5,8
2020-02-18 08:00,17.1,-0.1,59,-1,17.5,11
2020-02-18 09:00,17.2,0.1,59,0,17.5,21
2020-02-18 10:00,17.2,0.0,58,-1,17.5,27
2020-02-18 11:00,17.2,0.0,57,-1,17.5,32
2020-02-18 12:00,17.2,0.0,58,1,17.5,33
2020-02-18 13:00,17.2,0.0,58,0,17.5,35
2020-02-18 14:00,17.3,0.1,58,0,17.4,35
2020-02-18 15:00,17.3,0.0,58,0,17.5,31
2020-02-18 16:00,17.3,0.0,59,1,17.5,28
2020-02-18 17:00,17.3,0.0,59,0,17.5,23
2020-02-18 18:00,17.3,0.0,59,0,17.5,22
2020-02-18 19:00,17.3,0.0,59,0,17.5,20
2020-02-18 20:00,17.2,-0.1,59,0,17.5,19
2020-02-18 21:00,17.2,0.0,59,0,17.5,17
2020-02-18 22:00,17.2,0.0,59,0,17.5,16
2020-02-18 23:00,17.2,0.0,59,0,17.5,16
2020-02-19 00:00,17.2,0.0,59,0,17.5,14
2020-02-19 01:00,17.2,0.0,59,0,17.5,14
2020-02-19 02:00,17.2,0.0,59,0,17.5,15
2020-02-19 03:00,17.2,0.0,59,0,17.5,15
2020-02-19 04:00,17.2,0.0,59,0,17.5,17

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
            //jsonDecoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "~", negativeInfinity: "-~", nan: "nan")
            jsonDecoder.dateDecodingStrategy = .formatted(Date.snotelAPIDateFormatter)
            
            context("SnowData") {
                
                it("can remove comments from csv") {
                    let lines = String.cleanCSV(string: SnowDataSampleCSV, keyMap: SnowData.keyMap())
                    expect(lines.count) == 54
                }
                
                it("can convert csv to json") {
                    let lines = String.cleanCSV(string: SnowDataSampleCSV, keyMap: SnowData.keyMap())
                    expect(lines.count) == 54
                    do {
                        let csv: CSV = try CSV(string: lines.joined(separator: "\n"), delimiter: ",")

                        let snowDataPoints = try (csv.namedRows as [Dictionary]).map { (row) in
                            return try jsonDecoder.decode(SnowData.self, fromDict: row)
                        }
                        expect(snowDataPoints.count) == 53
                        expect(snowDataPoints[0].snowH20Equivalent) == 17.3
                        expect(snowDataPoints[1].airTemperature) == 27.0
                    } catch let err {
                        fail("CSV instancing: \(err)")
                    }
                }
            }
        }
        describe("API") {
            context("Stations") {
                
            }
            context("NWS Snow Data") {
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
                            expect(values.count) > 40
                            waiting = false
                        })
                    .store(in: &subscriptions)
                    expect(waiting).toEventually(equal(false), timeout: 100)
                    
                }
                
                it("can generate NWS URL for hourly data, for specific dates") {
                    if let url = SnoTelAPI.SnotelStore.shared.generateNWSURL(triplet: "713:CO:SNTL", from: Date.snotelAPIDateFormatter.date(from: "2019-12-25 00:00")! , to: Date.snotelAPIDateFormatter.date(from: "2019-12-28 00:00")!) {
                        expect(url.absoluteString).to(contain(["713:CO:SNTL", "2019-12-28"]), description: "NWS URL for hours")
                    } else {
                        fail("GenerateNWSURL Hourly")
                    }
                }
                    
                
                it("can generate NWS URL for hourly data, from now to the given number of hours ago") {
                    if let url = SnoTelAPI.SnotelStore.shared.generateNWSURL(triplet:"713:CO:SNTL", hours:48) {
                        
                        expect(url.absoluteString).to(contain(["713:CO:SNTL", "-48,0"]), description: "NWS URL for hours")
                        print("URL:\(url.absoluteString)")
                    } else {
                        fail("GenerateNWSURL Hourly")
                    }
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
            }
        }
    }
}
