//
//  PostalCodesRepository.swift
//  PostalCode
//
//  Created by João Pedro on 27/08/2022.
//

import Foundation
import RealmSwift

protocol PostalCodesRepositoryUseCase {
    
    func fetchPostalCodes() -> [PostalCode]?
    func search(for searchTerm: String) -> [PostalCode]
}


struct PostalCodesRepository {
    
    private var service: PostalCodesService
    private var database: DBStorage?
    
    
    init(service: PostalCodesService) {
        self.service = service
        self.database = DBStorage()
    }
    
    func fetchPostalCodes() -> [PostalCode]? {
        
        print("Check fetchPostalCodes on repository")
        guard
            let database = database,
            let postalCodes = database.fetchPostalCodes()
        else {
            return nil
        }
        
        return postalCodes
    }
    
    func searchBy(text: String, completed: @escaping ([PostalCode]?) -> Void) {
        
        database?.searchBy(text: text, completed: { postalCodes in
            completed(postalCodes)
        })
    }
    
    
    /// Function that downloads and saves the downloaded Postal Codes
    func downloadPostalCodes(completion: @escaping (Result<Void, Error>) -> ()) {
        
        print("Start downloadPostalCodes")
        
        Task {
            let postalCodes = await service.downloadPostalCodes()
            
            switch postalCodes {
            case .success(let downloadedPostalCodes):
                
                database?.save(downloadedPostalCodes, completion: {
                    completion(.success(()))
                })
                
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }
    }
}
