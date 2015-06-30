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
            var expn = NSExpression(format:eqn)
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
        
        var fetchRequest = NSFetchRequest()
        fetchRequest.entity = historyEntity
        var error: NSError?
        var results = context!.executeFetchRequest(fetchRequest, error: &error)
        var historyItems = [String]()
        let resultCount = results!.count
        
        if resultCount > 0 {
            for index in 0...(resultCount-1) {
                historyItems.append(results![index].equation)
                println(results![index].equation)
            }
            
            if let myHistory = results?.last as? History {
                context!.deleteObject(myHistory)
                context!.save(nil)
            }
        }
        return historyItems
    }
    
    // -----------------------------------------------------------------------------------------------------
    
    public func clearHistory() -> Bool {
        let fetchRequest = NSFetchRequest(entityName: "History")
        fetchRequest.includesSubentities = false
        var error:NSError?
        
        if let objects = context!.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject] {
            for each in objects {
                context!.deleteObject(each)
            }
        } else {
            println()
        }
        
        return context!.save(nil)
    }
    
    // -----------------------------------------------------------------------------------------------------
    // MARK: - Local Core-Data Access:
    
    func newEntry(eqn:String) {
        let context = self.context
        let historyEntity = NSEntityDescription.entityForName("History", inManagedObjectContext: context!)
        
        let history = History(entity: historyEntity!, insertIntoManagedObjectContext: context)
        history.equation = eqn
        if context!.save(nil) {
            println("Saved!")
        } else {
            println("Not Saved.")
        }
    }
    
    // -----------------------------------------------------------------------------------------------------
    
    func codeCleansing(origString:String) -> String {
        let pattern = "(?<=\\d)(?=\\()|(?<=\\))(?=\\d)"
        
        var revisedString = NSMutableString(string: origString)
        let range = NSMakeRange(0, revisedString.length)
        
        revisedString.replaceOccurrencesOfString(")(", withString: ")*(", options: .LiteralSearch, range: range)
        
        var error: NSError? = nil
        let regex = NSRegularExpression(pattern: pattern, options: nil, error: &error)
        
        if (nil != error) {
            let userInfo = error?.userInfo
            println(userInfo)
            return ""
        }
        
        regex?.replaceMatchesInString(revisedString, options: NSMatchingOptions.allZeros,
            range: NSMakeRange(0, revisedString.length),
            withTemplate: "*")
        
        return revisedString as String
    }
}

