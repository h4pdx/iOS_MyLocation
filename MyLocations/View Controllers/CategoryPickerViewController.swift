//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Ryan on 10/12/18.
//  Copyright © 2018 fatalerr. All rights reserved.
//

import UIKit

class CategoryPickerViewController: UITableViewController {
    var selectedCategoryName = ""
    
    let categories = [
    "No Category",
    "Apple Store",
    "Store",
    "Bar",
    "Bookstore",
    "Shop",
    "Club",
    "Grocery Store",
    "Historic Building",
    "House",
    "Apartment",
    "Landmark",
    "Park",
    "Museum",
    "Gym",
    "Coffee Shop",
    "Café",
    "Factory",
    "Airport",
    "Concert Venue",
    "Stadium",
    "Arena"]
    
    var selectedIndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<categories.count {
            if categories[i] == selectedCategoryName {
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
            }
        }
    }
    
    // MARK:- Table View Delegates
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // reuse identifier defined in sotoryboard- prototype cells
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        
        if categoryName == selectedCategoryName {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != selectedIndexPath.row {
            if let newCell = tableView.cellForRow(at: indexPath) {
                newCell.accessoryType = .checkmark
            }
            if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
                oldCell.accessoryType = .none
            }
            selectedIndexPath = indexPath
        }
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell) {
                // pass the selected row back on thr segue unwind
                selectedCategoryName = categories[indexPath.row]
            }
        }
    }
    
}
