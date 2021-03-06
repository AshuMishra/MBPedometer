//
//  ViewController.swift
//  MBPedometer
//
//  Created by Ashutosh on 21/06/15.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import UIKit
import CoreMotion

class MBPedoMeterViewController: UIViewController,UITextFieldDelegate {
  
  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var startDateTextField: UITextField!
  @IBOutlet weak var endDateTextField: UITextField!
  @IBOutlet weak var todayUpdatesView: UIView!
  @IBOutlet weak var previousUpdatesView: UIView!
  @IBOutlet weak var previousDayResultContainer: MBResultContainer!
  @IBOutlet weak var segmentButton: UISegmentedControl!
  @IBOutlet weak var resultContainer: MBResultContainer!
  @IBOutlet weak var footImageView: UIImageView!
  @IBOutlet weak var activityStatusLabel: UILabel!
  @IBOutlet weak var datePickerView: UIView!
  
  var startDate: NSDate?
  var endDate: NSDate?
  var cumulativeActivity: Activity!
  var activeTextField:UITextField!
  let activityManager = CMMotionActivityManager()
  
  //MARK: ViewController Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Home"
    self.setUpActivity()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if (self.segmentButton.selectedSegmentIndex == 0) {
      var currentEndDate = NSDate()
      var currentStartDate = self.midnightOfToday(currentEndDate)
      
      //The following method increments the current status of the various acitivies
      PedometerManager.sharedInstance.calculateStepsForInterval(startDate:currentStartDate, endDate:currentEndDate) { (activity, error) -> Void in
        if (error == nil) {
          self.cumulativeActivity = activity!
          self.resultContainer.updateResultWithActiviy(activity!)
          PedometerManager.sharedInstance.startStepCounterFromDate(self.cumulativeActivity.endDate, completionBlock: { (currentActivity, error) -> Void in
            
            //Get current values of the activity
            var finalActivity = Activity(startDate: currentActivity!.startDate, endDate: currentActivity!.endDate)
            //Add newly fetched values
            finalActivity.stepCount = NSNumber(int:self.cumulativeActivity.stepCount.intValue + currentActivity!.stepCount.intValue)
            finalActivity.distanceCovered = NSNumber(double:self.cumulativeActivity.distanceCovered.doubleValue + currentActivity!.distanceCovered.doubleValue)
            finalActivity.floorsAscended = NSNumber(int:self.cumulativeActivity.floorsAscended.intValue + currentActivity!.floorsAscended.intValue)
            finalActivity.floorsDescended = NSNumber(int:self.cumulativeActivity.floorsDescended.intValue + currentActivity!.floorsDescended.intValue)
            //update UI
            self.resultContainer.updateResultWithActiviy(finalActivity)
          })
        }
        else if (error?.code == 105) {
          self.showAlertWithMessage("you are not allowed to use Motion feature of app. Please go to Settings and allow the permission.")
        }
      }
    }
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    PedometerManager.sharedInstance.stopCountingUpdates()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //MARK: IBActions
  
  @IBAction func didSelectDate(sender: AnyObject) {
    self.activeTextField.text = formatDate(self.datePicker.date)
    if (self.activeTextField.isEqual(self.startDateTextField)) {
      self.startDate = self.datePicker.date
    }else {
      self.endDate = self.datePicker.date
    }
  }
  
  @IBAction func didTapEndTap(sender: UIButton) {
    self.activeTextField = self.endDateTextField
    self.endDateTextField.backgroundColor = UIColor(red: 153/255.0, green: 204.0/255, blue: 255/255.0, alpha: 1)
    self.startDateTextField.backgroundColor = UIColor.clearColor()
    self.datePicker.maximumDate = NSDate()
    self.datePicker.minimumDate = NSDate(timeIntervalSinceNow: -86400 * 7)
    self.datePickerView.hidden = false
    
  }
  
  @IBAction func didTapStartDate(sender: AnyObject) {
    self.activeTextField = self.startDateTextField
    self.startDateTextField.backgroundColor = UIColor(red: 153/255.0, green: 204.0/255, blue: 255/255.0, alpha: 1)
    self.endDateTextField.backgroundColor = UIColor.clearColor()
    self.datePicker.minimumDate = NSDate(timeIntervalSinceNow: -86400 * 7)
    self.datePicker.maximumDate = NSDate()
    self.datePickerView.hidden = false
  }
  
  @IBAction func calculateSteps(sender: AnyObject) {
    if (self.readyForCalulation()) {
      PedometerManager.sharedInstance.calculateStepsForInterval(startDate:self.startDate!, endDate: self.endDate!) { (activity, error) -> Void in
        self.previousDayResultContainer.updateResultWithActiviy(activity!)
        self.datePickerView.hidden = true
      }
    }
  }
  
  @IBAction func didChangeSegment(sender: UISegmentedControl) {
    switch(sender.selectedSegmentIndex){
    case 0:
      self.todayUpdatesView.hidden = false
      self.previousUpdatesView.hidden = true
    case 1:
      self.todayUpdatesView.hidden = true
      self.previousUpdatesView.hidden = false
    default:
      self.todayUpdatesView.hidden = false
      self.previousUpdatesView.hidden = false
    }
  }
  
  @IBAction func didTapPickerClose(sender: AnyObject) {
    self.datePickerView.hidden = true
  }
  
  //MARK: Touch Handlers
  
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    let touch = touches.first as? UITouch
    var point = touch?.locationInView(self.view)
    if (CGRectContainsPoint(self.datePickerView.frame, point!) == false) {
      datePickerView.hidden = true //Hide datepicker when tapped outside of date picker
    }
  }
  
  //MARK:Private Helpers
  
  //Check for condition before calculating steps
  func readyForCalulation() -> Bool {
    var shouldCalculateNow = true
    
    if (self.startDate == nil ||  self.endDate == nil) {
      self.showAlertWithMessage("Please choose start and end date.")
      shouldCalculateNow = false
    }
    else if (self.startDate?.compare(self.endDate!) == NSComparisonResult.OrderedDescending) {
      self.showAlertWithMessage("End date should be later than start date.")
      shouldCalculateNow = false
    }
    else if (!PedometerManager.sharedInstance.checkStepCountingAvailability()) {
      self.showAlertWithMessage("Step Counting Not Avaliable.")
      shouldCalculateNow = false
    }else if (!PedometerManager.sharedInstance.checkFloorCountingAvailability()) {
      self.showAlertWithMessage("Floor Counting Not Avaliable.")
      shouldCalculateNow = true
    }
    return shouldCalculateNow
  }
  
  //Shows alert with custom messages
  func showAlertWithMessage(message:String!)->() {
    var	alertController = UIAlertController(title: "Error", message:message, preferredStyle: UIAlertControllerStyle.Alert)
    var action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
    alertController.addAction(action)
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  //Update imageView and status label according to the user's motion actvity
  func setUpActivity() {
    
    if(CMMotionActivityManager.isActivityAvailable()) {
      self.activityManager.startActivityUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data: CMMotionActivity!)  in
        dispatch_async(dispatch_get_main_queue(), { ()  in
          
          if(data.stationary == true) {
            self.activityStatusLabel.text = "Stationary"
            self.footImageView.image = UIImage(named: "stationary.png")
          }
          else if (data.walking == true){
            self.activityStatusLabel.text = "Walking"
            self.footImageView.image = UIImage(named: "Walking Man.jpg")
          }
          else if (data.running == true){
            self.activityStatusLabel.text = "Running"
            self.footImageView.image = UIImage(named: "running_man.png")
          }
          
        })
        MBUtility.changeViewToCircle(self.footImageView.layer, bordorWidth: 3.0, cornerRadius: self.footImageView.frame.size.height / 2, borderColor: UIColor(red: 219.0/255.0, green: 182.0/255.0, blue: 72.0/255.0, alpha: 1.0))
        
      })
    }
  }
  
  //Format date string to be displayed on labels
  func formatDate(date:NSDate)->(String!) {
    var dataFormatter:NSDateFormatter? = NSDateFormatter()
    dataFormatter?.dateFormat = "MM'/'dd'/'yyyy HH:mm"
    
    var formattedDate:String? = dataFormatter!.stringFromDate(date)
    return formattedDate
  }
  
  //Calculates midnight of today
  
  func midnightOfToday(date:NSDate) -> (NSDate) {
    let cal = NSCalendar.currentCalendar()
    let comps = cal.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: NSDate())
    
    comps.hour = 0
    comps.minute = 0
    comps.second = 0
    let timeZone = NSTimeZone.systemTimeZone()
    cal.timeZone = timeZone
    
    return cal.dateFromComponents(comps)!
  }

}

