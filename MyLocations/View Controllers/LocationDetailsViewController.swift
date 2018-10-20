//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Ryan on 10/8/18.
//  Copyright © 2018 fatalerr. All rights reserved.
//

import UIKit
import CoreLocation


//MARK:- private global constant
// only call one instance of this obj
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

class LocationDetailsViewController: UITableViewController {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    // this screen will never be tapped unless there is a valid coordinate object
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    
    var categoryName = "No Category"
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done() {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        hudView.text = "Tagged"
        // delay to display checkmark before exiting screen
        let delayTime = 0.6
        afterDelay(delayTime) {hudView.hide(); self.navigationController?.popViewController(animated: true)}
    }
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController // view that sent the segue
        categoryName = controller.selectedCategoryName // read value of categoryName
        categoryLabel.text = categoryName // update label
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.text = ""
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = format(date: Date())
        
        // create tap recognizer object
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer) // waits for tap to occur
    }
    
    // MARK:- Table View Delegates
    
    // Limit taps to only first two sections of table
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    // bring up keyboard if user taps anywhere in first section (description)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
        tableView.deselectRow(at: indexPath, animated: true) // un-highlight after tap
    }
    
    // MARK:- Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    // MARK:- Helper Methods
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        
        if let s = placemark.subThoroughfare {
            text += s + " "
        }
        if let s = placemark.thoroughfare {
            text += s + ", "
        }
        if let s = placemark.locality {
            text += s + ", "
        }
        if let s = placemark.administrativeArea {
            text += s + " "
        }
        if let s = placemark.postalCode {
            text += s + ", "
        }
        if let s = placemark.country {
            text += s
        }
        return text
    }
    
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    
    // MARK:- Objective-C selectors
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        // tell where on screen tap happened
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        // keep keyboard up if the cell tapped is the place where we can type
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        // if we didnt return early, hide the keyboard
        descriptionTextView.resignFirstResponder()
    }

}
