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
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    
    @IBOutlet weak var activityListTable: UITableView!
    
    var activityRecordsList = [ActivityRecord]()
    let tableCellID2 = "ActivityListItem"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let moc = self.managedObjectContext {
            
            activityListTable.delegate = self
            activityListTable.dataSource = self
        }
        // Do any additional setup after loading the view, typically from a nib.
        
        fetchLog()
    }
    
    func fetchLog() {
        let fetchRequest = NSFetchRequest(entityName: "ActivityRecord")
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
        let cell = tableView.dequeueReusableCellWithIdentifier(tableCellID2, forIndexPath: indexPath) as UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = activityRecordsList[row].type
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        println(activityRecordsList[row].type)
    }

}

