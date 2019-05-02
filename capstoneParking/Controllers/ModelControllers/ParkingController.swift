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
    private var currentRegisteredSpotImageURL: URL?
    
    private var defaultRegisteredCellHeight: CGFloat?
    
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
    
    //Current User
    func getCurrentUser() -> User? {
        guard let currentUser = currentUser else { return nil }
        return currentUser
    }
    
    func setCurrentUser(user: User) {
        currentUser = user
    }
    
    //Registered Spots
    func addRegisteredSpot(_ spot: RegisteredSpot) {
        currentUser?.registeredSpots.append(spot)
    }
    
    func getCurrentRegisteredSpotImageURL() -> URL? {
        return currentRegisteredSpotImageURL
    }
    
    func setCurrentRegisteredSpotImageURL(_ url: URL) {
        currentRegisteredSpotImageURL = url
    }
    
    //Reserved Spots
    func addReseravtion(_ reservation: Reservation) {
        currentUser?.reservations.append(reservation)
    }
    
    //Default Registered Cell Height
    func getDefaultRegisteredCellHeight() -> CGFloat? {
        return defaultRegisteredCellHeight
    }
    
    func setDefaultRegisteredCellHeight(_ height: CGFloat) {
        defaultRegisteredCellHeight = height
    }
}
