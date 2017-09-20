//
//  DetailsViewController.swift
//  PhotoViewer
//
//  Created by Crisler Chee on 18/07/2017.
//  Copyright © 2017 Crisler Chee. All rights reserved.
//


import Foundation
import UIKit
import KFSwiftImageLoader
import SafariServices

class DetailsViewController: UIViewController {
    
    var data: ImageItem?
    var weblinkUrl = ""
    
    @IBOutlet weak var bigImage: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var authorUrlLabel: UILabel!
    @IBOutlet weak var openOriginalPostButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let imageData = data else { return }
        
        if let idNumber = imageData.id {
            let urlString = Constants.defaultImageSizeUrl + String(describing: idNumber)
            bigImage.loadImage(urlString: urlString, placeholderImage: UIImage(named: "placeholder"), completion: nil)
            bigImage.heroID = "image" + String(describing: idNumber)
            bigImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showBiggerImage)))
        }
        
        if let authorName = imageData.author {
            authorLabel.text = authorName
            authorLabel.heroID = "text" + authorName
        }
        
        if let authorUrl = imageData.author_url {
            authorUrlLabel.text = authorUrl
            authorUrlLabel.isUserInteractionEnabled = true
            authorUrlLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openAuthorWebView)))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openOriginalPostButton.clipsToBounds = true
        openOriginalPostButton.layer.cornerRadius = 5.0
        
        shareButton.clipsToBounds = true
        shareButton.layer.cornerRadius = shareButton.frame.width / 2
    }
    
    @IBAction func closeModalView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openOriginalPostButtonPressed(_ sender: Any) {
        openPostWebView()
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        self.openShareActivity()
    }
    
    func setData(_ imageData: ImageItem) {
        data = imageData
    }
    
    // MARK: - Selector functions
    func showBiggerImage() {
        if let idNumber = data?.id {
            guard let width = data?.width, let height = data?.height else { return }
            let dimensions = String(format: "%d/%d", width, height)
            
            // loads the original dimension size
            let urlString = "https://unsplash.it/" + dimensions + "?image=" + String(describing: idNumber)
            performZoomInForStartingImageView(self.bigImage, originalImageUrl: urlString)
        }
    }
    
    func openAuthorWebView() {
        guard let urlString = data?.author_url else { return }
        openWebView(urlString: urlString)
    }
    
    func openPostWebView() {
        guard let urlString = data?.post_url else { return }
        openWebView(urlString: urlString)
    }
    
    func openWebView(urlString: String) {
        if let url = URL(string: urlString) {
            let safariVC = SFSafariViewController(url: url)
            safariVC.delegate = self
            self.present(safariVC, animated: true, completion: nil)
        }
    }
    
    func openShareActivity() {
        let shareText = data?.author ?? "Look at this awesome picture"
        if let shareImage = bigImage.image {
            let activityVC = UIActivityViewController(activityItems: [shareText, shareImage], applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Image zoom and etc
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    var zoomingImageView = UIImageView()
    
    // zooming logic
    func performZoomInForStartingImageView(_ startingImageView: UIImageView, originalImageUrl: String = "") {
        
        showLoading()
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        zoomingImageView = UIImageView(frame: startingFrame!)
        
        if originalImageUrl != "" {
            zoomingImageView.loadImage(urlString: originalImageUrl, placeholderImage: startingImageView.image, completion: { (completed, err) in
                hideLoading()
            })
        }
        else {
            zoomingImageView.image = startingImageView.image
        }
        zoomingImageView.backgroundColor = UIColor.lightGray
        
        zoomingImageView.contentMode = .scaleAspectFill
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomingImageView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(zoomPinch)))
        zoomingImageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panAction)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            blackBackgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
            blackBackgroundView?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panAction)))
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                self.zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                self.zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
            })
        }
    }
    
    func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        let zoomOutImageView = zoomingImageView
        hideLoading()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            zoomOutImageView.frame = self.startingFrame!
            self.blackBackgroundView?.alpha = 0
        }, completion: { (completed) in
            zoomOutImageView.removeFromSuperview()
            self.startingImageView?.isHidden = false
        })
        
    }
    
    var lastScale: CGFloat = 0.0
    
    func zoomPinch(_ pinchGesture: UIPinchGestureRecognizer) {
        if pinchGesture.state == .began {
            lastScale = pinchGesture.scale
        }
        
        if pinchGesture.state == .began || pinchGesture.state == .changed {
            if let myView = pinchGesture.view {
                if let currentScale = myView.layer.value(forKeyPath: "transform.scale") as? CGFloat {
                    let maxScale: CGFloat = 10.0
                    let minScale: CGFloat = 1.0
                    var newScale = 1 - (lastScale - pinchGesture.scale)
                    newScale = min(newScale, maxScale/currentScale)
                    newScale = max(newScale, minScale/currentScale)
                    let transform = (myView.transform).scaledBy(x: newScale, y: newScale)
                    pinchGesture.view?.transform = transform
                    lastScale = pinchGesture.scale
                }
            }
        }
    }
    
    func panAction(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: self.view)
        
        let myView = zoomingImageView
        myView.center = CGPoint(x: myView.center.x + translation.x, y: myView.center.y + translation.y)
        panGesture.setTranslation(.zero, in: self.view)
    }
}

extension DetailsViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
