//
//  ViewController.swift
//  Filter App
//
//  Created by Esraa Gamal on 19/09/2021.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var button : UIButton!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navC = segue.destination as? UINavigationController, let VC = navC.viewControllers.first as? CollectionViewController else {
            fatalError("Segue destination cannot be found")
        }
        VC.selectedImage.subscribe(onNext: { [weak self] photo in
            self?.updateUI(with: photo)
        }).disposed(by: disposeBag)
    }
    
    private func updateUI(with photo : UIImage) {
        imageView.image = photo
        button.isHidden = false
    }
    
    @IBAction func buttonPressed(_ sender : UIButton) {
        guard let image = imageView.image else {return}
        FilterService().applyFilter(to: image).subscribe(onNext: { filteredImage in
            DispatchQueue.main.async {
                self.imageView.image = filteredImage
            }
        }).disposed(by: disposeBag)
    }
    
}
