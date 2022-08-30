//
//  PostalCodesRepository.swift
//  PostalCode
//
//  Created by João Pedro on 27/08/2022.
//

import Foundation
import RealmSwift

struct PostalCodesRepository {
    
    private var service: PostalCodesService
    private var database = DatabaseManager()
    
    
    init(service: PostalCodesService) {
        self.service = service
    }
    
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
        print("Start Filtering by \(text)")
        
        database.filterPostalCodes(with: text, completion: { codes in
            completed(codes)
        })
    }
    
    /// Function that downloads and saves the downloaded Postal Codes
    func downloadPostalCodes(completion: @escaping (Result<Bool, Error>) -> ()) {
        
        print("Start downloadPostalCodes")
        
        Task {
            let postalCodes = await service.downloadPostalCodes()
            
            switch postalCodes {
            case .success(let downloadedPostalCodes):
    
                let databaseCreated = database.createDB(from: downloadedPostalCodes)
                completion(.success(databaseCreated))
                
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
    }
}
