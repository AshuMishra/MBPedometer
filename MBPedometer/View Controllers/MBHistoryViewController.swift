//
//  HistoryViewController.swift
//  MBPedometer
//
//  Created by Ashutosh on 22/06/15.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import UIKit
import CoreMotion

class HistoryViewController: UIViewController {

    var stepArray: [Int] = []
    var dateArray: [String] = []
    var distanceArray: [Float] = []
    var pedometerManager:PedometerManager!
   
    @IBOutlet weak var historyTableView: UITableView!
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        self.pedometerManager = PedometerManager()
          // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.pedometerManager.getHistory { (stepArray, dateArray, distanceArray,error) -> Void in
            if error == nil {
                self.stepArray = stepArray!
                self.dateArray = dateArray
                self.distanceArray = distanceArray
                self.historyTableView.reloadData()
            }
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: UITableView Datasource and Delegate Methods:
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateArray.count
    }
    
  
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("historyCell", forIndexPath: indexPath) as! HistoryTableViewCell
        cell.backgroundColor = UIColor.clearColor()
        
        cell.stepsLabel.text = NSString(format: "%d (Steps)", self.stepArray[indexPath.row]) as String
        cell.distanceLabel.text = NSString(format: "%.2f mtr", self.distanceArray[indexPath.row]) as String
        cell.dateLabel.text = NSString(format: "%@", dateArray[indexPath.row]) as String
     
        //To add addition height to row seprator
        var additionalSeparator: UIView = UIView(frame: CGRectMake(0,cell.frame.size.height-2,cell.frame.size.width,2))
        additionalSeparator.backgroundColor = UIColor(red: 234.0/255.0, green: 234.0/255.0, blue: 234.0/255.0, alpha: 1.0)
        cell.addSubview(additionalSeparator)
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 68.0
    }


}
