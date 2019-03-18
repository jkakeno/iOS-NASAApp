//
//  RoverPhotoViewController.swift
//  NASAApp
//
//  Created by Jun Kakeno on 3/14/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import UIKit

class RoverPhotoViewController: UIViewController {

    @IBOutlet weak var roverPhoto: UIImageView!
    var image:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let image = image else {return}
        roverPhoto.image = resizeImage(image: image, targetSize: CGSize(width:350, height:350))

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(sender:)))
        
        self.roverPhoto.isUserInteractionEnabled = true
        self.roverPhoto.addGestureRecognizer(tapGestureRecognizer)
        
        // Do any additional setup after loading the view.
        let shareButton = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(self.shareImage))
        navigationItem.rightBarButtonItem = shareButton
        
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width:size.width * heightRatio, height:size.height * heightRatio)
        } else {
            newSize = CGSize(width:size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x:0, y:0, width:newSize.width, height:newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    @objc func tapAction(sender: UITapGestureRecognizer) {
        
        let touchPoint = sender.location(in: self.roverPhoto) // Change to whatever view you want the point for
        print("Touched point: \(touchPoint)")
        let image = resizeImage(image: self.image!, targetSize: CGSize(width:350, height:350))
        roverPhoto.image = textToImage(drawText: "I'm in Mars!!!", inImage: image, atPoint: touchPoint)
    }
    
    func textToImage(drawText: NSString, inImage: UIImage, atPoint: CGPoint) -> UIImage{
        
        // Setup the font specific variables
        var textColor = UIColor.red
        var textFont = UIFont(name: "Helvetica Bold", size: 15)!
        
        // Setup the image context using the passed image
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ]
        
        // Put the image into a rectangle as large as the original image
        inImage.draw(in: CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))
        
        // Create a point within the space that is as bit as the image
        var rect = CGRect(x:atPoint.x,y: atPoint.y,width: inImage.size.width,height: inImage.size.height)
        
        // Draw the text into an image
        drawText.draw(in: rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage!
    }
    
    @objc func shareImage(){
        // image to share
        let image = self.roverPhoto.image
        
        // set up activity view controller
        let imageToShare = [ image! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }


}
