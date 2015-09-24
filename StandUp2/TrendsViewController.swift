//
//  TrendsViewController.swift
//  StandUp2
//
//  Created by Lindsey.Hanna on 7/13/15.
//  Copyright (c) 2015 Lindsey.Hanna. All rights reserved.
//

import UIKit
import CoreData
import Charts

class TrendsChartItem {
    var color: UIColor
    var activityType: String
    var startTime: NSDate
    var endTime: NSDate
    var durationFloat: Float
    
    init(startTime: NSDate, endTime: NSDate, activityType: String) {
        self.color = UIColor.blackColor()
        self.startTime = startTime
        self.endTime = endTime
        self.activityType = activityType
        self.durationFloat = Float(endTime.timeIntervalSinceDate(startTime))
    }
}

class TrendsViewController: UIViewController {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    let formatter = NSDateFormatter()
    let today = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
    
    // Outlets
    @IBOutlet weak var trendsLabel: UILabel!
    @IBOutlet weak var dailyPctButton: UIButton!
    @IBOutlet weak var dailyHrsButton: UIButton!
    @IBOutlet weak var allTimeButton: UIButton!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var barChartView: BarChartView!
    

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
    var chartItems: [TrendsChartItem] = [TrendsChartItem]()
    var requestedDate = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let moc = self.managedObjectContext {
        }
        // Do any additional setup after loading the view, typically from a nib.
        
        
        fetchLog()
        
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        setChart(1)
        
    }
    
    func setChart(chartType: Int) {
        pieChartView.hidden = true
        barChartView.hidden = true
        
        trendsLabel.text = chartTitles[chartType]
        if activityRecordsList.count == 0 {
            return
        }
        switch chartType {
        case 0:
            drawPieChart(true)
        case 1:
            drawBarChart()
        default:
            break
        }
        
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
        chartItems.removeAll(keepCapacity: true)
        for (var i = 0; i < activityRecordsList.count; i++) {
            let record = activityRecordsList[i]
            
            let item = TrendsChartItem(startTime: record.startTime, endTime: record.endTime, activityType: record.type)
            chartItems.append(item)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: rendering methods
    func refreshTrendsView() {
        fetchLog()
        pieChartView.setNeedsDisplay()
    }
    
    func changeChartView(chartType: Int) {
        setChart(chartType)
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshTrendsView()
    }
    var activityTotals: [String: Float] = [String: Float]()
    var days: [NSDate] = [NSDate]()
    
    func calculateAverages() {
        self.activityTotals = [
            "Sitting": 0,
            "Standing": 0,
            "Walking": 0
        ]
        
        days = [NSDate]()
        
        // Loop through all the values and collect the information
        for item in self.chartItems {
            // add the sums
            self.activityTotals[item.activityType] = self.activityTotals[item.activityType]! + item.durationFloat
            days.append(NSCalendar.currentCalendar().startOfDayForDate(item.startTime))
        }
        
        let numDays: Float = Float((NSSet(array: self.days).allObjects).count)
        var sum: Float = 0.0
        for (activity, value) in self.activityTotals {
            // convert to average hrs/day
            self.activityTotals[activity] = value / numDays / 60 / 60
            sum += self.activityTotals[activity]!
        }
    }
    
    func drawPieChart(isPercent: Bool) {
        calculateAverages()

        var yValues: [ChartDataEntry] = []
        var xValues: [String] = []
        var pieColors: [UIColor] = []
        
        var i = 0
        for (kind, value) in self.activityTotals {
            xValues.append(kind)
            pieColors.append(colors[kind]!)
            let dataEntry = ChartDataEntry(value: Double(value), xIndex: i)
            yValues.append(dataEntry)
            i++
        }
        var unitLabel = ""
        if (isPercent) {
            pieChartView.usePercentValuesEnabled = true
            unitLabel = "(%)"
        } else {
            pieChartView.usePercentValuesEnabled = false
            unitLabel = "(hours)"
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: yValues, label: unitLabel)
        pieChartDataSet.colors = pieColors
        let pieChartData = PieChartData(xVals: xValues, dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        pieChartView.descriptionText = ""
        pieChartView.legend.enabled = false
        
        pieChartView.hidden = false
        pieChartView.setNeedsDisplay()
    }
    
    func drawBarChart() {
        calculateAverages()
        
        var xValues: [String] = []
        var yValues: [BarChartDataEntry] = []
        var barColors: [UIColor] = []
        
        var i = 0
        for (kind, value) in self.activityTotals {
            xValues.append(kind)
            barColors.append(colors[kind]!)
            let dataEntry = BarChartDataEntry(value: Double(value), xIndex: i)
            yValues.append(dataEntry)
            i++
        }
        
        let barChartDataSet = BarChartDataSet(yVals: yValues, label: "Hours")
        barChartDataSet.colors = barColors
        let barChartData = BarChartData(xVals: xValues, dataSet: barChartDataSet)
        barChartData.setValueFont(UIFont.systemFontOfSize(12.0))
        
        barChartView.data = barChartData
        barChartView.xAxis.labelPosition = .Bottom
        barChartView.rightAxis.enabled = false
        
        barChartView.legend.enabled = false
        barChartView.descriptionText = ""
        
        barChartView.hidden = false
        barChartView.setNeedsDisplay()
    }
}