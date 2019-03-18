//
//  Cell.swift
//  NASAApp
//
//  Created by Jun Kakeno on 2/16/19.
//  Copyright © 2019 Jun Kakeno. All rights reserved.
//

import UIKit

//This class represents a cell in table view
final class CoverCell: UITableViewCell {
    static let reuseIdentifier = String(describing: CoverCell.self)
    
    @IBOutlet weak var coverImage: UIImageView!
    
    @IBOutlet weak var coverMainTitle: UILabel!
    
    @IBOutlet weak var coverSubTitle: UILabel!
}
