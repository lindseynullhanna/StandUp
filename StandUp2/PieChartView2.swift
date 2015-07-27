//
//  PieChartView2.swift
//
//  Created by Vito Bellini on 03/01/15.
//  Copyright (c) 2015 Vito Bellini. All rights reserved.
//
//  Modified by Lindsey Hanna on 4/6/15
//

import UIKit

let colors: [String: UIColor] = [
    "Standing": UIColor.blueColor(),
    "Sitting": UIColor.greenColor(),
    "Walking": UIColor.purpleColor()
]

class PieChartItem {
    var color: UIColor
    var activityType: String
    var startTime: NSDate
    var endTime: NSDate
    
    init(startTime: NSDate, endTime: NSDate, activityType: String) {
        self.color = colors[activityType]!
        self.startTime = startTime
        self.endTime = endTime
        self.activityType = activityType
    }
}

class PieChartView2: UIView {
    var items: [PieChartItem] = [PieChartItem]()
    // total is always 24 hours
    let sum: Float = 24*60*60
    
    var gradientFillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)

    var gradientStart: Float = 0.3
    var gradientEnd: Float = 1
    
    
    let donutRadius : CGFloat = 0.75

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    func clearItems() {
        items.removeAll(keepCapacity: true)
    }
    
    func addItem(startTime: NSDate, endTime: NSDate, activityType: String) {
        
        
        let item = PieChartItem(startTime: startTime, endTime: endTime, activityType: activityType)
        
        items.append(item)
    }

    func getDegree(value: Float) -> Float {
        return Float(360.0 * (value/sum));
    }

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        
        // Drawing code
        
        var startDeg: Float = 0
        var endDeg: Float = 0
        
        let context: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.4)
        CGContextSetLineWidth(context, 1.0)

        var radius: CGFloat = self.bounds.size.height / 2 * 0.9
        var x: CGFloat = self.bounds.midX
        var y: CGFloat = self.bounds.midY
        
        // Background
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.35 );
        CGContextAddArc(context, x, y, radius, 0.0, CGFloat(360.0 * M_PI / 180.0), 0)
        CGContextClosePath(context)
        CGContextFillPath(context);
        
        // Loop through all the values and draw the graph
        for item in self.items {
            // TODO: actual times
            let numComponents = CGColorGetNumberOfComponents(item.color.CGColor)
            
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            if (numComponents == 4) {
                let components = CGColorGetComponents(item.color.CGColor)
                red = components[0]
                green = components[1]
                blue = components[2]
                alpha = components[3]
            }
            
            // midnight of current day
            let startOfDay = NSCalendar.currentCalendar().startOfDayForDate(item.startTime)
            
            // startDeg = startTime since midnight
            startDeg = getDegree(Float(item.startTime.timeIntervalSinceDate(startOfDay)))
            
            // endDeg = endTime since midnight
            var endDeg = getDegree(Float(item.endTime.timeIntervalSinceDate(startOfDay)))

            if (startDeg != endDeg) {
                CGContextSetRGBFillColor(context, red, green, blue, alpha );
                CGContextMoveToPoint(context, x, y);
                let startAngle: CGFloat = (CGFloat(startDeg)-90.0) * CGFloat(M_PI) / 180.0
                let endAngle: CGFloat = (CGFloat(endDeg)-90.0) * CGFloat(M_PI) / 180.0
                CGContextAddArc(context, x, y, radius, startAngle, endAngle, 0)
                CGContextClosePath(context);
                CGContextFillPath(context);
            }
        }
        
        // Make it a donut
        CGContextSetRGBFillColor(context, 1, 1, 1, 1 );
        CGContextAddArc(context, x, y, radius*donutRadius, 0.0, CGFloat(360.0 * M_PI / 180.0), 0)
        CGContextClosePath(context)
        CGContextFillPath(context);
        
        // add clock lines
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 0.25)
        CGContextSetLineWidth(context, 1)
        // -midnight
        CGContextMoveToPoint(context, x, y-radius)
        CGContextAddLineToPoint(context, x, y-radius*donutRadius)
        CGContextDrawPath(context, kCGPathStroke)
        // -6am
        CGContextMoveToPoint(context, x+radius, y)
        CGContextAddLineToPoint(context, x+radius*donutRadius, y)
        CGContextDrawPath(context, kCGPathStroke)
        // -noon
        CGContextMoveToPoint(context, x, y+radius)
        CGContextAddLineToPoint(context, x, y+radius*donutRadius)
        CGContextDrawPath(context, kCGPathStroke)
        // -6pm
        CGContextMoveToPoint(context, x-radius, y)
        CGContextAddLineToPoint(context, x-radius*donutRadius, y)
        CGContextDrawPath(context, kCGPathStroke)
    }
}
