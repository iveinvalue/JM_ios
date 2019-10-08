//
//  ViewRotate.swift
//  music2
//
//  Created by USER on 07/10/2019.
//  Copyright © 2019 User. All rights reserved.
//

import Foundation
import UIKit

let kRotationAnimationKey = "com.myapplication.rotationanimationkey"

func rotateView(view: UIView, duration: Double = 10) {
    if view.layer.animation(forKey: kRotationAnimationKey) == nil {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Float(Double.pi * 2.0)
        rotationAnimation.duration = duration
        rotationAnimation.repeatCount = Float.infinity
        
        view.layer.add(rotationAnimation, forKey: kRotationAnimationKey)
    }
}
