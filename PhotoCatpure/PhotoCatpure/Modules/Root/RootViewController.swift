//
//  RootViewController.swift
//  PhotoCatpure
//
//  Created by Dmytro Kmytiuk on 21.03.2024.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Photos

class RootViewController: UIViewController {
    
    var bag: DisposeBag {
        return viewModel.bag
    }
    
    // MARK: UIElements
    private let mainImageView = UIImageView()
    private let buttonsStack = UIStackView()
    private let deleteButton = UIButton()
    private let saveButton = UIButton()
    private let trashView = UIView()
    private let imageCounterLabel = UILabel()
    private let imagesInTrashLabel = UILabel()
    private let cleanTrashButton = UIButton()
    private let infoLabel = UILabel()

    // MARK: Lifecycle
    private let viewModel: ViewModelType
    
    init(viewModel: ViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        handleAuthorizationStatus()
        setupConstraints()
        setupUI()
        bindEvents()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        deleteButton.makeCircle()
        saveButton.makeCircle()
    }
    
    // MARK: Private
    private func setupConstraints() {
        view.addSubview(mainImageView)
        view.addSubview(buttonsStack)
        buttonsStack.addArrangedSubview(deleteButton)
        buttonsStack.addArrangedSubview(saveButton)
        view.addSubview(trashView)
        trashView.addSubview(imageCounterLabel)
        trashView.addSubview(imagesInTrashLabel)
        trashView.addSubview(cleanTrashButton)
        view.addSubview(infoLabel)
        
        mainImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeArea.top)
            make.leading.equalToSuperview().offset(LocalConstants.superviewOffset)
            make.trailing.equalToSuperview().offset(-LocalConstants.superviewOffset)
            make.height.equalTo(view.frame.height * 0.7)
        }
        buttonsStack.snp.makeConstraints { make in
            make.bottom.equalTo(mainImageView.snp.bottom).offset(-LocalConstants.buttonStackBottomSpacing)
            make.centerX.equalToSuperview()
        }
        deleteButton.snp.makeConstraints { make in
            make.width.equalTo(LocalConstants.buttonsSize)
            make.height.equalTo(LocalConstants.buttonsSize)
        }
        saveButton.snp.makeConstraints { make in
            make.height.equalTo(LocalConstants.buttonsSize)
            make.width.equalTo(LocalConstants.buttonsSize)
        }
        trashView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeArea.bottom).offset(-LocalConstants.trashViewBottomOffset)
            make.height.equalTo(LocalConstants.trashViewHeight)
            make.leading.equalToSuperview().offset(LocalConstants.superviewOffset)
            make.trailing.equalToSuperview().offset(-LocalConstants.superviewOffset)
        }
        imageCounterLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(LocalConstants.trashViewOffset)
        }
        imagesInTrashLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(imageCounterLabel.snp.trailing).offset(LocalConstants.trashViewOffset)
        }
        cleanTrashButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-LocalConstants.trashViewOffset)
            make.height.equalTo(LocalConstants.clesanTrashButtonHeight)
            make.width.equalTo(LocalConstants.cleanTrashButtonWidth)
        }
        infoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-LocalConstants.ingoLabelVerticalSpacing)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .mainBlack
        mainImageView.makeCorners(radius: LocalConstants.mainCornerRadius)
        mainImageView.contentMode = .scaleAspectFill
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = LocalConstants.buttonStackSpacing
        deleteButton.backgroundColor = .weightRed
        deleteButton.setImage(UIImage(named: LocalConstants.wastebasket), for: .normal)
        saveButton.backgroundColor = .saveGreen
        saveButton.setImage(UIImage(named: LocalConstants.checkMark), for: .normal)
        trashView.backgroundColor = .mainIndigo
        trashView.makeCorners(radius: LocalConstants.mainCornerRadius)
        imageCounterLabel.textColor = .white
        imageCounterLabel.font = .systemFont(ofSize: LocalConstants.counterFontSize, weight: .bold)
        imagesInTrashLabel.text = LocalConstants.imagesInTrashLabelTitle
        imagesInTrashLabel.textColor = .white
        imageCounterLabel.textAlignment = .left
        imagesInTrashLabel.font = .systemFont(ofSize: LocalConstants.infoLabelFontSize, weight: .medium)
        imagesInTrashLabel.numberOfLines = .zero
        infoLabel.text = LocalConstants.infoLabelTitle
        infoLabel.font = .systemFont(ofSize: LocalConstants.infoLabelFontSize, weight: .black)
        infoLabel.textColor = .skyIndigo
        cleanTrashButton.backgroundColor = .lightIndigo
        cleanTrashButton.makeCorners(radius: LocalConstants.cleanTrashButtonCorners)
        cleanTrashButton.setTitle(LocalConstants.cleanTrashButtonTitle, for: .normal)
        cleanTrashButton.setImage(UIImage(named: LocalConstants.bluerWasteBasket), for: .normal)
        cleanTrashButton.setTitleColor(.skyIndigo, for: .normal)
    }
    
    private func bindEvents() {
        saveButton.rx
            .tap
            .asObservable()
            .bind(to: viewModel.input.saveButtonPressed)
            .disposed(by: bag)
        
        deleteButton.rx
            .tap
            .asObservable()
            .bind(to: viewModel.input.deleteButtonPressed)
            .disposed(by: bag)
        
        cleanTrashButton.rx
            .tap
            .asObservable()
            .bind(to: viewModel.input.clearTrashButtonPressed)
            .disposed(by: bag)
        
        viewModel.output.currentPhoto
            .subscribe(onNext: { [weak self] image in
                guard let self else { return }
                if let image = image {
                    self.mainImageView.image = image
                } else {
                    self.mainImageView.image = .none
                }
            })
            .disposed(by: bag)
        
        viewModel.output.deletedPhotos
            .map { "\($0.count)" }
            .observe(on: MainScheduler.instance)
            .bind(to: imageCounterLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.output.deletedPhotos
            .map { $0.count != 0 }
            .bind(to: cleanTrashButton.rx.isEnabled)
            .disposed(by: bag)
        
        viewModel.output.currentPhoto
            .map { $0.isNotNil }
            .subscribe(onNext: { [weak self] value in
                guard let self else { return }
                self.saveButton.isEnabled = value
                self.deleteButton.isEnabled = value
                self.infoLabel.isHidden = value

            })
            .disposed(by: bag)
    }
    
}

// MARK: - Extension
private extension RootViewController {
    func handleAuthorizationStatus() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            DispatchQueue.main.async { [weak self] in
                self?.viewModel.fetchLastAsset()
            }
        case .restricted, .denied:
            showPhotoLibraryRestrictedAlert()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                if status == .authorized {
                    self?.viewModel.fetchLastAsset()
                }
            }
        @unknown default:
            break
        }
    }

    func showPhotoLibraryRestrictedAlert() {
        let alert = UIAlertController(title: LocalConstants.photoLibraryAlertTitle,
                                      message: LocalConstants.photoLibraryAlertMessage,
                                      preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
        alert.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: LocalConstants
fileprivate enum LocalConstants {
    // MARK: Sizes
    static let buttonsSize: CGFloat = 60
    static let superviewOffset: CGFloat = 32
    static let trashViewOffset: CGFloat = 12
    static let mainCornerRadius: CGFloat = 24
    static let buttonStackBottomSpacing: CGFloat = 16
    static let trashViewHeight: CGFloat = 72
    static let trashViewBottomOffset: CGFloat = 24
    static let clesanTrashButtonHeight:  CGFloat = 48
    static let cleanTrashButtonWidth: CGFloat = 179
    static let ingoLabelVerticalSpacing: CGFloat = 150
    static let buttonStackSpacing: CGFloat = 110
    static let counterFontSize: CGFloat = 26
    static let infoLabelFontSize: CGFloat = 14
    static let cleanTrashButtonCorners: CGFloat = 12
    // MARK: Titles
    static let imagesInTrashLabelTitle: String = "images in\nthe trash"
    static let infoLabelTitle: String = "All photos have been processed"
    static let cleanTrashButtonTitle: String = "  Empty Trash"
    static let photoLibraryAlertTitle: String = "Access to Photo Library Restricted"
    static let photoLibraryAlertMessage = "Please grant access to the Photo Library in Settings to use this feature."
    // MARK: ImagesName
    static let bluerWasteBasket: String = "blueWastebasket"
    static let checkMark: String = "checkMark"
    static let wastebasket: String = "wastebasket"
}
