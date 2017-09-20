//
//  ViewController.swift
//  PhotoViewer
//
//  Created by Crisler Chee on 18/07/2017.
//  Copyright © 2017 Crisler Chee. All rights reserved.
//

import UIKit
import KFSwiftImageLoader
import IGListKit

import Alamofire

class ViewController: UIViewController {
    
    var allImages = [ImageItem]()
    var returnData = [ImageItem]()
    var showGrid = false
    var loading = false
    let itemIncrement = 20
    var page = 0

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self

        Alamofire.request("https://api.gwentapi.com/v0/cards")
            .responseJSON {
            response in
            
            print(response)
        }
        
        showLoading()
        APIHelper.sharedInstance.getImageList { (items) in
            if let itemsArray = items {
                self.allImages = itemsArray.shuffled()
                self.getMoreImages()
                self.adapter.performUpdates(animated: true)
                hideLoading()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        } else {
            print("3D Touch Not Available")
        }
    }
    
    func getMoreImages() {
        
        guard allImages.count > 0 else { return }
        
        for _ in 0..<itemIncrement {
            if let item = allImages.popLast() {
                returnData.append(item)
            }
        }
    }
    
    @IBAction func toggleViewLayout(_ sender: Any) {
        showGrid = !showGrid
        self.adapter.reloadData(completion: nil)
    }
}

extension ViewController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        let objects = returnData as [ListDiffable]
        return objects
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if showGrid {
            return ImageGridSectionController()
        }
        else {
            return ImageListSectionController()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension ViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let adjustedLocation = CGPoint(x: location.x + collectionView.contentOffset.x, y: location.y + collectionView.contentOffset.y)
        guard let indexPath = self.collectionView.indexPathForItem(at: adjustedLocation) else {
            print("Cant find indexpath")
            return nil
        }
        
        // when I used the IGList it uses the section instead of rows
        let imageData = self.returnData[indexPath.section]
        guard let detailsViewController = UIStoryboard(name: "Details", bundle: nil).instantiateInitialViewController() as? DetailsViewController else { return nil }
        
        detailsViewController.preferredContentSize =
            CGSize(width: 0.0, height: 600)
        detailsViewController.setData(imageData)
        previewingContext.sourceRect = CGRect.zero
        return detailsViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        //show(viewControllerToCommit, sender: self)
    }
}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        if !loading && distance < 200 {
            loading = true
            adapter.performUpdates(animated: true, completion: nil)
            DispatchQueue.global(qos: .default).async {
                self.getMoreImages()
                DispatchQueue.main.async {
                    self.loading = false
                    self.adapter.performUpdates(animated: true, completion: nil)
                }
            }
        }
    }
}
