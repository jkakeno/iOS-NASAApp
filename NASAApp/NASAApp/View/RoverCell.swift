//
//  RoverCell.swift
//  NASAApp
//
//  Created by Jun Kakeno on 3/10/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import UIKit

class RoverCell: UICollectionViewCell {
    
    let client = ApiClient()
    
    @IBOutlet weak var roverImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.layer.cornerRadius = 25.0
        self.contentView.layer.masksToBounds = true
    }
    
    
}
