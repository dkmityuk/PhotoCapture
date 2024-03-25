//
//  CoreDataStack.swift
//  PhotoCatpure
//
//  Created by Dmytro Kmytiuk on 23.03.2024.
//

import RxSwift
import CoreData

protocol PersistentStore {
    var persistentContainer: NSPersistentContainer { get }
}

private enum Constants {
    static let photoCaptureModelName = "PhotoCapture"
    static let subPathToDB = "db.sql.PhotoCapture"
    static let coreDataStackQueue = DispatchQueue(label: "com.PhotoCapture.CodeDataQueue")
}

 class CoreDataStack: PersistentStore {
    
    private let isStoreLoaded = BehaviorSubject<Bool>(value: false)
    var persistentContainer: NSPersistentContainer
    
    init(
        directory: FileManager.SearchPathDirectory = .documentDirectory,
        domainMask: FileManager.SearchPathDomainMask = .userDomainMask,
        version vNumber: UInt = Version.actual
    ) {
        let version = Version(vNumber)
        persistentContainer = NSPersistentContainer(name: version.modelName)
        
        if let url = version.dbFileURL(directory, domainMask) {
            debugPrint("DB Container URL: \(url)")
            let store = NSPersistentStoreDescription(url: url)
            store.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            persistentContainer.persistentStoreDescriptions = [store]
        }
        
        Constants.coreDataStackQueue.async { [weak isStoreLoaded, weak persistentContainer] in
            persistentContainer?.loadPersistentStores { _, error in
                if let error = error {
                    isStoreLoaded?.onError(error)
                } else {
                    DispatchQueue.main.async {
                        persistentContainer?.viewContext.configureAsReadOnlyContext()
                        isStoreLoaded?.onNext(true)
                    }
                }
            }
        }
    }
    
    func backgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
}

// MARK: - Versioning

extension CoreDataStack.Version {
    static var actual: UInt { 0 }
}

extension CoreDataStack {
    
    struct Version {
        private let number: UInt
        
        init(_ number: UInt) {
            self.number = number
        }
        
        var modelName: String { Constants.photoCaptureModelName }
        
        func dbFileURL(_ directory: FileManager.SearchPathDirectory,
                       _ domainMask: FileManager.SearchPathDomainMask) -> URL? {
            let path = FileManager.default
                .urls(for: directory, in: domainMask).first?
                .appendingPathComponent(subPathToDB)
            return path
        }
        
        private var subPathToDB: String { Constants.subPathToDB }
    }
    
}

// MARK: - NSManagedObjectContext Configuration

extension NSManagedObjectContext {
    
    func configureAsReadOnlyContext() {
        automaticallyMergesChangesFromParent = true
        undoManager = nil
        shouldDeleteInaccessibleFaults = true
        mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
}

