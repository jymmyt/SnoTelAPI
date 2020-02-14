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

fileprivate enum Section {
    case main
}

class SnotelStationTableViewController: UITableViewController, UISearchBarDelegate {
    
    static var reuseIdentifier = "SnowDataCell"
    fileprivate var diffableDataSource: UITableViewDiffableDataSource<Section, SnowData>!
    private var subscriptions = Set<AnyCancellable>()
    var isFetchingData = CurrentValueSubject<Bool, Never>(false)
    var station : Station?
    var snowData: [SnowData]?
    
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
        .assign(to: \.text, on: self.totalSnowLabel)
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
                print(" Values \($0)")
                print("")
            })
            .store(in: &subscriptions)
        }
    }
    
    private func setupTableView() {
        
        diffableDataSource = UITableViewDiffableDataSource<Section, SnowData>(tableView: tableView) { (tableView, indexPath, snowData) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: SnotelStationTableViewController.reuseIdentifier, for: indexPath) as? SnowDataTableViewCell
            cell?.dateLabel?.text = snowData.date
            if let airTemperature = snowData.airTemperature {
                cell?.temperatureLabel?.text = "\(airTemperature)"
            } else {
                cell?.temperatureLabel?.text = "--"
            }
            if let snowDepth = snowData.snowDepth {
                cell?.accumulatedSnowLabel?.text = "\(snowDepth)"
            } else {
                cell?.accumulatedSnowLabel?.text = "--"
            }
            return cell
        }
    }
    
    private func generateSnapshot(with snowData: [SnowData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SnowData>()
        snapshot.appendSections([.main])
        snapshot.appendItems(snowData)
        if let startSnow = snowData.first?.snowDepth, let endSnow = snowData.last?.snowDepth {
            self.totalSnowfall = endSnow - startSnow
        }
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
    
    // Mark - UISearchbarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    @IBAction func timeSpanChanged(_ sender: Any) {
        self.fetchStationData()
    }
    
    
}
