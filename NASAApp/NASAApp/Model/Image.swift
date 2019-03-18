//
//  Image.swift
//  NASAApp
//
//  Created by Jun Kakeno on 3/16/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import Foundation
import UIKit

class Image{
    
    var image:UIImage?
    var imageTitle:String?
    var imageDescription:String?
    
    init(image:UIImage?,title:String?,description:String?) {
        self.image = image
        self.imageTitle = title
        self.imageDescription = description
    }
    
}
