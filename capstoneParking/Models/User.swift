//
//  AccountHolder.swift
//  capstoneParking
//
//  Created by Justin Snider on 3/22/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import Foundation

struct User {
    var firstName: String
    var lastName: String
    var email: String
    var password: String
    var registeredSpots: [RegisteredSpot]
    var reservedSpots: [RegisteredSpot]
}
