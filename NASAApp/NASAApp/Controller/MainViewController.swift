//
//  ViewController.swift
//  NASAApp
//
//  Created by Jun Kakeno on 2/16/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UITableViewController {
    
    lazy var apiClient: ApiClient = {
        return ApiClient(configuration: .default)
    }()

    var epicList: [UIImage]?
    var coverList = [Cover]()

    var group = DispatchGroup()
    
    @IBOutlet var mainTableView: UITableView!
    
    var indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator(isDisplay: true)
        
        mainTableView.dataSource = self
        mainTableView.delegate = self
        
        let radQueue = OperationQueue()
        
        let operation1 = BlockOperation {
            print("Operation 1")
            self.group.enter()
            self.getAPOD(date: Date())
            self.group.enter()
            self.getEPIC()
            self.group.wait()
        }
        
        let operation2 = BlockOperation {
            print("Operation 2")
            self.getMARS()
            self.getLIBRARY()

            DispatchQueue.main.async {
                self.tableView.reloadData()
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
            indicator.center = mainTableView.center
            indicator.hidesWhenStopped = true
            mainTableView.addSubview(indicator)
            indicator.startAnimating()
        }else{
            indicator.stopAnimating()
        }
    }
    
    //Local method
    func getAPOD(date: Date) {
        apiClient.getAPOD(date: Date()){[unowned self] apod, error in
            //Get an APOD model
            if let apod = apod {
                
                if apod.mediaType == "image" {

                    //Use the APIClient method getImageFrom then pass the image url and handle the completion handler in a closure to get the image from the object.
                    self.apiClient.getImageFrom(url: apod.url) { [unowned self] image, error in
                        //Get the APOD image
                        if let image = image {

                            //Surface the image at the last minute before refreshing the
                            DispatchQueue.main.async {
                                print("Create APOD cover")
                                let apodCover=Cover(coverMainTitle: .apod, coverSubTitle: apod.title, coverImage: image, apod: apod, epic: nil)
                                self.coverList.append(apodCover)

                                self.group.leave()
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
                }else {
                    print("Create APOD cover with default image")
                    
                    guard let defaultImage = UIImage(named: "default_image") else {return}
                    
                    let apodCover=Cover(coverMainTitle: .apod, coverSubTitle: apod.title, coverImage: defaultImage, apod: apod, epic: nil)
                    self.coverList.append(apodCover)
                    
                    self.group.leave()
                }
            
                
            } else if let error = error {
                switch error {
                case .jsonParsingFailure: self.presentAlert(title: "Parsing Error", message: "Oops! It looks like something went wrong on the backend!")
                case .responseUnsuccessful: self.presentAlert(title: "Response Unsuccessful", message: "It looks like your network might be down. Please try again.")
                default: self.presentAlert(title: "Something Went Wrong", message: "Oops! It looks like something went wrong on the backend!")
                }
            }
        }
    }
    
    func getEPIC(){
        apiClient.getEPIC(){[unowned self] epicList, error in
            if let epicList = epicList {
                //Use the first image
                let epic = epicList[0]
                let endPoint = GSFCApi.epicArchive(date: epic.date, image: epic.image)
                let epicURL = endPoint.urlComponents.url!
                //Use the NASAAPIClient method getImageFrom
                //Pass the image url and handle the completion handler in a closure.
                self.apiClient.getImageFrom(url: epicURL) { [unowned self] image, error in
                    //Get the APOD image
                    if let image = image {
                        
                        //Surface the image at the last minute before refreshing the
                        DispatchQueue.main.async {
                            print("Create EPIC cover")
                            let epicCover=Cover(coverMainTitle: .epic, coverSubTitle: epic.date, coverImage: image, apod: nil, epic: epic)
                            self.coverList.append(epicCover)
                            
                            self.group.leave()
                        }

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
    
    func getMARS(){
        print("Create MARS cover")
        let marsCover=Cover(coverMainTitle: .mars, coverSubTitle: "Rover Photos", coverImage: UIImage(named: "mars"), apod: nil, epic: nil)
        coverList.append(marsCover)
    }

    func getLIBRARY(){
        print("Create LIBRARY cover")
        let libraryCover=Cover(coverMainTitle: .library, coverSubTitle: "NASA Image Library", coverImage: UIImage(named: "library"), apod: nil, epic: nil)
        coverList.append(libraryCover)

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coverList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CoverCell.reuseIdentifier, for: indexPath) as! CoverCell
        
        let cover = coverList[indexPath.row]
        cell.coverImage.image = cover.coverImage
        cell.coverMainTitle.text = cover.coverMainTitle?.rawValue
        cell.coverSubTitle.text = cover.coverSubTitle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let apodVC = storyboard?.instantiateViewController(withIdentifier: "APODViewController") as? APODViewController else { return }
        
        guard let locationVC = storyboard?.instantiateViewController(withIdentifier: "LocationViewController") as? LocationViewController else { return }
        
        guard let marsVC = storyboard?.instantiateViewController(withIdentifier: "MARSViewController") as? MARSViewController else { return }
        
        guard let imageSearchVC = storyboard?.instantiateViewController(withIdentifier: "ImageSearchViewController") as? ImageSearchViewController else { return }
        
        let cover = coverList[indexPath.row]
        
        if let coverMainTitle = cover.coverMainTitle{
            switch coverMainTitle {
            case .apod:
                if let apod = cover.apod{
                    print("Selected: \(apod.title)")
                    apodVC.apod = apod
                    navigationController?.pushViewController(apodVC, animated: true)
                }
            case .epic:
                print("Selected EPIC")
                navigationController?.pushViewController(locationVC, animated: true)
            case .mars:
                print("Selected MARS")
                navigationController?.pushViewController(marsVC, animated: true)
            case .library:
                print("Selected LIBRARY")
                navigationController?.pushViewController(imageSearchVC, animated: true)
            }
        }
    }
    
    
}






