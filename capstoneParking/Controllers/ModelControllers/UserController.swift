//
//  UserController.swift
//  capstoneParking
//
//  Created by Justin Snider on 4/2/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import Foundation

class UserController {
    
    static var shared = UserController()
    
    private var currentUser: User?
    
    //========================================
    //MARK: - Getters and Setters
    //========================================
    
    func getCurrentUser() -> User? {
        guard let currentUser = currentUser else { return nil }
        return currentUser
    }
    
    func setCurrentUser(user: User) {
        currentUser = user
    }
}
