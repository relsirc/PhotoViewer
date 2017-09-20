//
//  APIHelper.swift
//  PhotoViewer
//
//  Created by Crisler Chee on 18/07/2017.
//  Copyright © 2017 Crisler Chee. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

class APIHelper {
    struct Static {
        fileprivate static var instance: APIHelper?
    }
    
    class var sharedInstance: APIHelper {
        if Static.instance == nil {
            Static.instance = APIHelper()
        }
        
        return Static.instance!
    }
    fileprivate init() {}
    
    func destroy() {
        APIHelper.Static.instance = nil
        DLog("APIHelper Singleton instance destroyed.")
    }
    
    func getImageList(_ callback: @escaping([ImageItem]?)->()) {
        Alamofire.request("https://unsplash.it/list").responseArray { (response: DataResponse<[ImageItem]>) in
            let resultArray = response.result.value
            
            if let returnArray = resultArray {
                callback(returnArray)
            }
            else {
                callback(nil)
            }
        }
    }
}
