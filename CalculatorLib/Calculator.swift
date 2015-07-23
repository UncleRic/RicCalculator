//  Calculator.swift
//  RicCalculator
//
//  Created by Frederick C. Lee on 6/27/15.
//  Copyright (c) 2015 Frederick C. Lee. All rights reserved.
// -----------------------------------------------------------------------------------------------------


import Foundation
import CoreData

class History: NSManagedObject {
    @NSManaged var equation: String
}

public class Calculator {
    var context:NSManagedObjectContext?
    
    public init(context:NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: -  Public  Access:
    public func processEquation(eqn:String) -> String {
        let cleansedEqu = codeCleansing(eqn)
        if cleansedEqu > "" {
            let expn = NSExpression(format:eqn)
            let result = (expn.expressionValueWithObject(nil, context: nil) as! NSNumber).floatValue
            newEntry(eqn)
            return "\(result)"
        } else {
            return ""
        }
    }
    
    // -----------------------------------------------------------------------------------------------------
    
    public func fetchHistory() -> [String]? {
        let context = self.context
        let historyEntity = NSEntityDescription.entityForName("History", inManagedObjectContext: context!)
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = historyEntity

        var results: [AnyObject]?
        do {
            results = try context!.executeFetchRequest(fetchRequest)
        } catch _ {
            
        }
        
        var historyItems = [String]()
        let resultCount = results!.count
        
        if resultCount > 0 {
            for index in 0...(resultCount-1) {
                historyItems.append(results![index].equation)
                print(results![index].equation)
            }
            
            if let myHistory = results?.last as? History {
                context!.deleteObject(myHistory)
                do {
                    try context!.save()
                } catch _ {
                }
            }
        }
        return historyItems
    }
    
    // -----------------------------------------------------------------------------------------------------
    
    public func clearHistory() -> Bool {
//        let fetchRequest = NSFetchRequest(entityName: "History")
//        fetchRequest.includesSubentities = false
//        var error:NSError?
//        do {
//            let objects = context!.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
//                for each in objects! {
//                    context!.deleteObject(each)
//                } catch _ {
//                    return false
//                }
//                do {
//                    try context!.save()
//                    return true
//                } catch _ {
//                    return false
//                }
//            }
//        }
        
        return true
    }
    // -----------------------------------------------------------------------------------------------------
    // MARK: - Local Core-Data Access:
    
    func newEntry(eqn:String) {
        let context = self.context
        let historyEntity = NSEntityDescription.entityForName("History", inManagedObjectContext: context!)
        
        let history = History(entity: historyEntity!, insertIntoManagedObjectContext: context)
        history.equation = eqn
        do {
            try context!.save()
            print("Saved!")
        } catch _ {
            print("Not Saved.")
        }
    }
    
    // -----------------------------------------------------------------------------------------------------
    
    func codeCleansing(origString:String) -> String {
        let pattern = "(?<=\\d)(?=\\()|(?<=\\))(?=\\d)"
        
        let revisedString = NSMutableString(string: origString)
        let range = NSMakeRange(0, revisedString.length)
        
        revisedString.replaceOccurrencesOfString(")(", withString: ")*(", options: .LiteralSearch, range: range)
        
        var error: NSError? = nil
        let regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if (nil != error) {
            let userInfo = error?.userInfo
            print(userInfo)
            return ""
        }
        
        regex?.replaceMatchesInString(revisedString, options: NSMatchingOptions(),
            range: NSMakeRange(0, revisedString.length),
            withTemplate: "*")
        
        return revisedString as String
    }
}

