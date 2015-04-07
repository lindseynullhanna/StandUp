//
//  CurrentActivityViewController.swift
//  StandUp2
//
//  Created by Lindsey.Hanna on 4/6/15.
//  Copyright (c) 2015 Lindsey.Hanna. All rights reserved.
//

import UIKit

class CurrentActivityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    
    
    // Outlets
    @IBOutlet weak var activityTable: UITableView!
    @IBOutlet weak var currentActivityLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!

    // Activity table
    let activityList = ["Standing", "Walking", "Sitting"]
    let tableCellID = "ActivityCell"
    
    // Elapsed time
    var lastStartTime = NSTimeInterval()
    var timer = NSTimer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        activityTable.delegate = self
        activityTable.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:  UITextFieldDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableCellID, forIndexPath: indexPath) as UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = activityList[row]
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        currentActivityLabel.text = activityList[row]
        
        
        // elapsed time
        if timer.valid {
            // record time
            updateTime()
            ActivityRecord.createInManagedObjectContext(self.managedObjectContext!, type: activityList[row], duration: timer.timeInterval)
            stopTimer()
            
            
            
        }
        
        // start a new timer
        startTimer()
    }
    
    func startTimer() {
        let aSelector: Selector = "updateTime"
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        
        lastStartTime = NSDate.timeIntervalSinceReferenceDate()
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    func updateTime() {
        
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime: NSTimeInterval = currentTime - lastStartTime
        
        // set variables
        let hours = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(hours) * 60)
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        let seconds = UInt8(elapsedTime)
        
        // create strings
        let strHours = hours > 9 ? String(hours):"0" + String(hours)
        let strMinutes = minutes > 9 ? String(minutes):"0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)
        
        // concat string and apply to label
        elapsedTimeLabel.text = "\(strHours):\(strMinutes):\(strSeconds)"
    }
}

