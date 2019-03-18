//
//  EarthPhotoList.swift
//  NASAApp
//
//  Created by Jun Kakeno on 3/13/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import Foundation
import UIKit

//Parse API object tutorial: https://www.youtube.com/watch?v=YY3bTxgxWss

struct EarthPhotoAsset: Decodable{
    let count: Int
    let results: [Result]
}

struct Result: Decodable{
    let date: String
}
