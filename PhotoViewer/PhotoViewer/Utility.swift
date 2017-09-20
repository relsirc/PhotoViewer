//
//  Utility.swift
//  PhotoViewer
//
//  Created by Crisler Chee on 20/07/2017.
//  Copyright © 2017 Crisler Chee. All rights reserved.
//

import Foundation
import SVProgressHUD

struct Constants {
    static let defaultImageSizeUrl = "https://unsplash.it/375/250?image="
}

public func showLoading() {
    SVProgressHUD.show()
}

public func hideLoading() {
    SVProgressHUD.dismiss()
}

