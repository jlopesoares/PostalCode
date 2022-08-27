//
//  PostalCodesExplorerViewController.swift
//  PostalCode
//
//  Created by João Pedro on 27/08/2022.
//

import UIKit
import Combine

class PostalCodesExplorerViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var tableViewDataSource: UITableViewDiffableDataSource<UUID, PostalCode>!
    
    let viewModel = PostalCodesExplorerViewModel(repository: PostalCodesRepository(service: PostalCodesService()))
    var cancellables: [AnyCancellable] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupPostalCodeCellProvider()
        viewModel.fetchPostalCodes()
    }
    
    func bindViewModel() {
        
        viewModel.$datasource
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
                self.setSnapshot()
                
                
            }.store(in: &cancellables)
    }
    
    func setupPostalCodeCellProvider() {
        
        tableViewDataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, postalCode in
            
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            
            var content = cell.defaultContentConfiguration()
            content.text = "\(postalCode.codPostal)-\(postalCode.extCodPostal)"
            content.secondaryText = postalCode.local
            cell.contentConfiguration = content
            return cell
        })
    }
    
    func setSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<UUID, PostalCode>()
        let section = UUID()
        snapshot.appendSections([section])
        snapshot.appendItems(viewModel.datasource, toSection: section)
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true)
    }
}
