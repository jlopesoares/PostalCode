//
//  PostalCodesExplorerViewController.swift
//  PostalCode
//
//  Created by João Pedro on 27/08/2022.
//

import UIKit
import Combine

class PostalCodesExplorerViewController: UIViewController {
   
    @IBOutlet weak var tableViewBottomMarginConstraint: NSLayoutConstraint!
    
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
            tableView.dataSource = self
//            tableView.keyboardDismissMode = .onDrag
        }
    }
    
    //MARK: - Vars
    let viewModel = PostalCodesExplorerViewModel(repository: PostalCodesRepository(service: PostalCodesService()))
    var cancellables: [AnyCancellable] = []
    
    deinit {
        removeKeyboardObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        observeKeyboardNotifications()
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
    
    /// This function will start the download process
    /// It will show a loader screen and then remove when finished
    func downloadPostalCodes() {
        
        presentLoaderView()
        
        viewModel.downloadPostalCodes { [weak self] result in
            
            DispatchQueue.main.async {
                
                self?.dismissLoaderViewController(completion: {
                    if case .failure = result {
                        
                        self?.presentAlerController()
                        return
                    }
                })
            }
        }
    }
    
    /// Databinding between datasource and view
    /// Refresh the Ui when new values are available
    func bindViewModel() {

        viewModel.$datasource
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                
                self?.tableView.reloadData()
                
            }.store(in: &cancellables)
    }
}

//MARK: - TableView
extension PostalCodesExplorerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PostalCodeTableViewCell.self),
                                                       for: indexPath) as? PostalCodeTableViewCell else {
            return UITableViewCell()
        }
        
        let postalCode = self.viewModel.datasource[indexPath.row]
        cell.setup(postalCode: postalCode)
        
        return cell
    }
}

//MARK: - SearchBar Delegate
extension PostalCodesExplorerViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        viewModel.search(for: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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

//MARK: - Observers
extension PostalCodesExplorerViewController {
    
    
    fileprivate func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.tableViewBottomMarginConstraint.constant = keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.tableViewBottomMarginConstraint.constant = 0
    }
}

private struct Constants {
    
    static var searchBarPlaceholder = "Search for any location"
    static var cancelActionTitle = "Cancel"
    static var tryAgainActionTitle = "Try again"
    static var errorMessageTitle = "Ops..."
    static var errorMessageDescription = "Something went wrong..."
}
