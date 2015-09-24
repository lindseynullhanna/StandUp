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
        currentActivityLabel.text = "Inactive"
    }
    
    // Activity table
    let activityList = ["Standing", "Walking", "Sitting"]
    let tableCellID = "ActivityCell"
    
    // Elapsed time
    var prevActivityType = ""
    var lastStartTime = NSDate()
    var timer = NSTimer()
    var isRecording: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadPreviousState()
        activityTable.delegate = self
        activityTable.dataSource = self
        endActivityButton.enabled = false
        
        if isRecording {
            startTimer(false)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"saveCurrentState", name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        startTimer(true)
    }
    
    func recordTime(activityType: String) {
        ActivityRecord.createInManagedObjectContext(
            self.managedObjectContext!,
            type: activityType,
            startTime: lastStartTime,
            endTime: NSDate())
    }
    
    func startTimer(restartTime: Bool) {
        endActivityButton.enabled = true
        // refresh stopwatch every .1sec
        let aSelector: Selector = "updateTime"
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        
        isRecording = true
        // set start time
        if restartTime {
            lastStartTime = NSDate()
        } else {
            currentActivityLabel.text = prevActivityType
        }
    }
    
    func stopTimerAndRecord(activityType: String) {
        endActivityButton.enabled = false
        updateTime()
        // record time
        recordTime(activityType)
        // reset stuff
        timer.invalidate()
        isRecording = false
    }
    
    // string displayed to stopwatch
    func updateTime() {
        
        var currentTime = NSDate()
        var elapsedTime: NSTimeInterval = currentTime.timeIntervalSinceDate(lastStartTime)
        let elapsedString = createDurationString(elapsedTime)
        elapsedTimeLabel.text = elapsedString
    }
    
    // MARK: State methods
    // MARK: Memento Pattern
    func saveCurrentState() {
        NSUserDefaults.standardUserDefaults().setObject(lastStartTime, forKey: "savedStartTime")
        NSUserDefaults.standardUserDefaults().setObject(prevActivityType, forKey: "savedActivityType")
        NSUserDefaults.standardUserDefaults().setBool(isRecording, forKey: "savedRecordingState")
    }
    
    func loadPreviousState() {
        var savedRecordingState: Bool? = NSUserDefaults.standardUserDefaults().objectForKey("savedRecordingState") as? Bool
        
        if savedRecordingState != nil && savedRecordingState == true {
            isRecording = true
            // if we were recording, reload state
            var savedStartTime: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("savedStartTime")
            
            // TODO: if date is not today?
            if savedStartTime != nil {
                lastStartTime = savedStartTime as! NSDate
            }
            var savedActivityType: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("savedActivityType")
            
            if savedActivityType != nil {
                prevActivityType = savedActivityType as! String
            }
        }
    }
}

