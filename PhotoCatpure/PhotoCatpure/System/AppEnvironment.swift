//
//  AppEnvironment.swift
//  PhotoCatpure
//
//  Created by Dmytro Kmytiuk on 24.03.2024.
//

import Foundation
import CoreData

struct AppEnvironment {
    let container: DIContainer
}

extension AppEnvironment {
    static func bootstrap() -> AppEnvironment {
        let persistentStore = CoreDataStack(version: CoreDataStack.Version.actual)
        let localRepositories = configuratedRepositories(persistentContainer: persistentStore.persistentContainer)
        let services = configuratedServices(localRepositories: localRepositories)
        let diContainer = DIContainer(services: services)
        
        return AppEnvironment(container: diContainer)
    }
}

extension AppEnvironment {
    private static func configuratedServices(localRepositories: DIContainer.LocalRepositories) -> DIContainer.ServicesContainer {
        let imageService: AssetService = ImageServiceImpl(repository: localRepositories.imageLocalRepository)
        
        return .init(imageService: imageService)
    }
}

extension AppEnvironment {
    private static func configuratedRepositories(persistentContainer: NSPersistentContainer) -> DIContainer.LocalRepositories {
        let imageLocalRepository: AssetLocalRepository = AssetLocalRepositoryImp()
        
        return .init(imageLocalRepository: imageLocalRepository)
    }
    
    
}

