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
    var managedObjectContext: NSManagedObjectContext!;
    //var locations = [Location]() // an array of location objects (core data)
    lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
        let fetchRequest = NSFetchRequest<Location>()
        let entity = Location.entity();
        fetchRequest.entity = entity;
        //let sortDescriptor = NSSortDescriptor(key: "date", ascending: true);
        //fetchRequest.sortDescriptors = [sortDescriptor];
        let sort1 = NSSortDescriptor(key: "category", ascending: true);
        let sort2 = NSSortDescriptor(key: "date", ascending: true);
        fetchRequest.sortDescriptors = [sort1, sort2];
        fetchRequest.fetchBatchSize = 20;
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.managedObjectContext,
                                                                  sectionNameKeyPath: "category",
                                                                  cacheName: "Locations");
        fetchedResultsController.delegate = self;

        
        return fetchedResultsController;
    }()
    
    // desctructor()
    deinit {
        fetchedResultsController.delegate = nil;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        /*
        let fetchRequest = NSFetchRequest<Location>();
        let entity = Location.entity();
        fetchRequest.entity = entity;
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true);
        fetchRequest.sortDescriptors = [sortDescriptor];
        do {
            locations = try managedObjectContext.fetch(fetchRequest);
        } catch {
            fatalCoreDataError(error);
        }
        */
        navigationItem.rightBarButtonItem = editButtonItem;
        performFetch();
    }
    
    
    // MARK:- Table View Delegates
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return locations.count;
        let sectionInfo = fetchedResultsController.sections![section];
        return sectionInfo.numberOfObjects;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell;
        
        //let location = locations[indexPath.row];
        let location = fetchedResultsController.object(at: indexPath);
        /*
        let descriptionLabel = cell.viewWithTag(100) as! UILabel;
        descriptionLabel.text = location.locationDescription;
        let addressLabel = cell.viewWithTag(101) as! UILabel;
        //addressLabel.text = "...then it works!";
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
            addressLabel.text = "";
        }
        */
        cell.configure(for: location);
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let location = fetchedResultsController.object(at: indexPath);
            managedObjectContext.delete(location);
            do {
                try managedObjectContext.save();
            } catch {
                fatalCoreDataError(error);
            }
        }
    }
    
    // ask the fetcher for the number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count;
    }
    
    // ask the fetcher what the section names are
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section];
        return sectionInfo.name;
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let controller = segue.destination as! LocationDetailsViewController;
            controller.managedObjectContext = self.managedObjectContext;
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                //let location = locations[indexPath.row];
                let location = fetchedResultsController.object(at: indexPath);
                controller.locationToEdit = location;
            }
        }
    }
    
    //MARK:- Helper Methods
    func performFetch() {
        do {
            try fetchedResultsController.performFetch();
        } catch {
            fatalCoreDataError(error);
        }
    }
    
    
}

// MARK:- NSFetchedResultsController Delegate
extension LocationsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerWillChangeContent");
        tableView.beginUpdates();
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (object)");
            tableView.insertRows(at: [newIndexPath!], with: .fade);
        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)");
            tableView.deleteRows(at: [indexPath!], with: .fade);
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)");
            if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
                let location = controller.object(at: indexPath!) as! Location;
                cell.configure(for: location);
            }
        case .move:
            print("*** NSFetchedResultsChangeMove (object)");
            tableView.deleteRows(at: [indexPath!], with: .fade);
            tableView.insertRows(at: [newIndexPath!], with: .fade);
        @unknown default:
            //fatalCoreDataError(error);
            print("*** NSFetchedResultsChangeUpdate (object)");
            if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
                let location = controller.object(at: indexPath!) as! Location;
                cell.configure(for: location);
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)");
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade);
            
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)");
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade);
            
        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)");
        case .move:
            print("*** NSFetchedResultsChangeMove (section)");
        //@unknown default:
            //fatalCoreDataError(error);
        @unknown default:
            print("*** NSFetchedResultsChangeUpdate (section)");
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChnageContent");
        tableView.endUpdates();
    }
    
}


