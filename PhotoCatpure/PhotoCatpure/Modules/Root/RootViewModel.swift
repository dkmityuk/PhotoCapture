//
//  RootViewModel.swift
//  PhotoCatpure
//
//  Created by Dmytro Kmytiuk on 23.03.2024.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import Photos

protocol ViewModelInput {
    var buttonPressed: PublishRelay<Void> { get }
    var saveButtonPressed: PublishRelay<Void> { get }
    var deleteButtonPressed: PublishRelay<Void> { get }
    var clearTrashButtonPressed: PublishRelay<Void> { get }
}

protocol ViewModelOutput {
    var currentPhoto: Observable<UIImage?> { get }
    var deletedPhotos: Observable<[String]> { get }
}

protocol ViewModelType {
    var bag: DisposeBag { get }
    var input: ViewModelInput { get }
    var output: ViewModelOutput { get }
    func fetchLastAsset()
}

final class RootViewModel:
    ViewModelInput,
    ViewModelOutput,
    ViewModelType
{
    var buttonPressed = PublishRelay<Void>()
    var saveButtonPressed = PublishRelay<Void>()
    var deleteButtonPressed = PublishRelay<Void>()
    var clearTrashButtonPressed = PublishRelay<Void>()
    
    let bag = DisposeBag()
    var input: ViewModelInput { return self }
    var output: ViewModelOutput { return self }
    
    var currentAsset: PHAsset?
    private let fetchOptions = PHFetchOptions()
    private let container: DIContainer
    
    private let currentPhotoSubject = BehaviorSubject<UIImage?>(value: nil)
    var currentPhoto: Observable<UIImage?> {
        return currentPhotoSubject.asObservable()
    }
    private var deletedPhotosSubject = BehaviorSubject<[String]>(value: [])
    var deletedPhotos: Observable<[String]> {
        return deletedPhotosSubject.asObservable()
    }
    
    init(container: DIContainer) {
        self.container = container
        bindEvents()
        updateTrashContent()
    }
    
    // MARK: BindEvents
    private func bindEvents() {
        saveButtonPressed
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                guard let currentAsset else { return }
                self.fetchPreviusAsset(asset: currentAsset)
            })
            .disposed(by: bag)
        
        deleteButtonPressed
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                guard let currentAsset else { return }
                self.moveAssetToTrash(asset: currentAsset)
            })
            .disposed(by: bag)

        clearTrashButtonPressed
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.cleanTrash()
            })
            .disposed(by: bag)
    }
    
    // MARK: - AssetManagement
     func fetchLastAsset() {
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        guard let lastAsset = fetchResult.firstObject else { return }
        currentAsset = lastAsset
        do {
            if try deletedPhotosSubject.value().contains(lastAsset.localIdentifier) {
                fetchPreviusAsset(asset: lastAsset)
            } else {
                loadPhoto(asset: lastAsset)
            }
        } catch { return }
    }
    
    private func fetchPreviusAsset(asset: PHAsset) {
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let predicate = NSPredicate(format: "creationDate < %@", argumentArray: [asset.creationDate as Any])
            fetchOptions.predicate = predicate
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        guard fetchResult.firstObject != nil else {
            currentPhotoSubject.onNext(nil)
            return
        }
            currentAsset = fetchResult.firstObject
        do {
            if try deletedPhotosSubject.value().contains(currentAsset?.localIdentifier ?? "") {
                fetchPreviusAsset(asset: currentAsset ?? asset)
            } else {
                loadPhoto(asset: currentAsset ?? asset)
            }
        } catch { return }
    }
        
    private func loadPhoto(asset: PHAsset) {
        PHImageManager
            .default()
            .requestImage(for: asset,
                          targetSize: .zero,
                          contentMode: .aspectFit,
                          options: nil) { [weak self] (image, _) in
            DispatchQueue.main.async {
                self?.currentPhotoSubject.onNext(image)
            }
        }
    }
    
    // MARK: - TrashManagement
    private func moveAssetToTrash(asset: PHAsset) {
        container
            .services
            .imageService
            .saveAssets(localIdentifier: asset.localIdentifier)
            updateTrashContent()
        fetchPreviusAsset(asset: asset)
    }
    
    private func cleanTrash() {
        container
            .services
            .imageService
            .fetchAssets()
            .subscribe(onNext: { [weak self] id in
            self?.deletePhotoesFromGallery(with: id)
        })
            .disposed(by: bag)
    }
    
    private func updateTrashContent() {
        container
            .services
            .imageService
            .fetchAssets()
            .subscribe(onNext: { [weak self] locallIDs in
                DispatchQueue.global().async {
                    self?.deletedPhotosSubject.onNext(locallIDs)
                }
            })
            .disposed(by: bag)
    }
    
    private func deletePhotoesFromGallery(with localIdentifier: [String]) {
        let photoLibrary = PHPhotoLibrary.shared()
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifier, options: nil)
        
        var assetsToDelete = [PHAsset]()
        fetchResult.enumerateObjects { asset, index, _ in
            assetsToDelete.append(asset)
        }
        photoLibrary.performChanges({
            PHAssetChangeRequest.deleteAssets(assetsToDelete as NSArray)
        }) { success, error in
            if success {
                self.cleanUpDatabase()
            } else { return }
        }
    }
    
    private func cleanUpDatabase() {
        container
            .services
            .imageService
            .cleanUpDatabase()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.updateTrashContent()
        }
    }
    
}
