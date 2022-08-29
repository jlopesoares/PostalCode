//
//  PostalCodeExplorerViewModel.swift
//  PostalCode
//
//  Created by João Pedro on 27/08/2022.
//

import Foundation
import Combine

enum PostCodesExplorerState {
    
    case firstFetch,
         downloading,
         error,
         ready
}

final class PostalCodesExplorerViewModel {
    
    private var state: PostCodesExplorerState = .firstFetch
    private var repository: PostalCodesRepository
    
    @Published var datasource: [PostalCode] = []
    
    init(repository: PostalCodesRepository) {
        self.repository = repository
    }
    
    var shouldDownloadPostalCodes: Bool {
        fetchPostalCodes() == nil && state != .error
    }
}

//MARK: - Database Fetches
extension PostalCodesExplorerViewModel {
    
    /// Fetch Already saved Postal Codes
    /// - Returns: Returns current values if already exists
    func fetchPostalCodes() -> [PostalCode]?{
        print("Start Fetching")
        
        guard let availablePostalCodes = repository.fetchPostalCodes() else {
            return nil
        }
        
        state = .ready
        datasource = availablePostalCodes
        
        return availablePostalCodes
    }
    
    
    /// Search function to filter Postal Codes saved
    /// - Parameter searchTerm: search term to filter
    func search(for searchTerm: String) async {
        
        repository.searchBy(text: searchTerm) { postalCode in
            self.datasource = postalCode ?? []
        }
    }
}

//MARK: - Services
extension PostalCodesExplorerViewModel {
    
    func downloadPostalCodes(completion: @escaping (Result<Void, Error>) -> ()) {
        
        state = .downloading
        
        repository.downloadPostalCodes { [weak self] result in
            
            switch result {
            case .success:
                self?.state = .ready
                completion(.success(()))
                
            case .failure(let error):
                self?.state = .error
                completion(.failure(error))
            }
        }
    }
}
