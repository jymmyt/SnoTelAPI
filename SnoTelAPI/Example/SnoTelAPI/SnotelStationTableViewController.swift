//
//  SnotelStationTableViewController.swift
//  SnoTelAPI_Example
//
//  Created by Jim Terhorst on 2/13/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SnoTelAPI
import Combine

fileprivate class DateSection {
    
}

class SnotelStationTableViewController: UITableViewController {
    
    static var reuseIdentifier = "SnowDataCell"
    fileprivate var diffableDataSource: UITableViewDiffableDataSource<String, SnowData>!
    private var subscriptions = Set<AnyCancellable>()
    var isFetchingData = CurrentValueSubject<Bool, Never>(false)
    var station : Station?
    var snowData: [SnowData]?
    var snowDataByDate: Dictionary<String, [SnowData]>?
    var sectionLabels: [String]?
    
    static var timeFormatter = { () -> DateFormatter in
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .medium
        return timeFormatter
    }()
    
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var totalSnowLabel: UILabel!
    @IBOutlet weak var totalH2OLabel: UILabel!
    @IBOutlet weak var timeSpanSwitch: UISegmentedControl!
    
    @Published var totalSnowfall: Double = 0.0
    @Published var totalH2O: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let station = self.station {
            stationNameLabel?.text = station.name
        }
        setupTableView()
        self.fetchStationData()
        
        $totalSnowfall.receive(on: DispatchQueue.main).map { (totalSnow) -> String in
            return "\(totalSnow)"
        }
        .assign(to: \.text, on: self.totalSnowLabel)
        .store(in: &subscriptions)
        
        $totalH2O.receive(on: DispatchQueue.main).map { (totalH2O) -> String in
            return "\(totalH2O)"
        }
        .assign(to: \.text, on: self.totalH2OLabel)
        .store(in: &subscriptions)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func fetchStationData() {
        if let station = self.station {
            var timespan = 48
            if timeSpanSwitch.selectedSegmentIndex == 0 {
                timespan = 24
            }
            SnotelStore.shared.fetchStationDetails(triplet: station.triplet, hours: timespan)
            .sink(receiveCompletion: {[unowned self] (completion) in
                if case let .failure(error) = completion {
                    self.handleError(apiError: error)
                }
            }, receiveValue: { [unowned self] in
                self.generateSnapshot(with: $0)
                print("")
            })
            .store(in: &subscriptions)
        }
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "SnotelStationsHeaderView", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "SnotelStationsHeaderView")
        diffableDataSource = UITableViewDiffableDataSource<String, SnowData>(tableView: tableView) { (tableView, indexPath, snowData) -> UITableViewCell? in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: SnotelStationTableViewController.reuseIdentifier, for: indexPath) as? SnowDataTableViewCell
            cell?.snowData = snowData
            
            return cell
        }
    }
    
    private func generateSnapshot(with snowData: [SnowData]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, SnowData>()
        self.snowDataByDate = SnowData.snowDataByDate(for: snowData)
        if let snowDataByDate = self.snowDataByDate {
            self.sectionLabels = snowDataByDate.keys.map { (key)  in
                return key
            }
            if let sectionLabels = self.sectionLabels {
                snapshot.appendSections(sectionLabels)
                snowDataByDate.forEach { (dateString, snowDataForDate) in
                    
                    snapshot.appendItems(snowDataForDate, toSection: dateString)
                }
            }
        }
        
        self.totalSnowfall = SnowData.totalSnow(for: snowData)
        
        if let startH2OEquivalent = snowData.first?.snowH20Equivalent,
            let endH2OEquivalent = snowData.last?.snowH20Equivalent {
            self.totalH2O = endH2OEquivalent - startH2OEquivalent
        }
        diffableDataSource.apply(snapshot, animatingDifferences: true)
    }

    func handleError(apiError: SnotelStoreAPIError) {
        let alertController = UIAlertController(title: "Error", message: apiError.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true)
    }
    
    @IBAction func timeSpanChanged(_ sender: Any) {
        self.fetchStationData()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SnotelStationsHeaderView") as! SnotelStationDataHeaderView
        sectionHeader.dateLabel?.text = self.sectionLabels![section]
        return sectionHeader
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
}
