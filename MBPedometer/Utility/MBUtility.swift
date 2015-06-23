//
//  MBUtility.swift
//  MBPedometer
//
//  Created by Ashutosh on 23/06/15.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import UIKit
import Foundation

class MBUtility: NSObject {
    
    class func changeViewToCircle(layer: CALayer, bordorWidth: CGFloat, cornerRadius: CGFloat, borderColor: UIColor?) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        layer.borderWidth = bordorWidth
        layer.borderColor = borderColor?.CGColor
    }
}
