//
//  FilterService.swift
//  Filter App
//
//  Created by Esraa Gamal on 19/09/2021.
//

import UIKit
import CoreImage
import RxSwift

class FilterService {
    
    private var context : CIContext
    private var filterName : String = "CICMYKHalftone"

    init() {
        self.context = CIContext()
        
    }
    func applyFilter(to inputImage: UIImage) -> Observable<UIImage> {
            return Observable<UIImage>.create { observer in
                self.applyFilter(to: inputImage) { image in
                    observer.onNext(image)
                }
                return Disposables.create()
            }
    }
    private func applyFilter(to inputImage: UIImage, completion: @escaping ((UIImage) -> ())) {
        guard let filter = CIFilter(name: filterName) else {return}
        filter.setValue(5.0, forKey: kCIInputWidthKey)
        
        if let sourceImage = CIImage(image: inputImage) {
            filter.setValue(sourceImage, forKey: kCIInputImageKey)
            if let image = context.createCGImage(filter.outputImage!, from: filter.outputImage!.extent) {
                let processedImage = UIImage(cgImage: image, scale: inputImage.scale, orientation: inputImage.imageOrientation)
                completion(processedImage)
            }
        }
    }
}
