//
//  UserController.swift
//  capstoneParking
//
//  Created by Justin Snider on 4/2/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

class UserController {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    static var shared = UserController()
    
    private var currentUser: User?
    private var currentRegisteredSpotImageURL: URL?
    var lastRegisteredSpot: RegisteredSpot?
    
    private var currentUserRegisteredSpotImages: [UIImage] = []
    private var currentUserReservedSpotImages: [UIImage] = []
    
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
    func addRegisteredSpot(_ spot: RegisteredSpot, completion: () -> Void) {
        currentUser?.registeredSpots.append(spot)
        if let imageURL = URL(string: spot.imageURLString) {
            fetchImage(url: imageURL) { (image) in
                guard let image = image else { return }
                self.currentUserRegisteredSpotImages.append(image)
            }
        }
        completion()
    }
    
    func replaceRegisteredSpot(with registeredSpot: RegisteredSpot) {
        if currentUser != nil {
            for i in 0...currentUser!.registeredSpots.count - 1 {
                if currentUser!.registeredSpots[i].address == registeredSpot.address {
                    currentUser!.registeredSpots[i] = registeredSpot
                }
            }
        }
    }
    
    func removeRegisteredSpot(_ registeredSpot: RegisteredSpot) {
        if currentUser != nil {
            for i in 0...currentUser!.registeredSpots.count - 1 {
                if currentUser!.registeredSpots[i].address == registeredSpot.address {
                    currentUser!.registeredSpots.remove(at: i)
                    return
                }
            }
        }
    }
    
    func getRegisteredSpotImages() -> [UIImage] {
        return currentUserRegisteredSpotImages
    }
    
    func setRegisteredSpotImages(completion: () -> Void) {
        guard let currentUser = currentUser else { return }
        for i in currentUser.registeredSpots {
            let group = DispatchGroup()
            if let imageURL = URL(string: i.imageURLString) {
                group.enter()
                fetchImage(url: imageURL) { (image) in
                    guard let image = image else { return }
                    self.currentUserRegisteredSpotImages.append(image)
                    group.leave()
                }
                group.wait()
            }
        }
        completion()
    }
    
    func addRegisteredSpotImage(_ image: UIImage) {
        self.currentUserRegisteredSpotImages.append(image)
    }
    
    func getCurrentRegisteredSpotImageURL() -> URL? {
        return currentRegisteredSpotImageURL
    }
    
    func setCurrentRegisteredSpotImageURL(_ url: URL) {
        currentRegisteredSpotImageURL = url
    }
    
    
    //Reserved Spots
    func addReseravtion(_ reservation: Reservation, completion: () -> Void) {
        currentUser?.reservations.append(reservation)
        
        if let imageURL = URL(string: reservation.reservedSpot.imageURLString) {
            fetchImage(url: imageURL) { (image) in
                guard let image = image else { return }
                self.currentUserReservedSpotImages.append(image)
            }
        }
        completion()
    }
    
    func getReservedSpotImages() -> [UIImage] {
        return currentUserReservedSpotImages
    }
    
    func setReservedSpotImages(completion: () -> Void) {
        guard let currentUser = currentUser else { return }
        for i in currentUser.reservations {
            let group = DispatchGroup()
            if let imageURL = URL(string: i.reservedSpot.imageURLString) {
                group.enter()
                fetchImage(url: imageURL) { (image) in
                    guard let image = image else { return }
                    self.currentUserReservedSpotImages.append(image)
                    group.leave()
                }
                group.wait()
            }
        }
        completion()
    }
    
    func removeReserervedSpot(_ reservation: Reservation) {
        if currentUser != nil {
            for i in 0...currentUser!.reservations.count - 1 {
                if currentUser!.reservations[i].reservationID == reservation.reservationID {
                    currentUser!.reservations.remove(at: i)
                    return
                }
            }
        }
    }
    
    func addReservedSpotImage(_ image: UIImage) {
        self.currentUserReservedSpotImages.append(image)
    }
}
