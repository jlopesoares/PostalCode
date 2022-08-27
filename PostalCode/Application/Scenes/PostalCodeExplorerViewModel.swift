//
//  PostalCodeExplorerViewModel.swift
//  PostalCode
//
//  Created by João Pedro on 27/08/2022.
//

import Foundation
import Combine

final class PostalCodesExplorerViewModel {

    private var repository: PostalCodesRepository
    
    @Published private(set) var datasource: [PostalCode] = []
    
    
    init(repository: PostalCodesRepository) {
        self.repository = repository
    }
    
    func fetchPostalCodes(){
        print("Start fetchPostalCodes")
        datasource = repository.fetchPostalCodes() ?? []
    }
    
    func search(for searchTerm: String){
        datasource = repository.search(for: searchTerm)
    }
    
}
