//
//  CollectionViewController.swift
//  Filter App
//
//  Created by Esraa Gamal on 19/09/2021.
//

import UIKit
import Photos
import RxSwift

private let reuseIdentifier = "PhotoCollectionViewCell"

class CollectionViewController: UICollectionViewController {

    var images : [PHAsset] = []
    private let selectedPhotoSubject = PublishSubject<UIImage>()
    var selectedImage : Observable<UIImage> {
        return selectedPhotoSubject.asObserver()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllPhotos()
    }
    
    func getAllPhotos() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            switch status {
            case .authorized:
                self?.getAllAssets()
                break
            default:
                break
            }
        }
    }
    
    func getAllAssets() {
        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        assets.enumerateObjects { [weak self] object, count, stop in
            self?.images.append(object)
            self?.images.reverse()
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoCollectionViewCell else {
            fatalError("PhotoCollectionViewCell can't be found")
        }
        let asset = images[indexPath.row]
        let manager = PHImageManager.default()
        manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: nil) { image, _ in
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
        }
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let selectedAsset = images[indexPath.row]
      
        PHImageManager.default().requestImage(for: selectedAsset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFit, options: nil) { [weak self] image, info in
            guard let info = info else {return}
            let isDegraded = info["PHImageResultIsDegradedKey"] as! Bool
            if !isDegraded {
                if let image = image {
                    self?.selectedPhotoSubject.onNext(image)
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
        return true
    }

}
