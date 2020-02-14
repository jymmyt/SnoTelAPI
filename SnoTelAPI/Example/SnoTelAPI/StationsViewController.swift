//
//  StationsViewController.swift
//  SnoTelAPI
//
//  Created by Jim Terhorst on 02/12/2020.
//  Copyright (c) 2020 Jim Terhorst. All rights reserved.
//

import UIKit
import Combine
import SnoTelAPI

class SubtitleTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



fileprivate enum Section {
    case main
}

class StationsViewController: UITableViewController, UISearchBarDelegate {
    let reuseIdentifer = "Cell"
    
    fileprivate var diffableDataSource: UITableViewDiffableDataSource<Section, Station>!
    private var subscriptions = Set<AnyCancellable>()
    var isFetchingData = CurrentValueSubject<Bool, Never>(false)
    var stations: [Station]?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.fetchStations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func generateSnapshot(with stations: [Station]) {
        self.stations = stations
        var snapshot = NSDiffableDataSourceSnapshot<Section, Station>()
        snapshot.appendSections([.main])
        snapshot.appendItems(stations)
        diffableDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func testFetch() {
        SnotelStore.shared.testURL()
    }
    
    func fetchStations() {
        isFetchingData.value = true
        SnotelStore.shared.fetchStations()
            .sink(receiveCompletion: {[unowned self] (completion) in
                if case let .failure(error) = completion {
                    self.handleError(apiError: error)
                }
                self.isFetchingData.value = false
            }, receiveValue: { [unowned self] in
                self.generateSnapshot(with: $0)
            })
            .store(in: &self.subscriptions)
    }
    
    func handleError(apiError: SnotelStoreAPIError) {
        let alertController = UIAlertController(title: "Error", message: apiError.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true)
    }
    
    var currentStation: Station?
    
    private func setupTableView() {
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: self.reuseIdentifer)
        diffableDataSource = UITableViewDiffableDataSource<Section, Station>(tableView: tableView) { (tableView, indexPath, station) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifer, for: indexPath)
            
            cell.textLabel?.text = station.name
            cell.detailTextLabel?.text = station.triplet
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SnotelStationTableViewController {
            destinationVC.station = self.currentStation
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("")
        let cell = tableView.cellForRow(at: indexPath)
        self.currentStation = diffableDataSource.itemIdentifier(for: indexPath)
        self.performSegue(withIdentifier: "ShowSnowData", sender: cell)
    }
    
    // Mark - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.performSearch(searchQuery: searchText)
    }
    
    func performSearch(searchQuery: String?) {
        guard let stations = self.stations else {
            return
        }
        let filteredStations: [Station]
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            filteredStations = stations.filter { $0.contains(query: searchQuery) }
        } else {
            filteredStations = stations
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, Station>()
        snapshot.appendSections([.main])
        snapshot.appendItems(filteredStations, toSection: .main)
        diffableDataSource.apply(snapshot, animatingDifferences: true)
    }
}
