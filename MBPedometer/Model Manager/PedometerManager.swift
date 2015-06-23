//
//  PedometerManager.swift
//  Pedometer
//
//  Created by Ashutosh on 21/06/15.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import UIKit
import CoreMotion

enum DataSourceType {
  case DataSourceTypeHealthKit, DataSourceTypeCoreMotion
}

//Activity Structure to be passed
public struct Activity {
  
  var startDate : NSDate
  var endDate : NSDate
  public var stepCount : NSNumber
  public var distanceCovered : NSNumber
  public var floorsAscended: NSNumber
  public var floorsDescended: NSNumber
  
  init(startDate : NSDate, endDate : NSDate){
    self.startDate = startDate
    self.endDate = endDate
    self.stepCount = NSNumber()
    self.distanceCovered = NSNumber()
    self.floorsAscended = NSNumber()
    self.floorsDescended = NSNumber()
  }
}

public typealias CompletionBlock = (Activity?,NSError?) -> Void
public typealias CompletionBlock_History = (stepsAraay: Array<Int>?, dateArray: Array<String>?, distanceArray: Array<Float>?, NSError?) -> Void

public class PedometerManager: NSObject {
  
  var myActivityArray = [Activity]()
  let activityManager = CMMotionActivityManager()
  let pedoMeter = CMPedometer()
  var days:[String] = []
  var stepsTaken:[Int] = []
  var distanceTravelled:[Float] = []
  
  static let sharedInstance = PedometerManager()
  
  //Check whether your application supports step counting or not
  public func checkStepCountingAvailability() -> Bool {
    return(CMPedometer.isStepCountingAvailable())
  }
  
  //Check whether your application supports floor counting or not
  public func checkFloorCountingAvailability() -> Bool {
    return(CMPedometer.isFloorCountingAvailable())
  }
  //Stop getting updates
  public func stopCountingUpdates() {
    self.pedoMeter.stopPedometerUpdates()
  }
  //Check whether your application supports activity tracking
  public func checkForMotionActivityAvailability() -> Bool {
    return (CMMotionActivityManager.isActivityAvailable())
  }
  
  //Calculate Steps for specific intervels
  public func calculateStepsForInterval(#startDate:NSDate, endDate:NSDate,completionBlock:CompletionBlock) {
    var currentActivity = Activity(startDate: startDate, endDate: endDate)
    
    if(CMPedometer.isStepCountingAvailable()){
      self.pedoMeter.queryPedometerDataFromDate(startDate, toDate: endDate) { (activity : CMPedometerData!, error)  in
        println(activity)
        dispatch_async(dispatch_get_main_queue(), { () in
          if(error == nil) {
            currentActivity.stepCount = activity.numberOfSteps
            currentActivity.distanceCovered = activity.distance
            currentActivity.floorsAscended = activity.floorsAscended
            currentActivity.floorsDescended = activity.floorsDescended
            completionBlock(currentActivity, nil)
          }
          else {
            completionBlock(nil,error)
          }
        })
      }
    }
  }
  
  //Count steps for live updates
  public func startStepCounterFromDate(date:NSDate, completionBlock:CompletionBlock) {
    var currentActivity = Activity(startDate: date,endDate: NSDate())
    self.pedoMeter.startPedometerUpdatesFromDate(date, withHandler: { (data: CMPedometerData!, error) -> Void in
      if (error == nil) {
        currentActivity.startDate = data.startDate
        currentActivity.endDate = data.endDate
        currentActivity.stepCount = data.numberOfSteps
        currentActivity.distanceCovered = data.distance
        currentActivity.floorsAscended = data.floorsAscended
        currentActivity.floorsDescended = data.floorsDescended
        completionBlock(currentActivity, nil)
      }
      else {
        completionBlock(nil, error)
      }
      
      
    })
  }
  
  
  //Get History of last 7 days
  func getHistory(completionBlock: CompletionBlock_History) {
    var serialQueue : dispatch_queue_t  = dispatch_queue_create("com.example.MyQueue", nil)
    let formatter = NSDateFormatter()
    formatter.dateFormat = "d MMM"
    
    let today = NSDate()
    for day in 0...6{
      let fromDate = NSDate(timeIntervalSinceNow: Double(-7+day) * 86400)
      let toDate = NSDate(timeIntervalSinceNow: Double(-7+day+1) * 86400)
      let dtStr = formatter.stringFromDate(toDate)
      self.pedoMeter.queryPedometerDataFromDate(fromDate, toDate: toDate) { (data : CMPedometerData!, error) in
        if(error == nil){
          self.days.append(dtStr)
          self.stepsTaken.append(Int(data.numberOfSteps))
          self.distanceTravelled.append(data.distance.floatValue)
          if(self.days.count == 7){
            dispatch_async(dispatch_get_main_queue(), { () in
              completionBlock(stepsAraay: self.stepsTaken, dateArray: self.days, distanceArray: self.distanceTravelled, error)
            })
            
          }
        }
        else {
          completionBlock(stepsAraay: nil, dateArray: nil, distanceArray: nil, error)
        }
      }
      
    }
  }
  
}

