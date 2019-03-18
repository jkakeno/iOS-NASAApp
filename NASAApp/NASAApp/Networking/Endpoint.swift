//
//  Endpoint.swift
//  NASAApp
//
//  Created by Jun Kakeno on 2/16/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import Foundation
//NASA API: https://api.nasa.gov/api.html#apod
//API Key: rT9qT3KTMkGOzKSoVtYMjFLkJ7L5sXGA3xymwEqh
//APOD url: https://api.nasa.gov/planetary/apod?api_key=rT9qT3KTMkGOzKSoVtYMjFLkJ7L5sXGA3xymwEqh
//MARS url: https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?sol=1000&camera=fhaz&api_key=rT9qT3KTMkGOzKSoVtYMjFLkJ7L5sXGA3xymwEqh
//Library: https://images-api.nasa.gov/search?q=apollo&media_type=image
//Resource: https://www.swiftbysundell.com/posts/constructing-urls-in-swift

protocol EndPoint {
    //This protocol contains all the components required to assemble the url.
    var base: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

extension EndPoint {
    //This variable assembles the url
    var urlComponents: URLComponents {   //4
        //Put the base url in this variable
        var components = URLComponents(string: base)!
        //Add the path return from 2 to the variable
        components.path = path
        //Add one of the array of query items to the variable
        components.queryItems = []
        //Add the other array of query items to the variable
        components.queryItems?.append(contentsOf: queryItems)
        //Return the complete url
        //This variable has access to all the variables nessesary to assemble the url because NasaApi adopts this protocol. Thus NasaApi has to implement the EndPoint's variables used in this computed variable to create the url.
        return components
    }
    //This computed variable converts a url into a url request neccesary to make a REST call.
    var request: URLRequest {   //5
        let url = urlComponents.url!
        return URLRequest(url: url)
    }
}

enum NasaApi {
    case apod(date: Date)      //1
    case marsRoverCuriosity(camera:String,sol:String)
    case marsRoverOportunity(camera:String,sol:String)
    case marsRoverSpirit(camera:String,sol:String)
    case earthAsset(lat: Double, long: Double, date: Date?)
    case earthImagery(lat: Double, long: Double, date: String)
}

enum GSFCApi {
    case epicList
    case epicArchive(date: String, image: String)
}

enum ImageApi {
    case image(query:String)
}

extension NasaApi: EndPoint {
    //Here all the components required to assemble the url are formed.
    var base: String {
        return "https://api.nasa.gov"
    }
    
    var path: String {
        switch self {
        case .apod: return "/planetary/apod"    //2
        case .marsRoverCuriosity: return "/mars-photos/api/v1/rovers/curiosity/photos"
        case .marsRoverOportunity: return "/mars-photos/api/v1/rovers/opportunity/photos"
        case .marsRoverSpirit: return "/mars-photos/api/v1/rovers/spirit/photos"
        case .earthAsset: return "/planetary/earth/assets"
        case .earthImagery: return "/planetary/earth/imagery/"
        }
    }
    
    var queryItems: [URLQueryItem] {
        let credential = URLQueryItem(name: "api_key", value: "rT9qT3KTMkGOzKSoVtYMjFLkJ7L5sXGA3xymwEqh")
        switch self {
        case .apod(let date):   //3
            var result = [URLQueryItem]()
            let date = URLQueryItem(name: "date", value: date.toString(withFormat: "yyyy-MM-dd"))
            let getHD = URLQueryItem(name: "hd", value: "true")
            result.append(getHD)
            result.append(date)
            result.append(credential)
            return result
        case .marsRoverCuriosity(let camera,let sol):
            var result = [URLQueryItem]()
            if camera != ""{
                let camera = URLQueryItem(name: "camera", value: "\(camera)")
                result.append(camera)
            }
            let martianDate = URLQueryItem(name: "sol", value: "\(sol)")
            result.append(martianDate)
            result.append(credential)
            return result
        case .marsRoverOportunity(let camera,let sol):
            var result = [URLQueryItem]()
            if camera != ""{
                let camera = URLQueryItem(name: "camera", value: "\(camera)")
                result.append(camera)
            }
            let martianDate = URLQueryItem(name: "sol", value: "\(sol)")
            result.append(martianDate)
            result.append(credential)
            return result
        case .marsRoverSpirit(let camera,let sol):
            var result = [URLQueryItem]()
            if camera != ""{
                let camera = URLQueryItem(name: "camera", value: "\(camera)")
                result.append(camera)
            }
            let martianDate = URLQueryItem(name: "sol", value: "\(sol)")
            result.append(martianDate)
            result.append(credential)
            return result
        case .earthAsset(let lat, let long, let date):
            var result = [URLQueryItem]()
            if let date = date {
                let date = URLQueryItem(name: "begin", value: date.toString(withFormat: "yyyy-MM-dd"))
                result.append(date)
            }
            let long = URLQueryItem(name: "lon", value: "\(long)")
            let lat = URLQueryItem(name: "lat", value: "\(lat)")
            result.append(long)
            result.append(lat)
            result.append(credential)
            return result
        case .earthImagery(let lat, let long, let date):
            var result = [URLQueryItem]()
            let long = URLQueryItem(name: "lon", value: "\(long)")
            let lat = URLQueryItem(name: "lat", value: "\(lat)")
            let date = URLQueryItem(name: "date", value: date)
            result.append(long)
            result.append(lat)
            result.append(date)
            result.append(credential)
            return result
        }
    }
}

extension GSFCApi:EndPoint{
    var base: String {
        return "https://epic.gsfc.nasa.gov"
    }
    
    var path: String {
        switch self {
        case .epicList:
            return "/api/natural"
        case .epicArchive(let date, let image):
            //Make the epic image url using the date and the image passed
            let dateArray = date.split{$0 == "-"}.map(String.init)
            let year = dateArray[0]
            let month = dateArray[1]
            let dayArray = dateArray[2].split(separator: " ").map(String.init)
            let day = dayArray[0]
            let dateString = "\(year)/\(month)/\(day)"
            return "/archive/natural/\(dateString)/png/\(image).png"
        }
    }
    
    //Return empty query because EPIC doesn't need query parameters
    var queryItems: [URLQueryItem] {
        switch self {
        case .epicList:
            return [URLQueryItem]()
        case .epicArchive:
            return [URLQueryItem]()
        }
    }
}

extension ImageApi:EndPoint{
    var base: String {
        return "https://images-api.nasa.gov"
    }
    
    var path: String {
        return "/search"
    }
    
    var queryItems: [URLQueryItem] {
        var result = [URLQueryItem]()
        switch self {
        case .image(let query):
            let query = URLQueryItem(name: "q", value: "\(query)")
            let mediaType = URLQueryItem(name:"media_type", value:"image")
            result.append(query)
            result.append(mediaType)
            return result
        }
    }
}


