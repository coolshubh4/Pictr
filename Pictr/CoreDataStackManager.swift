//
//  CoreDataStackManager.swift
//  Pictr
//
//  Created by Shubham Tripathi on 23/11/15.
//  Copyright © 2015 coolshubh4. All rights reserved.
//

import Foundation
import CoreData

let SQLITE_FILE_NAME = "Pictr.sqlite"
let CORE_DATA_MODEL_NAME = "PictrDataModel"

class CoreDataStackManager: NSObject {
    
    private struct ErrorMessage {
        static let Domain = NSBundle.mainBundle().bundleIdentifier!
        static let PersistentCoordinatorInitFailed = "Failed to init perisistent coordinator"
        static let PersistentCoordinatorInitFailedReason = "There was an error adding a persistent store type"
    }
    
    static let sharedInstance = CoreDataStackManager()
    
    lazy var applicationDocumentDirectory: NSURL = {
        let url = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
        #if DEBUG
            print(url.path!)
        #endif
        return url
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(CORE_DATA_MODEL_NAME, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentDirectory.URLByAppendingPathComponent(SQLITE_FILE_NAME)
        
        var error: NSError? = nil
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            #if DEBUG
                NSLog("CoreDataStackManager persistentStoreCoordinator error \(error)")
            #endif
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let persistentStoreCoordinator = self.persistentStoreCoordinator
        if persistentStoreCoordinator == nil {
            return nil
        }
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }()
    
    func saveContext() {
        if let context = self.managedObjectContext {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    #if DEBUG
                        NSLog("CoreDataStackManager saveContext error \(error)")
                    #endif
                    abort()
                }
            }
        }
    }
}