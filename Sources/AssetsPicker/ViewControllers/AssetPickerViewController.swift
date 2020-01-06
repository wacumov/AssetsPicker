//
//  PhotosPickerController.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/16.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit
import enum Photos.PHAssetMediaType

public protocol AssetPickerDelegate: class {
    func photoPicker(_ pickerController: AssetPickerViewController, didPickImages images: [UIImage])
    func photoPickerDidCancel(_ pickerController: AssetPickerViewController)
    /// [Optional] Will be called when the user press the done button. At this point, you can either:
    /// - Keep or dissmiss the view controller and continue forward with the `AssetDownload` object
    /// - Wait for the images to be ready (will be provided with by the `didPickImages`
    func photoPicker(_ pickerController: AssetPickerViewController, didPickAssets assets: [AssetFuture])
}

public extension AssetPickerDelegate {
    func photoPicker(_ pickerController: AssetPickerViewController, didPickAssets assets: [AssetFuture]) {}
    func photoPicker(_ pickerController: AssetPickerViewController, didPickImages images: [UIImage]) {}
}

public final class AssetPickerViewController : UINavigationController {
    
    // MARK: - Properties
    var configuration = AssetPickerConfiguration.shared
    public weak var pickerDelegate: AssetPickerDelegate?
    private var assetFutures: [AssetFuture]?
    
    // MARK: - Lifecycle
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRootController: do  {
            let controller = SelectAssetCollectionContainerViewController(configuration: configuration)
            pushViewController(controller, animated: false)
        }
        
        setupPickImagesNotification: do {
            NotificationCenter.assetPicker.addObserver(self,
                                                   selector: #selector(didPickImages(notification:)),
                                                   name: PhotoPickerPickImagesNotificationName,
                                                   object: nil)
            NotificationCenter.assetPicker.addObserver(self,
                                                   selector: #selector(didPickAssets(notification:)),
                                                   name: PhotoPickerPickAssetsNotificationName,
                                                   object: nil)
            
            NotificationCenter.assetPicker.addObserver(self,
                                                   selector: #selector(didCancel(notification:)),
                                                   name: PhotoPickerCancelNotificationName,
                                                   object: nil)
        }
        setupNavigationBar: do {
            let dismissBarButtonItem = UIBarButtonItem(title: configuration.localize.dismiss, style: .plain, target: self, action: #selector(dismissPicker(sender:)))
            navigationBar.topItem?.leftBarButtonItem = dismissBarButtonItem
            navigationBar.tintColor = configuration.tintColor
        }
    }
    
    @objc func didPickImages(notification: Notification) {
        if let images = notification.object as? [UIImage] {
            self.pickerDelegate?.photoPicker(self, didPickImages: images)
        }
        assetFutures = nil
    }
    
    @objc func didCancel(notification: Notification) {
        self.pickerDelegate?.photoPickerDidCancel(self)
        assetFutures = nil
    }
    
    @objc func dismissPicker(sender: Any) {
        NotificationCenter.assetPicker.post(name: PhotoPickerCancelNotificationName, object: nil)
    }

    @objc func didPickAssets(notification: Notification) {
        if let downloads = notification.object as? [AssetFuture] {
            self.pickerDelegate?.photoPicker(self, didPickAssets: downloads)
            assetFutures = downloads
        }
    }
}


// MARK: Builder pattern

extension AssetPickerViewController {
    @discardableResult
    public func setSelectionMode(_ selectionMode: SelectionMode) -> AssetPickerViewController {
        configuration.selectionMode = selectionMode
        return self
    }
    
    @discardableResult
    public func setSelectionMode(_ selectionColor: UIColor) -> AssetPickerViewController {
        configuration.selectionColor = selectionColor
        return self
    }
    
    @discardableResult
    public func setSelectionColor(_ tintColor: UIColor) -> AssetPickerViewController {
        configuration.tintColor = tintColor
        return self
    }
    
    @discardableResult
    public func setNumberOfItemsPerRow(_ numberOfItemsPerRow: Int) -> AssetPickerViewController {
        configuration.numberOfItemsPerRow = numberOfItemsPerRow
        return self
    }
    
    @discardableResult
    public func setHeaderView(_ headerView: UIView, isHeaderFloating: Bool) -> AssetPickerViewController {
        configuration.headerView = headerView
        configuration.isHeaderFloating = isHeaderFloating
        return self
    }
    
    @discardableResult
    public func setCellRegistrator(_ cellRegistrator: AssetPickerCellRegistrator) -> AssetPickerViewController {
        configuration.cellRegistrator = cellRegistrator
        return self
    }
    
    @discardableResult
    public func setMediaTypes(_ supportOnlyMediaType: [PHAssetMediaType]) -> AssetPickerViewController {
        configuration.supportOnlyMediaType = supportOnlyMediaType
        return self
    }
    
    @discardableResult
    public func disableOnLibraryScrollAnimation() -> AssetPickerViewController {
        configuration.disableOnLibraryScrollAnimation = true
        return self
    }
    
    @discardableResult
    public func localize(_ localize: LocalizedStrings) -> AssetPickerViewController {
        configuration.localize = localize
        return self
    }
}
