//
//  DateCollectionViewCell.swift
//  capstoneParking
//
//  Created by Justin Snider on 4/29/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

class DateCollectionViewCell: UICollectionViewCell {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    var delegate: calendarDelegate?
    
    //========================================
    //MARK: - IBOutlets
    //========================================
    
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var circleView: UIView!
    
    //========================================
    //MARK: - IBActions
    //========================================
    
    @IBAction func dateButtonTapped(_ sender: UIButton) {
        delegate?.dateTapped(sender: self)
    }
    
    //========================================
    //MARK: - Helper Methods
    //========================================
    
    func drawCircle() {
        
        let circleCenter = circleView.center
        
        let circlePath = UIBezierPath(arcCenter: circleCenter, radius: (circleView.bounds.width/2 - 5), startAngle: -CGFloat.pi/2, endAngle: (2 * CGFloat.pi), clockwise: true)
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.strokeColor = UIColor.black.cgColor
        circleLayer.lineWidth = 2
        circleLayer.strokeEnd = 0
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = CAShapeLayerLineCap.round
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1
        animation.toValue = 1
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        
        circleLayer.add(animation, forKey: nil)
        circleView.layer.addSublayer(circleLayer)
        circleView.layer.backgroundColor = UIColor.clear.cgColor
    }
    
}
