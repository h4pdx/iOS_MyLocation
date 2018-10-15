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
        hudView.show(animated: animated)
        return hudView
    }
    
    
    // draw a square with rounded corners (done - HUD view)
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        // create box image object
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
        // load checkmark into a UIImage object
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(
                x: center.x - round(image.size.width / 2),
                y: center.y - round(image.size.height / 2) - boxHeight / 8)
            image.draw(at: imagePoint)
        }
        // Draw the text
        // set up dictionary of attributes for the text to display
        let attributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        // calculate how wide and tall the text will be
        let textSize = text.size(withAttributes: attributes)
        // calculate where to draw the text
        let textPoint = CGPoint(
            x: center.x - round(textSize.width / 2),
            y: center.y - round(textSize.height / 2) + boxHeight / 4)
        
        text.draw(at: textPoint, withAttributes: attributes)
    }
    
    // MARK:- Public Methods
    
    // animate the checkmark appearing
    func show(animated: Bool) {
        if animated {
            // set up the initial state of the view before the animation starts
            alpha = 0 // fully transparent
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3) // view is scaled up slightly
            // spring animation
            UIView.animate(withDuration: 0.4,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5,
                           options: [],
                           animations: {
                // set up view as it should be after animation completes
                self.alpha = 1 // fully opaque
                self.transform = CGAffineTransform.identity // restore scale back to normal
            })
        }
    }
    
    func hide() {
        superview?.isUserInteractionEnabled = true
        removeFromSuperview()
    }
    
}
