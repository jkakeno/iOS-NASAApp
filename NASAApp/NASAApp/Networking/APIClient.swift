//
//  APIClient.swift
//  NASAApp
//
//  Created by Jun Kakeno on 2/16/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import Foundation
import UIKit


class ApiClient {
    
    //Sessions are neccesary to get the object response from a REST call
    let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    /* Custom method to get Astronomy Picture of the Day
     - Parameters:
     - date: The date of which you want the astronomy picture
     - completion: A completion handler that provides the data or an error depending upon the response
     NOTE: Custom method that takes a Date argument and has the signature of a completion handler. Since this method will get an APOD from the NasaApi it needs a completion handler to execute code after the method receives the response from the network.*/
    
    func getAPOD(date: Date, completion: @escaping (APOD?, APIError?) -> Void) {
        let endPoint = NasaApi.apod(date: date)
        let request = endPoint.request
        print("Endpoint: \(endPoint)")
        print("Request: \(request)")
        
        //Session deliver results to a completion handler block.
        //Execute the completion handler in a closure. The format of the closure is defined by the native method dataTask().
        let task = session.dataTask(with: request) {data, response, error in
            //Get a HTTPResponse, otherwise make the completion handler return an error message defined in API Error enum
            guard let httpResponse = response as? HTTPURLResponse else { completion(nil, .requestFailed); return }
            //Check that the HTTPResponse status code is 200 (success)
            if httpResponse.statusCode == 200 {
                print("APOD response OK")
                //Get the data from the response
                if let data = data {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        /// `JSONDecoder` facilitates the decoding of JSON into semantic `Decodable` types.
                        let decoder = JSONDecoder()
                        /// Convert from "snake_case_keys" to "camelCaseKeys" before attempting to match a key with the one specified by each type.
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        /// Decode the `Date` as a string parsed by the given formatter.
                        decoder.dateDecodingStrategy = .formatted(formatter)
                        do {
                            //Parse the HTTP response data (JSON) into our model
                            let apod = try decoder.decode(APOD.self, from: data)
                            //Make the completion handler return our model is data received from the API
                            completion(apod, nil)
                        } catch {
                            completion(nil, .jsonParsingFailure)
                        }
                }
            } else {
                completion(nil, .responseUnsuccessful)
            }
            
            if let _ = error {
                completion(nil, .unknownError)
            }
        }
        task.resume()
    }
    
    /* Custom method to gets a list of images from the Earth Polychromatic Imaging Camera
        NOTE: Custom method takes no parameters to calls a fix url and has the signature of a completion handler. This method gets a list of EPIC from the NasaApi each EPIC has a date which will be used in another method to get the image url. The completion handler will execute code after the method receives the response from the network.*/
    
    func getEPIC(completion: @escaping ([EPIC]?, APIError?) -> Void) {
        let endPoint = GSFCApi.epicList
        let request = endPoint.request
        print("Endpoint: \(endPoint)")
        print("Request: \(request)")
        let task = session.dataTask(with: request) {data, response, error in
            //Get a HTTPResponse, otherwise make the completion handler return an error message defined in API Error enum
            guard let httpResponse = response as? HTTPURLResponse else { completion(nil, .requestFailed); return }
            //Check that the HTTPResponse status code is 200 (success)
            if httpResponse.statusCode == 200 {
                print("EPIC response OK")
                //Get the data from the response
                if let data = data {
                    //data is the JSON response from the API, so print the JSON to see what the JSON response looks like
//                    print(try! JSONSerialization.jsonObject(with: data, options: []))

                    //Return to the main thread
                    DispatchQueue.main.async {
                        /// `JSONDecoder` facilitates the decoding of JSON into semantic `Decodable` types.
                        let decoder = JSONDecoder()

                        do {
                            //Parse the HTTP response data (JSON) into our model
                            let epicList = try decoder.decode([EPIC].self, from: data)

                            //Make the completion handler return an array of our model is data received from the API
                            completion(epicList, nil)
                        } catch {
                            completion(nil, .jsonParsingFailure)
                        }
                    }
                }
            } else {
                completion(nil, .responseUnsuccessful)
            }
            
            if let _ = error {
                completion(nil, .unknownError)
            }
        }
        task.resume()
    }
    
/*Custom method that gets Mars Rover images
 - Parameters:
     - rover: The name of one of three rovers in Mars
     - camera: The name of the camera installed on the rover
     - sol: The date in Martian sol that indicates the date when the images were taken
     - completion: A completion handler that provides the data or an error depending upon the response*/
    func getMarsPhotos(rover:Rover,camera:String,sol:String, completion: @escaping([MarsPhoto]?, APIError?) -> Void) {
        let endPoint:NasaApi
        switch rover {
        case .curiosity:
            endPoint = NasaApi.marsRoverCuriosity(camera: camera, sol: sol)
        case .oportunity:
            endPoint = NasaApi.marsRoverOportunity(camera: camera, sol: sol)
        case .spirit:
            endPoint = NasaApi.marsRoverSpirit(camera: camera, sol: sol)
        }
        let request = endPoint.request
        print("Endpoint: \(endPoint)")
        print("Request: \(request)")
        let task = session.dataTask(with: request) {data, response, error in
            DispatchQueue.main.async {
                if let _ = error {
                    completion(nil, .unknownError)
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(nil, .requestFailed)
                    return
                }
                if httpResponse.statusCode == 200 {
                    if let data = data {
//                        print(try! JSONSerialization.jsonObject(with: data, options: []))
                        let decoder = JSONDecoder()
                        do {
                            let photosDict = try decoder.decode([String:[MarsPhoto]].self, from: data)
                            let photoURLS = photosDict["photos"]!
                            if photoURLS.isEmpty {
                                completion(nil, .noPhotos)
                            } else {
                                completion(photoURLS, nil)
                            }
                        } catch {
                            completion(nil, APIError.jsonParsingFailure)
                        }
                    }
                } else {
                    completion(nil, .responseUnsuccessful)
                }
            }
        }
        task.resume()
    }
    
    /*Custom method that a list of Images of Earth
     - Parameters:
     - lat: Latitude on Earth to indicate the location where the images were taken
     - long: Longitude on Earth to indicate the location where the images were taken
     - date: The date when the images were taken
     - completion: A completion handler that provides the data or an error depending upon the response
     NOTE: This call gets a list of images of Earth to get a list of valid dates for the images. The dates will be used in a different method to get the actual image.*/
    func getEarthAsset(lat: Double, long: Double, date: Date, completion: @escaping (EarthPhotoAsset?, APIError?) -> Void ) {
        let endPoint = NasaApi.earthAsset(lat: lat, long: long, date: date)
        let request = endPoint.request
        print("Endpoint: \(endPoint)")
        print("Request: \(request)")
        let task = session.dataTask(with: request) {data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    guard let response = response as? HTTPURLResponse else { completion(nil, .responseUnsuccessful); print("taco"); return }
                    if response.statusCode == 200 {
                        let decoder = JSONDecoder()
                        do {
                            let earthPhotoAsset = try decoder.decode(EarthPhotoAsset.self, from: data)
                            completion(earthPhotoAsset, nil)
                        } catch {
                            completion(nil, APIError.jsonParsingFailure)
                        }
                    } else {
                        completion(nil, APIError.responseUnsuccessful)
                    }
                } else if let _ = error {
                    completion(nil, .unknownError)
                }
            }
        }
        task.resume()
    }
    

    /*Custom method that gets Images of Earth
     - Parameters:
     - lat: Latitude on Earth to indicate the location where the images were taken
     - long: Longitude on Earth to indicate the location where the images were taken
     - date: The date when the images were taken
     - completion: A completion handler that provides the data or an error depending upon the response.
     NOTE: This method gets the actual images of Earth using the valid dates collected by the method above.*/
    func getEarthImage(lat: Double, long: Double, date: String, completion: @escaping (EarthPhoto?, APIError?) -> Void ) {
        let endPoint = NasaApi.earthImagery(lat: lat, long: long, date: date)
        let request = endPoint.request
        print("Endpoint: \(endPoint)")
        print("Request: \(request)")
        let task = session.dataTask(with: request) {data, response, error in
            if let data = data {
                guard let response = response as? HTTPURLResponse else { completion(nil, .responseUnsuccessful); print("taco"); return }
                if response.statusCode == 200 {
                    let decoder = JSONDecoder()
                    do {
                        let earthImage = try decoder.decode(EarthPhoto.self, from: data)
                        completion(earthImage, nil)
                    } catch {
                        completion(nil, APIError.jsonParsingFailure)
                    }
                } else {
                    completion(nil, APIError.responseUnsuccessful)
                }
            } else if let _ = error {
                completion(nil, .unknownError)
            }
        }
        task.resume()
    }
    
    /*Custom method that gets Images from the NASA Image Library
     - Parameters:
     - query: keyword that the NASA API uses to search for images
     - completion: A completion handler that provides the data or an error depending upon the response*/
    func searchImageLibrary(query: String, completion: @escaping (ImageSearchResult?, APIError?) -> Void ) {
        let endPoint = ImageApi.image(query: query)
        let request = endPoint.request
        print("Endpoint: \(endPoint)")
        print("Request: \(request)")
        let task = session.dataTask(with: request) {data, response, error in
            if let data = data {
                guard let response = response as? HTTPURLResponse else { completion(nil, .responseUnsuccessful); print("taco"); return }
                if response.statusCode == 200 {
                    let decoder = JSONDecoder()
                    do {
                        let imageSearchResult = try decoder.decode(ImageSearchResult.self, from: data)
                        completion(imageSearchResult, nil)
                    } catch {
                        completion(nil, APIError.jsonParsingFailure)
                    }
                } else {
                    completion(nil, APIError.responseUnsuccessful)
                }
            } else if let _ = error {
                completion(nil, .unknownError)
            }
        }
        task.resume()
    }
    
    func getImageFrom(url: URL, completion: @escaping (UIImage?, APIError?) -> Void) {
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, response, error in
            //NOTE: Emerge to the main thread at the call site
                if let data = data {
                    let image = UIImage(data: data)
                    completion(image, nil)
                } else if let _ = error {
                    completion(nil, .unknownError)
                }

        }
        task.resume()
    }

}




