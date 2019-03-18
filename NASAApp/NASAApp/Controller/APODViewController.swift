//
//  APODViewController.swift
//  NASAApp
//
//  Created by Jun Kakeno on 3/9/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import UIKit

class APODViewController: UIViewController {

    @IBOutlet weak var apodImage: UIImageView!
    @IBOutlet weak var apodTitle: UILabel!
    @IBOutlet weak var apodDescription: UITextView!
    
    lazy var apiClient: ApiClient = {
        return ApiClient(configuration: .default)
    }()
    
    var apod:APOD?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let apod = apod{
        apodTitle.text = apod.title
        apodDescription.text = apod.explanation
            self.apiClient.getImageFrom(url: apod.url) { [unowned self] image, error in
                //Get the APOD image
                if let image = image {
                    
                    //Surface the image at the last minute before refreshing the
                    DispatchQueue.main.async {
                        self.apodImage.image = image
                        
                    }
                    
                    //If APOD image is nil return an error
                } else if let error = error {
                    switch error {
                    case .jsonParsingFailure: self.presentAlert(title: "Parsing Error", message: "Oops! It looks like something went wrong on the backend!")
                    case .responseUnsuccessful: self.presentAlert(title: "Response Unsuccessful", message: "It looks like your network might be down. Please try again.")
                    default: self.presentAlert(title: "Something Went Wrong", message: "Oops! It looks like something went wrong on the backend!")
                    }
                }
            }
        }
    }

}
