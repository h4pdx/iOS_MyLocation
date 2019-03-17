//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Ryan Hoover on 8/18/18.
//  Copyright © 2018 fatalerr. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // Mark: - Core Data Stack
    
    // Load SQLite database
    // NSOManagedObjectContext object
    // loads databse into memeory and initializes Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error {
                fatalError("Could not load data store: \(error)")
            }
        })
        return container
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext

    // work down through the view hierarchy
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let tabController = window!.rootViewController as! UITabBarController // cast var as Tab Bar controller
        // find the first element in the the tab bar array
        if let tabViewControllers = tabController.viewControllers {
            let navController = tabViewControllers[0] as! UINavigationController // embedded nav stack lives at tab bar array first index
            let controller = navController.viewControllers.first as! CurrentLocationViewController // first view in the nav stack
            controller.managedObjectContext = self.managedObjectContext // initialzes the lazy var declared above
        }
        print(applicationDocumentDirectory) // print to console folder path
        listenForFatlaCoreDataNotifications()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK:- Helper Methods
    
    func listenForFatlaCoreDataNotifications() {
        // i want to be notified whenever a CoreDataSaveFailed noti is posted
        NotificationCenter.default.addObserver(forName: CoreDataSaveFailedNotification, object: nil, queue: OperationQueue.main, using: {
            (notification) in
            // multiline string
            let message = """
            There was a fatal error in the app and it cannot continue.
            Press OK to terminate the app. Sorry for the inconvenience.
            """
            // create an alert controller to show the error message
            let alert = UIAlertController(title: "Internal Error", message: message, preferredStyle: .alert)
            // add an action for the new alert pop-up
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                // creates an Exception object instead of calling fatalError()
                let exception = NSException(
                    name: NSExceptionName.internalInconsistencyException,
                    reason: "Fatal Core Data error", userInfo: nil)
                exception.raise()
            }
            alert.addAction(action)
            // use the root view controller of the app since its visible at all times
            let tabController = self.window!.rootViewController!
            tabController.present(alert, animated: true, completion: nil)
        })
    }

}

