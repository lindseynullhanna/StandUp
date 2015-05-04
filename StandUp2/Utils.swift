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


