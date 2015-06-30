//  MainViewController.swift
//  RicCalculator
//
//  Created by Frederick C. Lee on 6/27/15.
//  Copyright (c) 2015 Frederick C. Lee. All rights reserved.
// -----------------------------------------------------------------------------------------------------

import UIKit
import CoreData
import CalculatorLib

class CalCollectionCell: UICollectionViewCell {
    @IBOutlet weak var cellLabel: UILabel!
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var equationLabel: UILabel!
    
    var clearDisplay = false
    
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var gCalculator:Calculator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.equationLabel.text = ""
        if nil != context {
            gCalculator = Calculator(context: context!)
        }
        
        let historyItems = gCalculator!.fetchHistory()
        
        if historyItems != nil && historyItems!.count > 0 {
            println(historyItems)
        }
        
        return
    }
    
    // -----------------------------------------------------------------------------------------------------
    // MARK: - Action methods
    
    @IBAction func ancillaryAction(sender: UIButton) {
        let AC = (sender.tag == 1)
        let CH = (sender.tag == 2)
        let leftParan = (sender.tag == 3)
        let rightParan = (sender.tag == 4)
        
        if clearDisplay {
            self.equationLabel.text = ""
            clearDisplay = false
        }
        
        if AC {
            self.equationLabel.text = ""
        } else if CH {
            self.equationLabel.text = ""
            if gCalculator!.clearHistory() {
                showAlert("History Cleared")
            }
        } else if leftParan {
            self.equationLabel.text = self.equationLabel.text! + "("
        } else if rightParan {
            self.equationLabel.text = self.equationLabel.text! + ")"
            
        }
    }
    
    // -----------------------------------------------------------------------------------------------------
    
    @IBAction func zeroAction(sender: AnyObject) {
        if clearDisplay {
            self.equationLabel.text = ""
            clearDisplay = false
        }
        self.equationLabel.text = self.equationLabel.text! + "0"
    }
    
    // -----------------------------------------------------------------------------------------------------
    @IBAction func decimalPointAction(sender: UIButton) {
        //TODO: - CHECK FOR ERRORNEOUS NUMBER-ENTRY LIKE: '.9876.'
        
        if clearDisplay {
            self.equationLabel.text = ""
            clearDisplay = false
        }
        
        var str = self.equationLabel.text!
        
        // Checking for existing '.' at end of display text.  Toggle off if true:
        if str > "" {
            let index = count(str)-1 as Int
            let lastChar = (str as NSString).substringFromIndex(index)
            if lastChar == "." {
                self.equationLabel.text = (str as NSString).substringToIndex(index)
                return
            }
        } else {
            self.equationLabel.text = "."
            return
        }
        
        // -----------------------------------------------------------------
        // No decimal found.  Check if added decimal would create an erroneous numberal (e.g., '.1234.'):
        
        str = self.equationLabel.text! + "."  // ...decimal needs to be included to determine proper display text.
        
        let pattern = "\\.\\d+\\."
        let regExp = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive, error: nil)
        let range = NSMakeRange(0, (str as NSString).length)
        
        // Only allow decimal point to be added if it doesn't fit the stated duplicate-decimal/numeral pattern:
        
        if let numberMatches = regExp?.numberOfMatchesInString(str, options: NSMatchingOptions(0), range: range)
            where numberMatches == 0 {
                self.equationLabel.text = self.equationLabel.text! + "."
        }
    }
    
    // -----------------------------------------------------------------------------------------------------
    
    @IBAction func equalsAction(sender: UIButton) {
        let eqn = equationLabel.text!
        
        if eqn > "" {
            equationLabel.text = gCalculator!.processEquation(eqn)
            clearDisplay = true
        }
    }
    
    // -----------------------------------------------------------------------------------------------------
    // MARK: -
    
    func showAlert(title:String) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
        
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
}

// =======================================================================================================================

extension MainViewController:UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let myCell = collectionView.cellForItemAtIndexPath(indexPath) as! CalCollectionCell
        let clear = (indexPath.item == 0)
        let changeSign = (indexPath.item == 1)
        let percent = (indexPath.item == 2)
        let divide = (indexPath.item == 3)
        let multiply = (indexPath.item == 7)
        let subtract = (indexPath.item == 11)
        let add = (indexPath.item == 15)
        
        if clearDisplay {
            self.equationLabel.text = ""
            clearDisplay = false
        }
        
        switch indexPath.item {
        case 0,1,2:
            if clear {
                var str = self.equationLabel.text!
                if str > "" {
                    let index = count(str)-1 as Int
                    str = (str as NSString).substringToIndex(index)
                    self.equationLabel.text = str
                }
            } else if changeSign {
                let str = self.equationLabel.text!
                if str > "" {
                    let firstChar = (str as NSString).substringToIndex(1)
                    if firstChar == "-" {
                        self.equationLabel.text = (str as NSString).substringFromIndex(1)
                    } else {
                        self.equationLabel.text = "-" + self.equationLabel.text!
                    }
                }
            } else if percent {
                let str = self.equationLabel.text!
                if str > "" {
                    let index = count(str)-1 as Int
                    let lastChar = (str as NSString).substringFromIndex(index)
                    if lastChar == "%" {
                        self.equationLabel.text = (str as NSString).substringToIndex(index)
                    } else {
                        self.equationLabel.text = self.equationLabel.text! + "%"
                    }
                }
            }
        case 3,7,11,15:
            let str = self.equationLabel.text!
            if divide {
                if str > "" {
                    let index = count(str)-1 as Int
                    let lastChar = (str as NSString).substringFromIndex(index)
                    if lastChar == "/" {
                        self.equationLabel.text = (str as NSString).substringToIndex(index)
                    } else {
                        self.equationLabel.text = self.equationLabel.text! + "/"
                    }
                }
            } else if multiply {
                if str > "" {
                    let index = count(str)-1 as Int
                    let lastChar = (str as NSString).substringFromIndex(index)
                    if lastChar == "*" {
                        self.equationLabel.text = (str as NSString).substringToIndex(index)
                    } else {
                        self.equationLabel.text = self.equationLabel.text! + "*"
                    }
                }
            } else if subtract {
                if str > "" {
                    let index = count(str)-1 as Int
                    let lastChar = (str as NSString).substringFromIndex(index)
                    if lastChar == "-" {
                        self.equationLabel.text = (str as NSString).substringToIndex(index)
                    } else {
                        self.equationLabel.text = self.equationLabel.text! + "-"
                    }
                }
            } else if add {
                let index = count(str)-1 as Int
                let lastChar = (str as NSString).substringFromIndex(index)
                if lastChar == "+" {
                    self.equationLabel.text = (str as NSString).substringToIndex(index)
                } else {
                    self.equationLabel.text = self.equationLabel.text! + "+"
                }
            }
        default:
            self.equationLabel.text = self.equationLabel.text! + myCell.cellLabel.text!
            
        }
    }
}

// =======================================================================================================================

extension MainViewController:UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CalendarCell", forIndexPath:indexPath) as! CalCollectionCell
        
        if indexPath.item == 0 || indexPath.item == 1 || indexPath.item == 2 {
            cell.backgroundColor = UIColor.lightGrayColor()
        }
        if indexPath.item == 3 || indexPath.item == 7 || indexPath.item == 11 || indexPath.item == 15 {
            cell.backgroundColor = UIColor.orangeColor()
        }
        
        cell.tag = indexPath.item
        
        switch indexPath.item {
        case 0:
            cell.cellLabel.text = "C"
        case 1:
            cell.cellLabel.font = UIFont(name: "HelveticaNeue", size: 38.0)
            cell.cellLabel.text = "+/-"
        case 2:
            cell.cellLabel.text = "%"
        case 3:
            cell.cellLabel.text = "/"
        case 4:
            cell.cellLabel.text = "7"
        case 5:
            cell.cellLabel.text = "8"
        case 6:
            cell.cellLabel.text = "9"
        case 7:
            cell.cellLabel.text = "X"
        case 8:
            cell.cellLabel.text = "4"
        case 9:
            cell.cellLabel.text = "5"
        case 10:
            cell.cellLabel.text = "6"
        case 11:
            cell.cellLabel.text = "-"
        case 12:
            cell.cellLabel.text = "1"
        case 13:
            cell.cellLabel.text = "2"
        case 14:
            cell.cellLabel.text = "3"
        case 15:
            cell.cellLabel.text = "+"
            
        default:
            println("")
        }
        
        return cell as UICollectionViewCell
        
    }
    
    
}



