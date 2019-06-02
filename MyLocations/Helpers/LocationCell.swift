//
//  LocationCell.swift
//  MyLocations
//
//  Created by Ryan Hoover on 6/2/19.
//  Copyright © 2019 fatalerr. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!;
    @IBOutlet weak var addressLabel: UILabel!;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(for location: Location) {
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)";
        } else {
            descriptionLabel.text = location.locationDescription;
        }
        // if optional placemark exists, convert to string
        if let placemark = location.placemark {
            var text = "";
            if let s = placemark.subThoroughfare {
                text += (s + " ");
            }
            if let s = placemark.thoroughfare {
                text += (s + ", ");
            }
            if let s = placemark.locality {
                text += s;
            }
            addressLabel.text = text;
        } else {
            // cast longitude & latitiude as a string if no address is found from rev geocoding
            addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude);
        }
    }

}
