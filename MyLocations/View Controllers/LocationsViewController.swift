//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Ryan Hoover on 3/25/19.
//  Copyright © 2019 fatalerr. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    var locations = [Location]()
    
    // MARK:- Table View Delegates
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        let descriptionLabel = cell.viewWithTag(100) as! UILabel
        descriptionLabel.text = "If you can see this"
        let addressLabel = cell.viewWithTag(101) as! UILabel
        addressLabel.text = "...then it works!"
        
        return cell
    }
    
    
    
}

