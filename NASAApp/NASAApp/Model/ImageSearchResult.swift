//
//  ImageSearchResult.swift
//  NASAApp
//
//  Created by Jun Kakeno on 3/15/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import Foundation
import UIKit

struct ImageSearchResult: Decodable{
    let collection: Collection
}

struct Collection: Decodable{
    let items: [Item]
}

struct Item: Decodable{
    let data: [Data]
    let links:[Link]
}

struct Data: Decodable{
    let title:String
    let description:String
}

struct Link: Decodable {
    let href:URL
}
