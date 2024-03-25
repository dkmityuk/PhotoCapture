//
//  ServicesContainer.swift
//  PhotoCatpure
//
//  Created by Dmytro Kmytiuk on 24.03.2024.
//

import Foundation

extension DIContainer {
    
    struct ServicesContainer {
        let imageService: AssetService
        
        init(imageService: AssetService) {
            self.imageService = imageService
        }
    }
}

