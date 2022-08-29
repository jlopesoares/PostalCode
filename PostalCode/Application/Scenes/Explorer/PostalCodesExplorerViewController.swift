//
//  PostalCodesExplorerViewController.swift
//  PostalCode
//
//  Created by João Pedro on 27/08/2022.
//

import UIKit
import Combine

class PostalCodesExplorerViewController: UIViewController {
    
    //MARK: - Outlets
    lazy var loaderViewController: UIViewController = {
        return getLoaderViewController()
    }()
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.placeholder = Constants.searchBarPlaceholder
            searchBar.delegate = self
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.keyboardDismissMode = .onDrag
        }
    }
    
    //MARK: - Vars
    var tableViewDataSource: UITableViewDiffableDataSource<UUID, PostalCode>!
    let viewModel = PostalCodesExplorerViewModel(repository: PostalCodesRepository(service: PostalCodesService()))
    var cancellables: [AnyCancellable] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupPostalCodeCellProvider()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        fetchPostalCodes()
    }
    
    /// Fetch already available Postal Codes
    /// If there is any
    /// Present the Loader View and then start download request
    /// On completion
    /// Dismiss Loader View
    func fetchPostalCodes() {
        
        if viewModel.shouldDownloadPostalCodes {
            downloadPostalCodes()
        }
    }
    
    func downloadPostalCodes() {
        
        presentLoaderView()
        
        viewModel.downloadPostalCodes { [weak self] result in
            
            self?.dismissLoaderViewController(completion: {
                
                if case .failure = result {
                    
                    DispatchQueue.main.async {
                        self?.presentAlerController()
                    }
                    return
                }
            })
        }
    }
    
    /// Databinding between datasource and view
    /// Refresh the Ui when new values are available
    func bindViewModel() {
        
        viewModel.$datasource
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
                self.setSnapshot()
                
            }.store(in: &cancellables)
    }
}

//MARK: - TableView
extension PostalCodesExplorerViewController {
    
    /// Basic Cell with the DiffableDasource
    /// For this simple example I decided to not create a custom cell since it was unnecessary
    func setupPostalCodeCellProvider() {
        
        tableViewDataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, postalCode in
            
            let cell = UITableViewCell(style: .default, reuseIdentifier: Constants.cellIdentifier)
            
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
        snapshot.appendItems(viewModel.datasource,
                             toSection: section)
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true)
    }
}

//MARK: - SearchBar Delegate
extension PostalCodesExplorerViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        Task {
            await self.viewModel.search(for: searchText)
        }
    }
}


//MARK: - Navigation
extension PostalCodesExplorerViewController {
    
    func presentLoaderView() {
        present(loaderViewController, animated: true)
    }
    
    func dismissLoaderViewController(completion: @escaping () -> ()) {
        loaderViewController.dismiss(animated: true, completion: completion)
    }
    
    func presentAlerController() {
        
        let alertController = UIAlertController(title: Constants.errorMessageTitle,
                                                message: Constants.errorMessageDescription,
                                                preferredStyle: .alert)

        let retryAction = UIAlertAction(title: Constants.tryAgainActionTitle,
                                        style: .default) { action in
            self.downloadPostalCodes()
        }
        
        alertController.addAction(retryAction)
        
        present(alertController, animated: true)
    }
}

private struct Constants {
    
    static var cellIdentifier = "cell"
    static var searchBarPlaceholder = "Search for any location"
    static var cancelActionTitle = "Cancel"
    static var tryAgainActionTitle = "Try again"
    static var errorMessageTitle = "Ops..."
    static var errorMessageDescription = "Something went wrong..."
    
    
}
