//
//  TrendsViewController.swift
//  StandUp2
//
//  Created by Lindsey.Hanna on 7/13/15.
//  Copyright (c) 2015 Lindsey.Hanna. All rights reserved.
//

import UIKit
import CoreData

class TrendsViewController: UIViewController {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    let formatter = NSDateFormatter()
    let today = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
    
    // Outlets
    @IBOutlet weak var trendsLabel: UILabel!
    @IBOutlet weak var trendsChartView: TrendsChartView!
    @IBOutlet weak var dailyPctButton: UIButton!
    @IBOutlet weak var dailyHrsButton: UIButton!
    @IBOutlet weak var allTimeButton: UIButton!
    
    // Actions
    @IBAction func dailyPctAction(sender: AnyObject) {
        changeChartView(AVERAGE_DAILY_PERCENT)
    }
    @IBAction func dailyHrsAction(sender: AnyObject) {
        changeChartView(AVERAGE_DAILY_HRS)
    }
    @IBAction func allTimeAction(sender: AnyObject) {
        changeChartView(ALL_TIME)
    }
    
    // Local Variables
    var activityRecordsList = [ActivityRecord]()
    let tableCellID2 = "ActivityListItem"
    let colors: [String: UIColor] = [
        "Standing": UIColor.blueColor(),
        "Sitting": UIColor.greenColor(),
        "Walking": UIColor.purpleColor()
    ]
    var requestedDate = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let moc = self.managedObjectContext {
        }
        // Do any additional setup after loading the view, typically from a nib.
        
        
        fetchLog()
        trendsLabel.text = "Average Duration per Day"
        
        refreshTrendsView()
        
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = NSDateFormatterStyle.NoStyle
        
    }

    func fetchLog() {
        let fetchRequest = NSFetchRequest(entityName: "ActivityRecord")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        fetchRequest.shouldRefreshRefetchedObjects = true
        
//        var startDate = NSCalendar.currentCalendar().startOfDayForDate(requestedDate)
//        var endDate = NSDate(timeInterval: NSTimeInterval(60*60*24), sinceDate: NSCalendar.currentCalendar().startOfDayForDate(requestedDate))
//        
//        let datePredicate = NSPredicate(format: "startTime BETWEEN {%@, %@}", argumentArray: [startDate, endDate])
//        
//        fetchRequest.predicate = datePredicate
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ActivityRecord] {
            activityRecordsList = fetchResults
        }
        
        // add chart data
        trendsChartView.clearItems()
        for (var i = 0; i < activityRecordsList.count; i++) {
            let record = activityRecordsList[i]
            
            trendsChartView.addItem(record.startTime, endTime: record.endTime, activityType: record.type)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // MARK: rendering methods
    func refreshTrendsView() {
        fetchLog()
        trendsChartView.setNeedsDisplay()
    }
    
    func changeChartView(chartType: Int) {
        trendsLabel.text = chartTitles[chartType]
        trendsChartView.setChartType(chartType)
        trendsChartView.setNeedsDisplay()
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshTrendsView()
    }
}

class TrendsCollectionController: UICollectionViewController {
    
}