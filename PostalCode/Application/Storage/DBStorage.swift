//
//  DBStorage.swift
//  PostalCode
//
//  Created by João Pedro on 27/08/2022.
//

import Foundation
import RealmSwift

struct DBStorage {
    
    var realm: Realm?
    
    init() {
        
        do {
            self.realm = try Realm()
        } catch let error {
            print(error)
        }
    }
    
    func fetchPostalCodes() -> [PostalCode]? {
        print("Fetch values from database")
        
        guard
            let savedPostalCodes = realm?.objects(PostalCode.self),
            !savedPostalCodes.isEmpty
        else {
            return nil
        }
        
        print("Return saved on database")
        return Array(savedPostalCodes)
    }
    
    func save(_ postalCodes: [PostalCode], completion: @escaping () -> ()) {
        print("Start to save on database")
        
        DispatchQueue.main.async {
            
            realm?.writeAsync({
                realm?.add(postalCodes)
            }, onComplete: { error in
                
                if let error = error {
                    print("Failed to save on database")
                    print(error)
                    completion()
                    return
                }
                
                print("Saved on database successfully")
                completion()
            })
        }
    }
    
    func searchBy(text: String, completed: @escaping ([PostalCode]) -> Void) {
        
        DispatchQueue(label: "background").async {
            let realm = try! Realm()
            
            let split = text.split(separator: "-").flatMap({ $0.split(separator: " ")})
            let filter: [String] = split.map({ String($0) })
            if !filter.isEmpty {
                let predicates = self.getPredicates(with: filter)
                let predicate = NSCompoundPredicate(type: .or, subpredicates: predicates)
                
                let postalCodes = Array(realm.objects(PostalCode.self).filter(predicate))
                let postalCodesReferences = postalCodes.map { ThreadSafeReference(to: $0) }
                
                DispatchQueue.main.async {
                    // Resolve references on main thread
                    let mainRealm = try! Realm()
                    let mainThreadPostalCodes = postalCodesReferences.compactMap { mainRealm.resolve($0) }
                    // Do something with words
                    completed(Array(mainThreadPostalCodes))
                }
                
            } else {
                
                let postalCodes = Array(realm.objects(PostalCode.self))
                let postalCodesReferences = postalCodes.map { ThreadSafeReference(to: $0) }
                
                DispatchQueue.main.async {
                    // Resolve references on main thread
                    let mainRealm = try! Realm()
                    let mainThreadPostalCodes = postalCodesReferences.compactMap { mainRealm.resolve($0) }
                    // Do something with words
                    completed(Array(mainThreadPostalCodes))
                }
            }
        }
    }
    
    private func getPredicates(with filter: [String]) -> [NSPredicate] {
        var predicates: [NSPredicate] = []
        
        filter.forEach({
            predicates.append(NSPredicate(format: "local CONTAINS[c] %@", $0))
            predicates.append(NSPredicate(format: "codPostal CONTAINS[c] %@", $0))
            predicates.append(NSPredicate(format: "extCodPostal CONTAINS[c] %@", $0))
        })
        
        return predicates
    }
}
