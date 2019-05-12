//
//  RegisteredSpot.swift
//  capstoneParking
//
//  Created by Justin Snider on 3/22/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit
import CoreLocation

struct RegisteredSpot {
    var imageURLString: String
    var address: String
    var numberOfSpaces: Int
    var rate: Double
    var parkingInstructions: String
    var availableHours: [String : [String]]
    var coordinates: CLLocationCoordinate2D?
}
