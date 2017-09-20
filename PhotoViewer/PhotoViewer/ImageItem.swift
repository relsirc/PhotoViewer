//
//  ImageItem.swift
//  PhotoViewer
//
//  Created by Crisler Chee on 18/07/2017.
//  Copyright © 2017 Crisler Chee. All rights reserved.
//

import Foundation
import ObjectMapper
import IGListKit

final class ImageItem: Mappable {
    
    var author: String?
    var author_url: String?
    var filename: String?
    var id: Int?
    var post_url: String?
    var height: Int?
    var width: Int?
    var format: String?
    
    required init?(map: Map){
        
    }
    
    init() {
        
    }
    
    func mapping(map: Map) {
        self.author <- map["author"]
        self.author_url <- map["author_url"]
        self.filename <- map["filename"]
        self.id <- map["id"]
        self.post_url <- map["post_url"]
        self.height <- map["height"]
        self.width <- map["width"]
    }
}

extension ImageItem: Equatable {
    static func == (lhs: ImageItem, rhs: ImageItem) -> Bool {
        return lhs.id == rhs.id
    }
}

extension ImageItem: ListDiffable {
    public func diffIdentifier() -> NSObjectProtocol {
        return id! as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? ImageItem else { return false }
        return id == object.id
    }
}
