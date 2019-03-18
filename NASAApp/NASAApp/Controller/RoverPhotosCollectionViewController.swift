//
//  RoverPhotosCollectionViewController.swift
//  NASAApp
//
//  Created by Jun Kakeno on 3/10/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import UIKit

//Collection View Tutorial: https://www.raywenderlich.com/9334-uicollectionview-tutorial-getting-started

class RoverPhotosCollectionViewController: UICollectionViewController {

    var marsPhotos = [UIImage]()
    
    var rover:Rover?
    var camera:String?
    var sol:String?
    
    lazy var apiClient: ApiClient = {
        return ApiClient(configuration: .default)
    }()
    
    var indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
    
    var group = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator(isDisplay: true)
    
        let radQueue = OperationQueue()

        let operation1 = BlockOperation {
            print("Operation 1")
            self.group.enter()
            self.getMarsPhotos()
            self.group.wait()
        }

        let operation2 = BlockOperation {
            print("Operation 2")
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.activityIndicator(isDisplay: false)
            }
        }

        operation2.addDependency(operation1)
        radQueue.addOperation (operation1)
        radQueue.addOperation(operation2)
        
    }
    
    func activityIndicator (isDisplay:Bool){
        if isDisplay{
            indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            indicator.backgroundColor = .clear
            indicator.center = collectionView.center
            indicator.hidesWhenStopped = true
            collectionView.addSubview(indicator)
            indicator.startAnimating()
        }else{
            indicator.stopAnimating()
        }
    }
    
    
    func getMarsPhotos(){
        guard let rover = rover, let camera = camera, let sol = sol else{ return }
        
        apiClient.getMarsPhotos(rover: rover, camera: camera, sol:sol ){[unowned self] marsPhotos, error in
            
            if let marsPhotos = marsPhotos {
                print("Received Mars Photos!")
                
                if !marsPhotos.isEmpty{
                
                    for (index,marsPhoto) in marsPhotos.enumerated(){

                        let marsPhotoUrl = marsPhoto.imageURL
                        print("\(marsPhotoUrl)")
                    
                        self.apiClient.getImageFrom(url: marsPhotoUrl) { [unowned self] image, error in
                            //Get the APOD image
                            if let image = image {

                                //Surface the image at the last minute before refreshing the
                                DispatchQueue.main.async {
                                    self.marsPhotos.append(image)
                                }
                                
                                //Last item iterated
                                if index == marsPhotos.endIndex - 1{
                                    self.group.leave()
                                    print("Last iterated mars photo!")
                                }
                        
                            } else if let error = error {
                                switch error {
                                case .jsonParsingFailure: self.displayAlert(title:"Parsing Error" ,message:"Oops! It looks like something went wrong on the backend!")
                                case .responseUnsuccessful: self.displayAlert(title: "Response Unsuccessful",message:"It looks like your network might be down. Please try again.")
                                default: self.displayAlert(title:"Something Went Wrong" ,message:"Oops! It looks like something went wrong on the backend!")
                                }
                            }
                        }
                    }
                }
            }else{
                self.displayAlert(title: "No Data Available Error",message: "There's no images for the selection provided. Please make a different selection and try again.")
            }
        }
    }

    
    func displayAlert(title: String,message:String){
        DispatchQueue.main.async {
            self.activityIndicator(isDisplay: false)
        }
        
        self.group.leave()
        
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return marsPhotos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoverCell", for: indexPath) as! RoverCell

            cell.roverImageView.image = marsPhotos[indexPath.row]

        return cell
    }
    
     //Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        print("Selected item at: \(indexPath.row)")
        
        guard let roverPhotoVC = self.storyboard?.instantiateViewController(withIdentifier: "RoverPhotoViewController") as? RoverPhotoViewController else { return false}
        roverPhotoVC.image = marsPhotos[indexPath.row]

        self.navigationController?.pushViewController(roverPhotoVC, animated: true)
        
        return true
    }

}
