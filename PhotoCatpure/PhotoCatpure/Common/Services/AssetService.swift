//
//  AssetService.swift
//  PhotoCatpure
//
//  Created by Dmytro Kmytiuk on 24.03.2024.
//

import RxSwift

protocol AssetService {
    func fetchAssets() -> Observable<[String]>
    func saveAssets(localIdentifier: String)
    func cleanUpDatabase()
}

struct ImageServiceImpl: AssetService {
        
    private let repository: AssetLocalRepository
    
    init(repository: AssetLocalRepository) {
        self.repository = repository
    }
 
    func fetchAssets() -> Observable<[String]> {
        repository.fetchAssets()
    }
    
    func cleanUpDatabase() {
        repository.cleanUpDatabase()
    }
    
    func saveAssets(localIdentifier: String) {
        repository.saveAssets(localIdentifier)
    }
}
