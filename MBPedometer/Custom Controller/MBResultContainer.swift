//
//  MBResultContainer.swift
//  MBPedometer
//
//  Created by Ashutosh on 22/06/15.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import UIKit

public class MBResultContainer: UIView {
	
	var resultView: MBResultView!
	
	required public init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.resultView = NSBundle.mainBundle().loadNibNamed("MBResultView", owner: self, options: nil)[0] as? MBResultView
		self.addSubview(self.resultView!)
		self.resultView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
	}
	
	public func updateResultWithActiviy(activity:Activity) {
		var distanceString = String(format: "%.2f mtr", activity.distanceCovered.floatValue)
		self.resultView.updateView(distanceString,stepCount:  activity.stepCount.stringValue,
										ascendedFloorsCount: activity.floorsAscended.stringValue,
									   descendedFloorsCount: activity.floorsDescended.stringValue)
		}
	
}
