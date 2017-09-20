//
//  ImageListCellView.swift
//  PhotoViewer
//
//  Created by Crisler Chee on 18/07/2017.
//  Copyright © 2017 Crisler Chee. All rights reserved.
//

import UIKit
import Reusable
import KFSwiftImageLoader
import Hero

final class ImageListCellView: UICollectionViewCell, NibReusable {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    
    func setData(_ data: ImageItem) {
        if let idNumber = data.id {
            let urlString = Constants.defaultImageSizeUrl + String(describing: idNumber)
            imageView.loadImage(urlString: urlString, placeholderImage: UIImage(named: "placeholder"), completion: nil)
            imageView.heroID = "image" + String(describing: idNumber)
        }
        
        if let author = data.author {
            authorLabel.text = author
            authorLabel.heroID = "text" + author
        }
    }
}
