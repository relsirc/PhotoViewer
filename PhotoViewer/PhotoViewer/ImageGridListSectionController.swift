//
//  ImageGridListSectionController.swift
//  PhotoViewer
//
//  Created by Crisler Chee on 18/07/2017.
//  Copyright © 2017 Crisler Chee. All rights reserved.
//


import IGListKit

final class ImageGridSectionController: ListSectionController {
    var data: ImageItem?
    
    override init() {
        super.init()
        self.inset = UIEdgeInsetsMake(1, 1, 1, 1)
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        let size = (width / 3) - 3
        return CGSize(width: size, height: size)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: ImageGridCellView.reuseIdentifier, bundle: Bundle.main, for: self, at: index) as! ImageGridCellView
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
