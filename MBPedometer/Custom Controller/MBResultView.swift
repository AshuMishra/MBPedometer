//
//  MBResultView.swift
//  MBPedometer
//
//  Created by Ashutosh on 22/06/15.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import UIKit

class MBResultView: UIView {

	@IBOutlet weak var ascendedFloorsLabel: UILabel!
	@IBOutlet weak var descendedFloorsLabel: UILabel!
	@IBOutlet weak var distanceInfoLabel: UILabel!
	@IBOutlet weak var stepCountInfoLabel: UILabel!
	
	func updateView(distance:String, stepCount:String,ascendedFloorsCount:String, descendedFloorsCount:String) {
		self.distanceInfoLabel.text = distance
		self.stepCountInfoLabel.text = stepCount
		self.ascendedFloorsLabel.text = ascendedFloorsCount
		self.descendedFloorsLabel.text = descendedFloorsCount
	}
}
