//
//  ImageCollectionViewCell.swift
//  DemoTask
//
//  Created by Surjeet on 06/07/21.
//

import UIKit
import Kingfisher

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!

    func setData(_ data: BreedImage) {
        if let imageURL = data.url, !imageURL.isEmpty {
            let url = URL(string: imageURL)
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = nil
        }
    }
    
}
