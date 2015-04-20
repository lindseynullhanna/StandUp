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
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    // Outlets
    @IBOutlet weak var activityTable: UITableView!
    @IBOutlet weak var currentActivityLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var endActivityButton: UIButton!
    
    // Actions
    @IBAction func endCurrentActivity(sender: UIButton) {
        stopTimerAndRecord(prevActivityType)
    }
    
    // Activity table
    let activityList = ["Standing", "Walking", "Sitting"]
    let tableCellID = "ActivityCell"
    
    // Elapsed time
    var prevActivityType = ""
    var lastStartTime = NSDate()
    var timer = NSTimer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        activityTable.delegate = self
        activityTable.dataSource = self
        endActivityButton.enabled = false
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
        let cell = tableView.dequeueReusableCellWithIdentifier(tableCellID, forIndexPath: indexPath) as! UITableViewCell
        
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
            stopTimerAndRecord(prevActivityType)
        }
        
        // start a new timer
        prevActivityType = activityList[row]
        startTimer()
    }
    
    func recordTime(activityType: String) {
        ActivityRecord.createInManagedObjectContext(
            self.managedObjectContext!,
            type: activityType,
            startTime: lastStartTime,
            endTime: NSDate())
    }
    
    func startTimer() {
        endActivityButton.enabled = true
        // refresh stopwatch every .1sec
        let aSelector: Selector = "updateTime"
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        
        // set start time
        lastStartTime = NSDate()
    }
    
    func stopTimerAndRecord(activityType: String) {
        endActivityButton.enabled = false
        updateTime()
        // record time
        recordTime(activityType)
        // reset stuff
        timer.invalidate()
    }
    
    // string displayed to stopwatch
    func updateTime() {
        
        var currentTime = NSDate()
        var elapsedTime: NSTimeInterval = currentTime.timeIntervalSinceDate(lastStartTime)
        let elapsedString = createDurationString(elapsedTime)
        elapsedTimeLabel.text = elapsedString
    }
}

