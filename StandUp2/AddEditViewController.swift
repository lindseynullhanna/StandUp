//
//  AddEditViewController.swift
//  StandUp2
//
//  Created by Lindsey.Hanna on 6/15/15.
//  Copyright (c) 2015 Lindsey.Hanna. All rights reserved.
//

import UIKit
import CoreData

class AddEditViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // CONSTANTS
    var activityTypes = ["Standing", "Walking", "Sitting"]
    var formatter = NSDateFormatter()
    
    // PICKERS
    var activityPicker = UIPickerView()
    var startTimePicker = UIDatePicker()
    var endTimePicker = UIDatePicker()

    // OUTLETS
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var pickerContainer: UIView!
    @IBOutlet weak var addActivityButtonOutlet: UIButton!
    
    // ACTIONS
    @IBAction func activityButton(sender: AnyObject) {
        clearPickerViews()
        pickerContainer.addSubview(activityPicker)
    }
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func startTimeButton(sender: AnyObject) {
        clearPickerViews()
        pickerContainer.addSubview(startTimePicker)
        startTimePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    @IBAction func endTimeButton(sender: AnyObject) {
        clearPickerViews()
        pickerContainer.addSubview(endTimePicker)
        endTimePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    @IBAction func addActivityButton(sender: AnyObject) {
        // TODO: persist activity
        ActivityRecord.createInManagedObjectContext(
            self.managedObjectContext!,
            type: newType,
            startTime: newStart,
            endTime: newEnd
        )
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    var newType = ""
    var newStart = NSDate()
    var newEnd = NSDate()
    
    
    @IBAction func datePickerChanged(sender: UIDatePicker) {
        
        if (sender === startTimePicker) {
            newStart = startTimePicker.date
            startTimeLabel.text = formatter.stringFromDate(newStart)
        } else if (sender === endTimePicker) {
            newEnd = endTimePicker.date
            endTimeLabel.text = formatter.stringFromDate(newEnd)
        }
        
        var elapsedTime = newEnd.timeIntervalSinceDate(newStart)
        
        if (elapsedTime >= 60) {
            addActivityButtonOutlet.enabled = true
            durationLabel.text = createDurationString(elapsedTime)
        } else {
            addActivityButtonOutlet.enabled = false
            durationLabel.text = "invalid selection"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        if let moc = self.managedObjectContext {
//            // TODO get types here
//        }
        
        // Do any additional setup after loading the view, typically from a nib.
        activityPicker.dataSource = self
        activityPicker.delegate = self
        
        startTimePicker.maximumDate = NSDate()
        endTimePicker.maximumDate = NSDate()
        
        newType = activityTypes[0]
        
        // default labels
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        activityLabel.text = newType
        startTimeLabel.text = formatter.stringFromDate(newStart)
        endTimeLabel.text = formatter.stringFromDate(newEnd)
        durationLabel.text = "0 minutes"
        
        addActivityButtonOutlet.enabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UIPICKERVIEW
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if (pickerView === activityPicker) {
            return 1
        }
        return 0
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView === activityPicker) {
            return activityTypes.count
        }
        return 0
    }
    
    // returns title for each row
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if (pickerView === activityPicker) {
            return activityTypes[row]
        }
        return ""
    }
    
    // returns function to be performed on row selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView === activityPicker) {
            newType = activityTypes[row]
            activityLabel.text = newType
        }
    }
    
    func clearPickerViews() {
        for (var i = 0; i < pickerContainer.subviews.count; i++) {
            pickerContainer.subviews[i].removeFromSuperview()
        }
    }
}
