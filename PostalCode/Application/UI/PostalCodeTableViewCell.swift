//
//  PostalCodeTableViewCell.swift
//  PostalCode
//
//  Created by João Pedro on 30/08/2022.
//

import UIKit

class PostalCodeTableViewCell: UITableViewCell {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var fullPostalCodeLabel: UILabel!
    
    func setup(postalCode: PostalCodes) {
        
        self.locationLabel.text = postalCode.locationName
        self.fullPostalCodeLabel.text = postalCode.fullPostalCode
    }
}
