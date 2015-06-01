//
//  PieChartView.swift
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

class PieChartView: UIView {
    var items: [PieChartItem] = [PieChartItem]()
    // total is always 24 hours
    var sum: Float = 24*60*60
    
    var gradientFillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)

    var gradientStart: Float = 0.3
    var gradientEnd: Float = 1

    
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
        
        let ctx: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 0.4)
        CGContextSetLineWidth(ctx, 1.0)

        var x: CGFloat = self.center.x
        var y: CGFloat = self.center.y
        var r: CGFloat = (self.bounds.size.width > self.bounds.size.height ? self.bounds.size.height : self.bounds.size.width)/2 * 0.8
        
        // Background
        CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.35 );
        CGContextAddArc(ctx, x, y, r, 0.0, CGFloat(360.0 * M_PI / 180.0), 0)
        CGContextClosePath(ctx)
        CGContextFillPath(ctx);
        
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
                CGContextSetRGBFillColor(ctx, red, green, blue, alpha );
                CGContextMoveToPoint(ctx, x, y);
                let startAngle: CGFloat = (CGFloat(startDeg)-90.0) * CGFloat(M_PI) / 180.0
                let endAngle: CGFloat = (CGFloat(endDeg)-90.0) * CGFloat(M_PI) / 180.0
                CGContextAddArc(ctx, x, y, r, startAngle, endAngle, 0)
                CGContextClosePath(ctx);
                CGContextFillPath(ctx);
            }
        }
        
        // Make it a donut
        CGContextSetRGBFillColor(ctx, 1, 1, 1, 1 );
        CGContextAddArc(ctx, x, y, r*0.75, 0.0, CGFloat(360.0 * M_PI / 180.0), 0)
        CGContextClosePath(ctx)
        CGContextFillPath(ctx);
        
        // add clock lines
        CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 0.25)
        CGContextSetLineWidth(ctx, 1)
        // -midnight
        CGContextMoveToPoint(ctx, x, y-r)
        CGContextAddLineToPoint(ctx, x, y-r*0.75)
        CGContextDrawPath(ctx, kCGPathStroke)
        // -6am
        CGContextMoveToPoint(ctx, x+r, y)
        CGContextAddLineToPoint(ctx, x+r*0.75, y)
        CGContextDrawPath(ctx, kCGPathStroke)
        // -noon
        CGContextMoveToPoint(ctx, x, y+r)
        CGContextAddLineToPoint(ctx, x, y+r*0.75)
        CGContextDrawPath(ctx, kCGPathStroke)
        // -6pm
        CGContextMoveToPoint(ctx, x-r, y)
        CGContextAddLineToPoint(ctx, x-r*0.75, y)
        CGContextDrawPath(ctx, kCGPathStroke)
    }
}
