//
//  EarthPhoto.swift
//  NASAApp
//
//  Created by Jun Kakeno on 3/13/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import Foundation
import UIKit

struct EarthPhoto: Decodable{
    var date: String?
    let url: URL
    
    enum CodingKeys: String, CodingKey {
        case url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(URL.self, forKey: .url)
    }
    
}
