//
//  PostalCodesStorage.swift
//  PostalCode
//
//  Created by João Pedro on 29/08/2022.
//

import Foundation
import UIKit
import CoreData

final class DatabaseManager {
    
    private lazy var persistentContainer: NSPersistentContainer = {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }()
    
    var viewContext: NSManagedObjectContext {
        self.persistentContainer.viewContext
    }
    private var persistentContainerQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    init() { }
    
    /// Get all Locations from DB
    /// - Returns: Array of already saved postal codes
    func fetchAllPostalCodes() -> [PostalCodes] {
        do {
            let request = NSFetchRequest<PostalCodes>(entityName: Constants.postalCodesIdentity)
            request.fetchBatchSize = 20
            
            return try self.viewContext.fetch(request)
        } catch {
            fatalError()
        }
    }
}

//MARK: - Create DB
extension DatabaseManager {
    
    /// Saves the entire database
    /// - Parameters:
    ///   - downloadedPostalCodes: Array of postals to convert and save
    /// - Returns: Returns if the save was successful
    func createDB(from downloadedPostalCodes: [LocalPostalCode]) -> Bool {
        
        let dbPostalCodes = downloadedPostalCodes.map { localPostalCode -> PostalCodes in
        
            let newPostalCodes = PostalCodes(context: viewContext)
            newPostalCodes.locationName = localPostalCode.local
            newPostalCodes.codPostal = localPostalCode.codPostal
            newPostalCodes.extCodPostal = localPostalCode.extCodPostal
            newPostalCodes.fullPostalCode = localPostalCode.codPostal + "-" + localPostalCode.extCodPostal
            return newPostalCodes
        }

        return createFullDB(postalCodes: dbPostalCodes)
    }

    private func createFullDB(postalCodes: [PostalCodes]) -> Bool {
        
        var success: Bool = false
        self.viewContext.performAndWait {
            
            postalCodes.forEach { viewContext.insert($0) }
            
            do {
                try self.viewContext.save()
                success = true
            } catch {
                success = false
            }
        }
        return success
    }
}

//MARK: - Filtering
extension DatabaseManager {
    
    /// Filters DB based on query string
    /// - Parameter string: string to search on DB
    func filterPostalCodes(with string: String, completion: @escaping ([PostalCodes]) -> ()) {
        filterPostalCodes(searchString: string) { filtered in
            completion(filtered)
        }
    }
    
    /// Filter DB with some query
    /// - Parameters:
    ///   - searchString: Query string to filter
    ///   - completion: Result of the search, if any
    private func filterPostalCodes(searchString: String, completion: @escaping ([PostalCodes]) -> Void) {
        
        let filters = searchString.components(separatedBy: " ")
        
        var predicates: [NSPredicate] = []
        
        for filter in filters {
            if !filter.isEmpty {
                predicates.append(
                    NSPredicate(format: "locationName CONTAINS[cd] %@ OR codPostal CONTAINS[cd] %@ OR extCodPostal CONTAINS[cd] %@ OR fullPostalCode CONTAINS[cd] %@", argumentArray: [filter, filter, filter, filter])
                )
            }
        }
        
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let request = NSFetchRequest<PostalCodes>(entityName: Constants.postalCodesIdentity)
        request.fetchBatchSize = 20
        request.predicate = compound
        
        self.enqueue { context in
            do {
                let postalCode = try context.fetch(request)
                completion(postalCode)
            } catch let error {
                print(error)
            }
        }
    }
}

// MARK: - Extension
extension DatabaseManager {
    
    /// Function to search asynchronous
    private func enqueue(block: @escaping (_ context: NSManagedObjectContext) -> Void) {
        self.persistentContainerQueue.addOperation() {
            let context: NSManagedObjectContext = self.persistentContainer.newBackgroundContext()
            context.performAndWait{
                block(context)
                try? context.save()
            }
        }
    }
}


private struct Constants {
    static var postalCodesIdentity = "PostalCodes"
}
