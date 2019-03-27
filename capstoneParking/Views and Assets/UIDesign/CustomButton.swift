//
//  CustomButton.swift
//  capstoneParking
//
//  Created by Justin Snider on 3/24/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

@IBDesignable
class CustomButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            clipsToBounds = cornerRadius > 0
        }
    }
}
