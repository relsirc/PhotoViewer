//
//  ImageGridCellView.swift
//  PhotoViewer
//
//  Created by Crisler Chee on 18/07/2017.
//  Copyright © 2017 Crisler Chee. All rights reserved.
//

import UIKit
import Reusable
import KFSwiftImageLoader
import Hero

final class ImageGridCellView: UICollectionViewCell, NibReusable {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setData(_ data: ImageItem) {
        if let idNumber = data.id {
            let urlString = Constants.defaultImageSizeUrl + String(describing: idNumber)
            imageView.loadImage(urlString: urlString, placeholderImage: UIImage(named: "placeholder"), completion: nil)
            imageView.heroID = "image" + String(describing: idNumber)
        }
    }
}
