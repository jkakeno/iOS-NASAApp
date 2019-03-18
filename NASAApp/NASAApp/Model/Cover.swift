//
//  Cover.swift
//  NASAApp
//
//  Created by Jun Kakeno on 3/8/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import Foundation
import UIKit

enum MainTitles:String{
    case apod = "APOD"
    case epic = "EPIC"
    case mars = "MARS"
    case library = "LIBRARY"
}


class Cover {
    
    var coverMainTitle: MainTitles?
    var coverSubTitle: String?
    var coverImage: UIImage?
    var apod:APOD?
    var epic:EPIC?
    
    init(coverMainTitle:MainTitles?,coverSubTitle:String?,coverImage:UIImage?,apod:APOD?,epic:EPIC?){
        self.coverMainTitle=coverMainTitle
        self.coverSubTitle=coverSubTitle
        self.coverImage=coverImage
        self.apod=apod
        self.epic=epic
    }
    
}
