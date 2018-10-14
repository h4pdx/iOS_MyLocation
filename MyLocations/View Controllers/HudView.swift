//
//  HudView.swift
//  MyLocations
//
//  Created by Ryan on 10/14/18.
//  Copyright © 2018 fatalerr. All rights reserved.
//

import UIKit

class HudView: UIView {
    var text = ""
    
    // conveniance constructor
    class func hud(inView view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        view.addSubview(hudView) // cover parent view
        view.isUserInteractionEnabled = false // disable user interaction for pop-up hud
        
        //hudView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        
        
        return hudView
    }
    
    
    // draw a square with rounded corners (done - HUD view)
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect(
            x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 2),
            width: boxWidth,
            height: boxHeight
        )
        // draw a rectangle with rounded corner
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill() // fill with opaque grey color
        roundedRect.fill()
    }
}
