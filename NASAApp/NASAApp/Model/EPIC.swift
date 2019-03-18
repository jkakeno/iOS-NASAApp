//
//  EPIC.swift
//  NASAApp
//
//  Created by Jun Kakeno on 3/3/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import Foundation

struct EPIC {
    let date: String
    let image: String

    enum CodingKeys: String, CodingKey {
        case date
        case image
    }
}

extension EPIC: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try container.decode(String.self, forKey: .date)
        self.image = try container.decode(String.self, forKey: .image)
    }
}
