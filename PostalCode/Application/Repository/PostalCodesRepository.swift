//
//  PostalCodesRepository.swift
//  PostalCode
//
//  Created by João Pedro on 27/08/2022.
//

import Foundation

protocol PostalCodesRepositoryUseCase {
    
    func fetchPostalCodes() -> [PostalCode]?
    func search(for searchTerm: String) -> [PostalCode]
}


struct PostalCodesRepository: PostalCodesRepositoryUseCase {
    
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
            downloadPostalCodes()
            return nil
        }
        
        return postalCodes
    }
    
    func search(for searchTerm: String) -> [PostalCode] {
        []
    }
    
    
    func downloadPostalCodes() {
        print("Start downloadPostalCodes")
        
        Task {
            let postalCodes = await service.getPostalCodes()
            
            switch postalCodes {
            case .success(let downloadedPostalCodes):
                database?.save(downloadedPostalCodes)
                
            case .failure(let error):
                print("error")
                break
            }
        }
    }
}
