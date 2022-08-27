//
//  DBStorage.swift
//  PostalCode
//
//  Created by João Pedro on 27/08/2022.
//

import Foundation
import RealmSwift

struct DBStorage: PostalCodesRepositoryUseCase {
    
    var realm: Realm?
    
    init() {
        
        do {
            self.realm = try Realm()
        } catch let error {
            print(error)
        }
    }
    
    func fetchPostalCodes() -> [PostalCode]? {
        print("fetch on database")
        
        guard
            let savedPostalCodes = realm?.objects(PostalCode.self),
            !savedPostalCodes.isEmpty
        else {
            return nil
        }
        
        print("return saved on database")
        return Array(savedPostalCodes)
    }
    
    func search(for searchTerm: String) -> [PostalCode] {
        []
    }
    
    func save(_ postalCodes: [PostalCode]) {
        print("save on database")
        
        
        DispatchQueue.main.async {
            realm?.writeAsync({
                realm?.add(postalCodes)
            }, onComplete: { error in
                
                if let error = error {
                    print("failed to save on database")
                    print(error)
                    return
                }
                
                print("saved on database successfully")
            })
        }
    }
}
