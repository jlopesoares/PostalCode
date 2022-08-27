//
//  PostalCodesExplorerViewController.swift
//  PostalCode
//
//  Created by João Pedro on 27/08/2022.
//

import UIKit
import Combine

class PostalCodesExplorerViewController: UIViewController {
    
    let viewModel = PostalCodesExplorerViewModel(repository: PostalCodesRepository(service: PostalCodesService()))
    var cancellables: [AnyCancellable] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        viewModel.fetchPostalCodes()
        
    }
    
    func bindViewModel() {
        
        viewModel.$datasource
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
                
                print(self.viewModel.datasource)
                
                
            }.store(in: &cancellables)
    }
}
