//
//  LocationViewController.swift
//  NASAApp
//
//  Created by Jun Kakeno on 3/12/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocationViewController: UIViewController {
    

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationSearchResultTable: UITableView!
    let locationManager = CLLocationManager()
    var coordinate: CLLocationCoordinate2D?
    var date: Date?
    var mapItems: [MKMapItem] = []
    var searchBarText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(self.dateChanged(datePicker:)), for: .valueChanged)
        
        locationManager.delegate = self
        
        checkAuthorizationStatus()
        
        mapView.delegate = self
        searchBar.delegate = self
        
        //Configure Location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        locationSearchResultTable.delegate = self
        locationSearchResultTable.dataSource = self
        
        locationSearchResultTable.isHidden = true

        // Do any additional setup after loading the view.
        let photoButton = UIBarButtonItem(title: "Photos", style: .done, target: self, action: #selector(self.getEarthPhotos))
        navigationItem.rightBarButtonItem = photoButton
    }
    
    func checkAuthorizationStatus() {
        
        switch (CLLocationManager.authorizationStatus()) {
            
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            print("not determined")
            
        case .denied:
            print("no location!")
            
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            
        default:
            print("nothing")
            
        }
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
        let formater = DateFormatter()
        formater.dateFormat = "MM/dd/yyyy"
        let date = formater.string(from: datePicker.date)
        print("Date picked: \(date)")
        
        self.date = datePicker.date
    }
    
    func addCircle(toCoordinate coordinate: CLLocationCoordinate2D) {
        print("Update Current Location: \(coordinate.latitude), \(coordinate.longitude)")
        self.coordinate = coordinate
        
        let annotation = MKPointAnnotation()
        annotation.title = "Location"
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let circle = MKCircle(center: coordinate, radius: 30 as CLLocationDistance)
        mapView.addOverlay(circle)
    }

    @objc func getEarthPhotos() {
        if let coordinate = coordinate{
            if let date = date{
            print("Get Earth Photos...")
            guard let earthPhotoVC = self.storyboard?.instantiateViewController(withIdentifier: "EarthPhotoViewController") as? EarthPhotoViewController else { return }
                
                earthPhotoVC.date = date
                earthPhotoVC.coordinate = coordinate

                self.navigationController?.pushViewController(earthPhotoVC, animated: true)
            }else{ displayAlert(with: "Select a date.")}
        }else { displayAlert(with: "Select a location.")}
    }
    
    func displayAlert(with message:String){
        let alertController = UIAlertController(title: "Error", message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }

}


extension LocationViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Current Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            coordinate = location.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}

extension LocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circle = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = UIColor.red
        circle.fillColor = UIColor.red.withAlphaComponent(0.1)
        circle.lineWidth = 1
        return circle
    }
}


extension LocationViewController:UISearchBarDelegate{
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBar = searchBar
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print(searchBar.text as Any)
        self.searchBar = searchBar
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //Search bussiness
        searchBarText = searchBar.text
        guard let searchBarText = searchBarText else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {return}
            self.mapItems = response.mapItems
            self.locationSearchResultTable.reloadData()
        }
        
        //Dismiss the keyboard
        self.view.endEditing(true)
        
        if locationSearchResultTable.isHidden{
            locationSearchResultTable.isHidden = false
        }
    }
}

extension LocationViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = mapItems[indexPath.row].placemark
        tableView.isHidden = true
        addCircle(toCoordinate: place.coordinate)
    }
}

extension LocationViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        let place = mapItems[indexPath.row].placemark
        let address = parseAddress(place)
        
        if let itemName = place.name {
            cell.textLabel?.text = itemName
        }
        
        cell.detailTextLabel?.text = address
        
        return cell
    }
    
    // This method parses and formats location names/address for search queries
    
    func parseAddress(_ selectedItem: MKPlacemark) -> String {
        // space
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // comma between street and city
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // space
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        
        let addressLine = String(
            
            format:"%@%@%@%@%@%@%@",
            selectedItem.subThoroughfare ?? "",firstSpace, selectedItem.thoroughfare ?? "", comma, selectedItem.locality ?? "", secondSpace, selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
}



