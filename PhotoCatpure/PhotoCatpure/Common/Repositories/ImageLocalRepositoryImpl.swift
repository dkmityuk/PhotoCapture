//
//  ImageLocalRepositoryImpl.swift
//  PhotoCatpure
//
//  Created by Dmytro Kmytiuk on 23.03.2024.
//

import RxSwift
import CoreData

protocol AssetLocalRepository {
    func fetchAssets() -> Observable<[String]>
    func saveAssets(_ localIdentifier: String)
    func cleanUpDatabase()
}

final class AssetLocalRepositoryImp:CoreDataStack, AssetLocalRepository {
    
    // MARK: Fetch
    func fetchAssets() -> Observable<[String]> {
        return Observable<[String]>.create { observer in
            let context = self.persistentContainer.newBackgroundContext()
            context.perform {
                do {
                    let fetchRequest: NSFetchRequest<AssetEntityMO> = AssetEntityMO.fetchRequest()
                    let results = try context.fetch(fetchRequest)
                    let imageIdentifiers = results.compactMap { $0.localIdentifier }
                    observer.onNext(imageIdentifiers)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
        .subscribe(on: MainScheduler.asyncInstance)
    }
    
    // MARK: Save
    func saveAssets(_ localIdentifier: String) {
        let context = persistentContainer.newBackgroundContext()
        context.perform {
            do {
                let fetchRequest: NSFetchRequest<AssetEntityMO> = AssetEntityMO.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "localIdentifier == %@", localIdentifier)
                let result = try context.fetch(fetchRequest)
                
                if result.first != nil {
                    debugPrint("Already exists")
                } else {
                    let newObject = AssetEntityMO(context: context)
                    newObject.localIdentifier = localIdentifier
                    try context.save()
                }
            } catch {
                debugPrint("Error saving image: \(error)")
            }
        }
    }
    
    // MARK: Delete
    func cleanUpDatabase() {
        let context = persistentContainer.newBackgroundContext()
        context.perform {
            do {
                let fetchRequest: NSFetchRequest<AssetEntityMO> = AssetEntityMO.fetchRequest()
                if let fetchRequest = fetchRequest as? NSFetchRequest<NSFetchRequestResult> {
                    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    try context.execute(batchDeleteRequest)
                    try context.save()
                } else { debugPrint("Error") }
            } catch {
                return
            }
        }
    }

}
