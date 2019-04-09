//
//  UserController.swift
//  capstoneParking
//
//  Created by Justin Snider on 4/2/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

class ParkingController {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    static var shared = ParkingController()
    
    private var currentUser: User?
    
    //========================================
    //MARK: - Network Methods
    //========================================
    
    func fetchImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
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
