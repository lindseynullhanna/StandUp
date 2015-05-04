//
//  TodayViewController.swift
//  StandUp2
//
//  Created by Lindsey.Hanna on 4/6/15.
//  Copyright (c) 2015 Lindsey.Hanna. All rights reserved.
//

import UIKit
import CoreData

class TodayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var activityListTable: UITableView!
    @IBOutlet weak var pieChartView: PieChartView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    var activityRecordsList = [ActivityRecord]()
    let tableCellID2 = "ActivityListItem"
    let colors: [String: UIColor] = [
        "Standing": UIColor.blueColor(),
        "Sitting": UIColor.greenColor(),
        "Walking": UIColor.purpleColor()
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let moc = self.managedObjectContext {
            
            activityListTable.delegate = self
            activityListTable.dataSource = self
        }
        // Do any additional setup after loading the view, typically from a nib.
        
        fetchLog()
        drawPieChartView()
        dateLabel.text = "Today"
    }
    
    func fetchLog() {
        let fetchRequest = NSFetchRequest(entityName: "ActivityRecord")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ActivityRecord] {
            activityRecordsList = fetchResults
        }
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
        return activityRecordsList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableCellID2, forIndexPath: indexPath) as! UITableViewCell
        
        let row = indexPath.row
        let record = activityRecordsList[row]
        var elapsedTime = record.endTime.timeIntervalSinceDate(record.startTime)
        
        let elapsedTimeText = createDurationString(elapsedTime)
        cell.textLabel?.text = activityRecordsList[row].type + " - " + elapsedTimeText
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        println(activityRecordsList[row].type)
    }
    
    func drawPieChartView() {
        for (var i = 0; i < activityRecordsList.count; i++) {
            let record = activityRecordsList[i]
            
            var elapsedTime = record.endTime.timeIntervalSinceDate(record.startTime)
            
            pieChartView.addItem(Float(elapsedTime), color: colors[record.type]!)
        }
        pieChartView.setNeedsDisplay()
    }
}

