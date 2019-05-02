//
//  CustomTextView.swift
//  capstoneParking
//
//  Created by Justin Snider on 4/24/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTextView: UITextView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            clipsToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
}

