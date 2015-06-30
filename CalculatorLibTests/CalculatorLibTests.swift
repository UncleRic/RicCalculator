//  CalculatorLibTests.swift
//  CalculatorLibTests
//
//  Created by Frederick C. Lee on 6/27/15.
//  Copyright (c) 2015 Frederick C. Lee. All rights reserved.
// -----------------------------------------------------------------------------------------------------

import UIKit
import XCTest
import CoreData

class History: NSManagedObject {
    @NSManaged var equation: String
}

class CoreDataTestCase:XCTestCase {
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.AmourineTech.RicCalculator" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("RicCalculator", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        // I chose 'NSInMemoryStoryType' to decouple from application's sqlite.  I don't want to pollute the persistent
        // store with test data...hence work with memory instead:
        
        if coordinator!.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
}

// =======================================================================================================================

class CalculatorLibTests: CoreDataTestCase {
    var history:History?
    let testEqn = "9*10/(150-100)+10**2"
    
    override func setUp() {
        super.setUp()
        let entity = NSEntityDescription.entityForName("History", inManagedObjectContext: managedObjectContext!)
        history = History(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
    }
    
    override func tearDown() {
        managedObjectContext = nil
        super.tearDown()
    }
    
    func testForHistoryInCoreData() {
        XCTAssertNotNil(history, "FAILURE: The 'History' Entity not found in Core Data.")
    }
    
    func testForSavedHistoryToCoreData() {
        history!.equation = testEqn
        let success = managedObjectContext!.save(nil) as Bool
        XCTAssert(success, "Unable to Save History")
        
        let historyEntity = NSEntityDescription.entityForName("History", inManagedObjectContext: managedObjectContext!)
        
        var fetchRequest = NSFetchRequest()
        fetchRequest.entity = historyEntity
        var error: NSError?
        var results = managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)
        XCTAssertNotNil(results, "Core Data has No History")
    }
    
    func testEquationEvaluation() {
        var expn = NSExpression(format:testEqn)
        let result = (expn.expressionValueWithObject(nil, context: nil) as! NSNumber).intValue
        XCTAssertEqual(result, 101, "NSExpression Evaluator.")
        
        // Test if: 9(1+3) = (3+1)9
        // Note: NSExpression failed to parse 'n(' or ')n'.
        //       Hence need to put in multiplier.
        
        expn = NSExpression(format:"9*(1+3)")
        let result1 = (expn.expressionValueWithObject(nil, context: nil) as! NSNumber).intValue
        
        expn = NSExpression(format:"(3+1)*9")
        let result2 = (expn.expressionValueWithObject(nil, context: nil) as! NSNumber).intValue
        
        XCTAssertEqual(result1, result2, "NSExpression Evaluator.")
        
    }
    
}
