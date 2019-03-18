//
//  APIError.swift
//  NASAApp
//
//  Created by Jun Kakeno on 3/2/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import Foundation

enum APIError: Error {
    case requestFailed
    case responseUnsuccessful
    case jsonParsingFailure
    case noPhotos
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .requestFailed: return "Request Failed"
        case .responseUnsuccessful: return "Response Unsuccessful"
        case .jsonParsingFailure: return "JSON Parsing Failure"
        case .noPhotos: return "No Photos for given day"
        case .unknownError: return "No Data was Returned"
        }
    }
}
