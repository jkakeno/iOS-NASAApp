//
//  EarthPhotoViewController.swift
//  NASAApp
//
//  Created by Jun Kakeno on 3/13/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import UIKit
import CoreLocation

class EarthPhotoViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var earthPhoto: UIImageView!
    
    lazy var apiClient: ApiClient = {
        return ApiClient(configuration: .default)
    }()
    
    var coordinate: CLLocationCoordinate2D?
    var date: Date?
    var images = [UIImage]()
    
    var group = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        let radQueue = OperationQueue()
        
        let operation1 = BlockOperation {
            print("Operation 1")
            
            self.activityIndicator.startAnimating()
            
            self.group.enter()
            
            guard let coordinate = self.coordinate, let date = self.date else {return}
            self.getEarthPhotoAsset(lat: coordinate.latitude, long: coordinate.longitude, date: date)
            
            self.group.wait()
        }
        
        let operation2 = BlockOperation {
            print("Operation 2")
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
            self.group.enter()
                if !self.images.isEmpty{
                    for (index,image) in self.images.enumerated() {

                        DispatchQueue.main.async {
                            self.earthPhoto.image = image
                            print("Earth image: \(index)")

                            //Last item iterated
                            if index == self.images.endIndex - 1{
                                self.group.leave()
                                print("Last iterated earth image!")
                            }
                        }
                        
                        //Wait 2 sec to load the next image to image view
                        sleep(2)

                    }
                }else{
                    self.displayAlert(title: "No Data Available Error",message: "There's no images for the selection provided. Please make a different selection and try again.")
                }
            self.group.wait()
        }
        
        operation2.addDependency(operation1)
        radQueue.addOperation (operation1)
        radQueue.addOperation(operation2)

    }
    
    func getEarthPhotoAsset(lat: Double, long: Double, date: Date){
        apiClient.getEarthAsset(lat: lat, long: long, date: date){[unowned self] earthPhotoAssets, error in
            if let earthPhotoAssets = earthPhotoAssets{

                let results = earthPhotoAssets.results
                
                if !results.isEmpty{
                
                    for (index,earthPhotoAsset) in results.enumerated() {
                        //Call earth imagery to get image url
                        
                        let date = earthPhotoAsset.date.split(separator: "T")[0]
                        print("Earth photo date: \(date)")
                        
                        self.apiClient.getEarthImage(lat: lat, long: long, date: String(date)){[unowned self] earthImage, error in
                            
                            if let earthImage = earthImage{
                                
                                let earthImageUrl = earthImage.url
                                print(earthImageUrl)
                                
                                //Pass the image url and handle the completion handler in a closure.
                                self.apiClient.getImageFrom(url: earthImageUrl) { [unowned self] image, error in
                                    //Get the APOD image
                                    if let image = image {

                                        self.images.append(image)
                                        print("Append image to array.")

                                        //Last item iterated
                                        if index == results.endIndex - 1{
                                            self.group.leave()
                                            print("Last iterated earth photo!")
                                        }
                                        
                                    } else if let error = error {
                                        switch error {
                                        case .jsonParsingFailure: self.displayAlert(title:"Parsing Error" ,message:"Oops! It looks like something went wrong on the backend!")
                                        case .responseUnsuccessful: self.displayAlert(title: "Response Unsuccessful",message:"It looks like your network might be down. Please try again.")
                                        default: self.displayAlert(title:"Something Went Wrong" ,message:"Oops! It looks like something went wrong on the backend!")
                                        }
                                    }
                                }
                                
                                
                            }else if let error = error {
                                switch error {
                                case .jsonParsingFailure: self.displayAlert(title:"Parsing Error" ,message:"Oops! It looks like something went wrong on the backend!")
                                case .responseUnsuccessful: self.displayAlert(title: "Response Unsuccessful",message:"It looks like your network might be down. Please try again.")
                                default: self.displayAlert(title:"Something Went Wrong" ,message:"Oops! It looks like something went wrong on the backend!")
                                }
                            }
                        }
                    }
                    
                }else{
                    self.displayAlert(title: "No Data Available Error",message: "There's no images for the selection provided. Please make a different selection and try again.")
                }
                
            }else if let error = error {
                switch error {
                case .jsonParsingFailure: self.displayAlert(title:"Parsing Error" ,message:"Oops! It looks like something went wrong on the backend!")
                case .responseUnsuccessful: self.displayAlert(title: "Response Unsuccessful",message:"It looks like your network might be down. Please try again.")
                default: self.displayAlert(title:"Something Went Wrong" ,message:"Oops! It looks like something went wrong on the backend!")
                }
            }
        }
    }

    func displayAlert(title: String,message:String){
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
        
        self.group.leave()
        
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }

}
