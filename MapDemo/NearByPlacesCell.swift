//
//  NearByPlacesCell.swift
//  MapDemo
//
//  Created by Tejaswini on 26/03/18.
//  Copyright © 2018 Tejaswini. All rights reserved.
//

import UIKit

class NearByPlacesCell: UITableViewCell {

    
    @IBOutlet var typeImageView: UIImageView!
    @IBOutlet var locationLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        typeImageView.layer.masksToBounds = true
        typeImageView.layer.cornerRadius = 1.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
