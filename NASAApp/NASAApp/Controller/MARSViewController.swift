//
//  MARSViewController.swift
//  NASAApp
//
//  Created by Jun Kakeno on 3/10/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import UIKit


enum Rover:String{
    case curiosity
    case oportunity
    case spirit
}

class MARSViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var spirit: UIButton!
    @IBOutlet weak var oportunity: UIButton!
    @IBOutlet weak var curiosity: UIButton!
    @IBOutlet weak var cameraPicker: UIPickerView!
    @IBOutlet weak var solNumber: UITextField!
    
    let curiosityCameras: [String:String] = ["": "All","fhaz":"Front Hazard Avoidance Camera","rhaz":"Rear Hazard Avoidance Camera","mast":"Mast Camera","chemcam":"Chemistry and Camera Complex","mahli":"Mars Hand Lens Imager","mardi":"Mars Descent Imager","navcam":"Navigation Camera"]
    
    let oportunityCameras: [String:String] = ["": "All","fhaz":"Front Hazard Avoidance Camera","rhaz":"Rear Hazard Avoidance Camera","navcam":"Navigation Camera","pancam":"Panoramic Camera","minites":"Miniature Thermal Emission Spectrometer (Mini-TES)"]

    let spiritCameras: [String:String] = ["": "All","fhaz":"Front Hazard Avoidance Camera","rhaz":"Rear Hazard Avoidance Camera","navcam":"Navigation Camera","pancam":"Panoramic Camera","minites":"Miniature Thermal Emission Spectrometer (Mini-TES)"]
    
    var rover:Rover?
    var camera:String?
    var sol:String?
    var roverPhotos = [UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up navigatoin bar buttons action
        let photoButton = UIBarButtonItem(title: "Photos", style: .done, target: self, action: #selector(self.getMarsPhotos))
        navigationItem.rightBarButtonItem = photoButton
        
        let curiositySelector = UITapGestureRecognizer(target: self, action: #selector(self.curiosity(_:)))
        let oportunitySelector = UITapGestureRecognizer(target: self, action: #selector(self.oportunity(_:)))
        let spiritSelector = UITapGestureRecognizer(target: self, action: #selector(self.spirit(_:)))
        
        curiosity.addGestureRecognizer(curiositySelector)
        oportunity.addGestureRecognizer(oportunitySelector)
        spirit.addGestureRecognizer(spiritSelector)

        //Initialize picker
        self.cameraPicker.delegate = self
        self.cameraPicker.dataSource = self
        
        //Show number keyboard
        solNumber.keyboardType = UIKeyboardType.numberPad
        
        //Add done button to numeric pad keyboard
        let toolbarDone = UIToolbar.init()
        let barDoneBtn = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                              target: self, action: #selector(self.doneClicked))
        toolbarDone.sizeToFit()
        toolbarDone.items = [barDoneBtn]
        solNumber.inputAccessoryView = toolbarDone
        
        //Set the text field delegate needed to make observers for this view
        solNumber.delegate = self
        
        //Listen to keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func getMarsPhotos() {
        if let rover = rover{
            if let camera = camera {
                if let sol = sol {
                    //Send the parameters to next VC to make the url and get MARS photos
                    print("Navigate to RoverPhotoCollectionViewController and pass parameters: \(rover.rawValue), \(camera), \(sol)")

                    guard let roverPhotoCollectionVC = self.storyboard?.instantiateViewController(withIdentifier: "RoverPhotosCollectionViewController") as? RoverPhotosCollectionViewController else { return }
                    roverPhotoCollectionVC.rover = self.rover
                    roverPhotoCollectionVC.camera = camera
                    roverPhotoCollectionVC.sol = sol
                    self.navigationController?.pushViewController(roverPhotoCollectionVC, animated: true)
                    
                } else { displayAlert(with: "Enter a sol and try again.")}
            } else { displayAlert(with: "Select a camera and try again.")}
        } else { displayAlert(with: "Select a rover and try again.")}
    }
    
    @objc func curiosity(_ sender: UITapGestureRecognizer){
        rover = .curiosity
        print("Selected rover: \(rover)")
        cameraPicker.reloadAllComponents()
        curiosity.setTitleColor(.red, for: .normal)
        oportunity.setTitleColor(.white, for: .normal)
        spirit.setTitleColor(.white, for: .normal)
    }
    
    @objc func oportunity(_ sender: UITapGestureRecognizer){
        rover = .oportunity
        print("Selected rover: \(rover)")
        cameraPicker.reloadAllComponents()
        curiosity.setTitleColor(.white, for: .normal)
        oportunity.setTitleColor(.red, for: .normal)
        spirit.setTitleColor(.white, for: .normal)
    }
    
    @objc func spirit(_ sender: UITapGestureRecognizer){
        rover = .spirit
        print("Selected rover: \(rover)")
        cameraPicker.reloadAllComponents()
        curiosity.setTitleColor(.white, for: .normal)
        oportunity.setTitleColor(.white, for: .normal)
        spirit.setTitleColor(.red, for: .normal)
    }
    
    deinit {
        //Stop listening for keyboard events
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(notification:NSNotification){
        if notification.name.rawValue == "UIKeyboardWillShowNotification" {
            //Move the entire screen 350 points vertically from original position
            view.frame.origin.y = -350
        }else if notification.name.rawValue == "UIKeyboardDidHideNotification" {
            //Move the entire screen vertically to original position
            view.frame.origin.y = 0
        }
    }
    
    @objc func doneClicked(){
        print("Entered sol: \(solNumber.text)")
        sol = solNumber.text
        //Hide the keyboard
        view.endEditing(true)
    }
    
    //Number of column on picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Number of rows on picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let rover = rover{
            switch rover {
            case .curiosity:
                return Array(curiosityCameras.values).count
            case .oportunity:
                return Array(oportunityCameras.values).count
            case .spirit:
                return Array(spiritCameras.values).count
            }
        }else{
            return 0
        }
    }
    
    //Item displayed on picker
    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let rover = rover{
            switch rover {
            case .curiosity:
                let cameras = Array(curiosityCameras.values).sorted(by: <)
                return cameras[row]
            case .oportunity:
                let cameras = Array(oportunityCameras.values).sorted(by: <)
                return cameras[row]
            case .spirit:
                let cameras = Array(spiritCameras.values).sorted(by: <)
                return cameras[row]
            }
        }else{
            return ""
        }
    }
    
    //Item selected from picker
    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let rover = rover{
            switch rover {
            case .curiosity:
                let cameras = Array(curiosityCameras.keys).sorted(by: <)
                camera = cameras[row]
                print("Selected camera: \(camera)")
            case .oportunity:
                let cameras = Array(oportunityCameras.keys).sorted(by: <)
                camera = cameras[row]
                print("Selected camera: \(camera)")
            case .spirit:
                let cameras = Array(spiritCameras.keys).sorted(by: <)
                camera = cameras[row]
                print("Selected camera: \(camera)")
            }
        }
    }
    
    func displayAlert(with message:String){
        let alertController = UIAlertController(title: "Error", message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    

}
