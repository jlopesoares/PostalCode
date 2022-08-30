//
//  PostalCodesRepository.swift
//  PostalCode
//
//  Created by João Pedro on 27/08/2022.
//

import Foundation

struct PostalCodesRepository {
    
    private var service: PostalCodesService
    private var database = DatabaseManager()
    
    init(service: PostalCodesService) {
        self.service = service
    }
    
    /// This function will fetch all the saved postal codes
    /// - Returns: Array of saved postal codes
    func fetchPostalCodes() -> [PostalCodes]? {
        
        print("Check fetchPostalCodes on repository")
        
        let savedPostalCodes = database.fetchAllPostalCodes()

        if savedPostalCodes.isEmpty {
            return nil
        }
        
        return savedPostalCodes
    }
    
    /// Function thar starts the filtering process
    /// - Parameters:
    ///   - text: Text to filter
    ///   - completed: filtered Postal Codes
    func filterBy(text: String, completed: @escaping ([PostalCodes]?) -> Void) {
 
        database.filterPostalCodes(with: text, completion: { codes in
            completed(codes)
        })
    }
    
    /// Function that downloads and saves the downloaded Postal Codes
    func downloadPostalCodes(completion: @escaping (Result<Void, Error>) -> ()) {
        
        print("Start downloadPostalCodes")
        
        Task {
            let postalCodes = await service.downloadPostalCodes()
            
            switch postalCodes {
            case .success(let downloadedPostalCodes):
    
                database.createDB(from: downloadedPostalCodes)
                completion(.success(()))
                
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
    }
}
