//
//  ImageListSectionController.swift
//  PhotoViewer
//
//  Created by Crisler Chee on 18/07/2017.
//  Copyright © 2017 Crisler Chee. All rights reserved.
//


import IGListKit

final class ImageListSectionController: ListSectionController {
    var data: ImageItem?
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        
        // 375  250 is the ideal ratio from my design
        let scale = width / 375
        let height = 250 * scale
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: ImageListCellView.reuseIdentifier, bundle: Bundle.main, for: self, at: index) as! ImageListCellView
        if let imageData = data {
            cell.setData(imageData)
        }
        return cell
    }
    
    override func didUpdate(to object: Any) {
        data = object as? ImageItem
    }
    override func didSelectItem(at index: Int) {
        if let vc = UIStoryboard(name: "Details", bundle: nil).instantiateInitialViewController() as? DetailsViewController {
            if let imageData = data {
                vc.setData(imageData)
                viewController?.present(vc, animated: true, completion: nil)
            }
        }
    }
}

