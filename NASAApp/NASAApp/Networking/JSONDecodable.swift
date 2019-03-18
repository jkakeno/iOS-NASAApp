//
//  JSONDecodable.swift
//  NASAApp
//
//  Created by Jun Kakeno on 2/16/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import Foundation

protocol JSONDecodable {
    //Potocole to enable models that adopt this protocole to be initialized by passing a json
    init?(json: [String: Any])
}

