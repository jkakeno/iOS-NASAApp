//
//  ImageSearchViewController.swift
//  NASAApp
//
//  Created by Jun Kakeno on 3/15/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import UIKit


class ImageSearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    lazy var apiClient: ApiClient = {
        return ApiClient(configuration: .default)
    }()
    
    var images = [Image]()
    var query:String?
    
    var group = DispatchGroup()
    
    var indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        imageCollectionView.dataSource = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //Resize the cell width to fit the screen
        if let layout = imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemWidth = view.bounds.width
            let itemHeight = layout.itemSize.height
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            layout.invalidateLayout()
        }
    }
    
    func activityIndicator (isDisplay:Bool){
        if isDisplay{
            indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            indicator.backgroundColor = .clear
            indicator.center = imageCollectionView.center
            indicator.hidesWhenStopped = true
            imageCollectionView.addSubview(indicator)
            indicator.startAnimating()
        }else{
            indicator.stopAnimating()
        }
    }
    
    func searchImages(with query: String){
        apiClient.searchImageLibrary(query: query){[unowned self] images, error in
            if let images = images {
                
                let imageItems = images.collection.items
                if !imageItems.isEmpty{
                    
                    for (index,item) in imageItems.enumerated(){
                        let imageUrl = item.links[0].href
                        let imageTitle = item.data[0].title
                        let imageDescription = item.data[0].description
                        self.apiClient.getImageFrom(url: imageUrl) { [unowned self] image, error in
                            //Get the APOD image
                            if let image = image {
                                
                                //Surface the image at the last minute before refreshing the
                                DispatchQueue.main.async {
                                    let image = Image(image: image, title: imageTitle, description: imageDescription)
                                    self.images.append(image)
                                }
                                
                                //Last item iterated
                                if index == imageItems.endIndex - 1{
                                    self.group.leave()
                                    print("Last iterated library image!")
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
                    
                }else{
                    self.displayAlert(title: "No Data Available Error",message:"There aren't any images available in the library for the key work \(query). Enter a different keyword and try again.")
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
            self.activityIndicator(isDisplay: false)
        }
        
        self.group.leave()
        
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }

}

extension ImageSearchViewController:UISearchBarDelegate{
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBar = searchBar
        images = [Image]()
        self.imageCollectionView.reloadData()
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //Search bussiness
        query = searchBar.text
        guard let query = query else { return }

        print("Query: \(query)")
        
        //Dismiss the keyboard
        self.view.endEditing(true)
        
        let radQueue = OperationQueue()
        
        let operation1 = BlockOperation {
            print("Operation 1")
            DispatchQueue.main.async {
                self.activityIndicator(isDisplay: true)
            }
            self.group.enter()
            self.searchImages(with: query)
            self.group.wait()
        }
        
        let operation2 = BlockOperation {
            print("Operation 2")
            DispatchQueue.main.async {
                self.imageCollectionView.reloadData()
                self.activityIndicator(isDisplay: false)
            }
        }
        
        operation2.addDependency(operation1)
        radQueue.addOperation (operation1)
        radQueue.addOperation(operation2)
    }
}


extension ImageSearchViewController:UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if images.isEmpty{
            return 1
        }else{
            return images.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        if !images.isEmpty{
            if let image = images[indexPath.row].image{
                cell.imageView.image = image
            }
            
            if let title = images[indexPath.row].imageTitle {
                cell.imageTitle.text = title
            }
            
            if let description = images[indexPath.row].imageDescription{
                cell.imageDescription.text = description
            }
        }
        
        return cell
    }
    

}


