//
//  ActivityRecord.swift
//  StandUp2
//
//  Created by Lindsey.Hanna on 4/6/15.
//  Copyright (c) 2015 Lindsey.Hanna. All rights reserved.
//

import Foundation
import CoreData

@objc(ActivityRecord)
class ActivityRecord: NSManagedObject {

    @NSManaged var type: String
    @NSManaged var startTime: NSDate
    @NSManaged var endTime: NSDate

    class func createInManagedObjectContext(moc:NSManagedObjectContext, type: String, startTime: NSDate, endTime: NSDate) -> ActivityRecord {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("ActivityRecord", inManagedObjectContext: moc) as! ActivityRecord
        newItem.type = type
        newItem.startTime = startTime
        newItem.endTime = endTime
        
        return newItem
    }
}
