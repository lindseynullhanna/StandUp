//
//  Utils.swift
//  StandUp2
//
//  Created by Lindsey.Hanna on 4/10/15.
//  Copyright (c) 2015 Lindsey.Hanna. All rights reserved.
//

import Foundation

public func createDurationString(timeInterval: NSTimeInterval) -> String {
        var elapsedTime = timeInterval
    
    if (elapsedTime == 0) {
        return "none"
    }
        // set variables
        let hours = UInt8(elapsedTime / 3600.0)
        elapsedTime -= (NSTimeInterval(hours) * 3600)
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        let seconds = UInt8(elapsedTime)
        
        // create strings
        let strHours = hours > 9 ? String(hours):"0" + String(hours)
        let strMinutes = minutes > 9 ? String(minutes):"0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)
        
        // concat string and apply to label
        let durationString = "\(strHours):\(strMinutes):\(strSeconds)"
        return durationString
}

public class Record {
    var activityType: String
    var startTime: NSDate
    var endTime: NSDate
    
    init(startTime: NSDate, endTime: NSDate, activityType: String) {
        self.startTime = startTime
        self.endTime = endTime
        self.activityType = activityType
    }
}

public func getDummyData(numDays: Int) -> [Record]{
    var startDate = NSDate()
    let types = ["Standing", "Sitting", "Walking"]
    var data: [Record] = [Record]()
    
    for (var i = 0; i < numDays; i++) {
        var daysBackward = NSTimeInterval(60*60*24*i)
        
        var startTime = NSDate(timeInterval: (NSTimeInterval(60*60*(8+i)) - daysBackward), sinceDate: NSCalendar.currentCalendar().startOfDayForDate(startDate))

        // 4 hours standing
        var endTime = NSDate(timeInterval: NSTimeInterval(60*60*4), sinceDate: startTime)
        data.append(Record(startTime: startTime, endTime: endTime, activityType: types[0]))
        
        // 30 min out
        startTime = endTime
        endTime = NSDate(timeInterval: NSTimeInterval(60*60*0.5), sinceDate: startTime)
        
        // 1.5 hours sitting
        startTime = endTime
        endTime = NSDate(timeInterval: NSTimeInterval(60*60*1.5), sinceDate: startTime)
        data.append(Record(startTime: startTime, endTime: endTime, activityType: types[1]))
        
        // 1 hour walking
        startTime = endTime
        endTime = NSDate(timeInterval: NSTimeInterval(60*60*1), sinceDate: startTime)
        data.append(Record(startTime: startTime, endTime: endTime, activityType: types[2]))
        
        // 1 hour standing
        startTime = endTime
        endTime = NSDate(timeInterval: NSTimeInterval(60*60*1), sinceDate: startTime)
        data.append(Record(startTime: startTime, endTime: endTime, activityType: types[0]))
        
    }
    
    return data
}
