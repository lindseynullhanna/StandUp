//
//  PieChartView.swift
//
//  Created by Vito Bellini on 03/01/15.
//  Copyright (c) 2015 Vito Bellini. All rights reserved.
//

import UIKit

class PieChartItem {
    var color: UIColor
    var value: Float
    
    init(value: Float = 0, color: UIColor) {
        self.color = color
        self.value = value
    }
}

class PieChartView: UIView {
    var items: [PieChartItem] = [PieChartItem]()
    var sum: Float = 0
    
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
        sum = 0
    }
    
    func addItem(value: Float, color: UIColor) {
        let item = PieChartItem(value: value, color: color)
        
        items.append(item)
        sum += value
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
        
        // Loop through all the values and draw the graph
        startDeg = 0;
        
        for item in self.items {
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
            
            var currentValue: Float = item.value;
            
            var theta: Float = (360.0 * (currentValue/sum));
            
            if(theta > 0.0) {
                endDeg += theta;
                
                if( startDeg != endDeg ) {
                    CGContextSetRGBFillColor(ctx, red, green, blue, alpha );
                    CGContextMoveToPoint(ctx, x, y);
                    let startAngle: CGFloat = (CGFloat(startDeg)-90.0) * CGFloat(M_PI) / 180.0
                    let endAngle: CGFloat = (CGFloat(endDeg)-90.0) * CGFloat(M_PI) / 180.0
                    CGContextAddArc(ctx, x, y, r, startAngle, endAngle, 0)
                    CGContextClosePath(ctx);
                    CGContextFillPath(ctx);
                }
                
            }
            
            startDeg = endDeg;
        }
        
        // Make it a donut
        CGContextSetRGBFillColor(ctx, 1, 1, 1, 1 );
        CGContextAddArc(ctx, x, y, r*0.75, 0.0, CGFloat(360.0 * M_PI / 180.0), 0)
        CGContextClosePath(ctx)
        CGContextFillPath(ctx);

    }

}
