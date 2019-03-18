//
//  MarsPhoto.swift
//  NASAApp
//
//  Created by Jun Kakeno on 3/10/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import Foundation
import UIKit

enum ImageState {
    case placeHolder
    case downloaded
    case failed
}

class MarsPhoto: Decodable {
    let imageURL: URL
    
    enum CodingKeys: String, CodingKey {
        case imgSrc = "img_src"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.imageURL = try container.decode(URL.self, forKey: .imgSrc)
    }
}
