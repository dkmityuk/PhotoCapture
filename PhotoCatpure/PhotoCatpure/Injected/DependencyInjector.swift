//
//  DependencyInjector.swift
//  PhotoCatpure
//
//  Created by Dmytro Kmytiuk on 24.03.2024.
//

import Foundation

struct DIContainer {
    let services: ServicesContainer
    
    init(services: DIContainer.ServicesContainer) {
        self.services = services
    }
}

extension DIContainer {
    struct LocalRepositories {
        let imageLocalRepository: AssetLocalRepository
    }
}
