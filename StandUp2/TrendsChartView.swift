//
//  TrendsViewController.swift
//  StandUp2
//
//  Created by Lindsey.Hanna on 7/13/15.
//  Copyright (c) 2015 Lindsey.Hanna. All rights reserved.
//

import UIKit
import CoreData

class ChartItem {
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
let AVERAGE_DAILY_PERCENT = 0
let AVERAGE_DAILY_HRS = 1
let ALL_TIME = 2

let chartTitles: [Int: String] = [
    0: "Average Daily Percent",
    1: "Average Daily Hours",
    2: "All Time"
]
class TrendsChartView: UIView {
    
    // default chart setup
    var requestedChart: Int = AVERAGE_DAILY_PERCENT
    
    var items: [ChartItem] = [ChartItem]()
    var sum: Float = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    // getters & setters
    func getTitle() -> String {
        return chartTitles[requestedChart]!
    }
    
    func setChartType(chart: Int) {
        requestedChart = chart
    }
    
    func clearItems() {
        items.removeAll(keepCapacity: true)
    }
    
    func addItem(startTime: NSDate, endTime: NSDate, activityType: String) {
        
        
        let item = ChartItem(startTime: startTime, endTime: endTime, activityType: activityType)
        
        items.append(item)
    }
    
    func getDegree(value: Float) -> Float {
        return Float(360.0 * (value/sum));
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        switch requestedChart {
            case 0:
                // draw pie chart
                println("percent")
                drawPieChart(rect)
                break
            case 1:
                // bar chart
                println("hours")
                break
            default:
                //line chart
                println("TODO")
        }
    }
    
    func drawPieChart(rect: CGRect) {
        var activityTotals: [String: Float] = [
            "Sitting": 0,
            "Standing": 0,
            "Walking": 0
        ]

        var days: [NSDate] = [NSDate]()

        // Loop through all the values and collect the information
        for item in self.items {
            // add the sums
            activityTotals[item.activityType] = activityTotals[item.activityType]! + item.durationFloat
            days.append(NSCalendar.currentCalendar().startOfDayForDate(item.startTime))
        }
        
        let numDays: Float = Float((NSSet(array: days).allObjects).count)
        
        sum = 0
        for (activity, value) in activityTotals {
            activityTotals[activity] = value / numDays
            sum += activityTotals[activity]!
        }
        
        // Drawing code
        
        var startDeg: Float = 0
        var endDeg: Float = 0
        
        let context: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.4)
        CGContextSetLineWidth(context, 1.0)
        
        var radius: CGFloat = (self.bounds.size.height < self.bounds.size.width ? self.bounds.size.height : self.bounds.size.width) / 2 * 0.9
        var x: CGFloat = self.bounds.midX
        var y: CGFloat = self.bounds.midY
        
        // Background
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.35 );
        CGContextAddArc(context, x, y, radius, 0.0, CGFloat(360.0 * M_PI / 180.0), 0)
        CGContextClosePath(context)
        CGContextFillPath(context);
        
        // Loop through all the values and draw the graph
        if (sum <= 0) {
            return
        }
        
        for (activity, value) in activityTotals {
            let numComponents = CGColorGetNumberOfComponents(ACTIVITY_COLORS[activity]?.CGColor)
            
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            if (numComponents == 4) {
                let components = CGColorGetComponents(ACTIVITY_COLORS[activity]?.CGColor)
                red = components[0]
                green = components[1]
                blue = components[2]
                alpha = components[3]
            }

            endDeg = startDeg + getDegree(value)
            
            if (startDeg != endDeg) {
                CGContextSetRGBFillColor(context, red, green, blue, alpha );
                CGContextMoveToPoint(context, x, y);
                let startAngle: CGFloat = (CGFloat(startDeg)-90.0) * CGFloat(M_PI) / 180.0
                let endAngle: CGFloat = (CGFloat(endDeg)-90.0) * CGFloat(M_PI) / 180.0
                CGContextAddArc(context, x, y, radius, startAngle, endAngle, 0)
                CGContextClosePath(context);
                CGContextFillPath(context);
            }
            
            startDeg = endDeg
        }
    }
}
