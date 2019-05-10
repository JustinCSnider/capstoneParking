//
//  FirebaseController.swift
//  capstoneParking
//
//  Created by Justin Snider on 3/24/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirebaseController {
    
    static var shared = FirebaseController()
    
    func createAccount(firstName: String, lastName: String, email: String, password: String) {
        //Adds account to the database
        Firestore.firestore().collection("Users").document(email).setData([
            "firstName" : firstName,
            "lastName" : lastName,
            "email" : email,
            "password" : password,
            "reservations" : [],
            "registeredSpots" : []
            ])
    }
    
    func fetchUser(for email: String, completion: ((User?) -> Void)? = nil) {
        //Graps password that comes along with the user email
        Firestore.firestore().collection("Users").whereField("email", isEqualTo: email).getDocuments { (snapshot, error) in
            if let data = snapshot?.documents.first?.data(),
               let firstName = data["firstName"] as? String,
               let lastName = data["lastName"] as? String,
               let email = data["email"] as? String,
               let password = data["password"] as? String,
               let reservationsData = data["reservations"] as? [String : [String : Any]],
               let registeredSpotsData = data["registeredSpots"] as? [String : [String : Any]] {
                
                var reservations: [RegisteredSpot] = []
                var registeredSpots: [RegisteredSpot] = []
                
                for i in reservationsData {
                    let currentReservation = i.value
                    
                    if let imageURL = currentReservation["imageURLString"] as? String,
                       let address = currentReservation["address"] as? String,
                       let availableHours = currentReservation["availableHours"] as? [String : [String]],
                       let numberOfSpaces = currentReservation["numberOfSpaces"] as? Int,
                       let parkingInstructions = currentReservation["parkingInstructions"] as? String,
                       let rate = currentReservation["rate"] as? Double {
                        let reservation = RegisteredSpot(imageURLString: imageURL, address: address, numberOfSpaces: numberOfSpaces, rate: rate, parkingInstructions: parkingInstructions, availableHours: availableHours, coordinates: nil)
                        
                        reservations.append(reservation)
                    }
                }
                
                for i in registeredSpotsData {
                    let currentSpot = i.value
                    
                    if let imageURL = currentSpot["imageURLString"] as? String,
                       let address = currentSpot["address"] as? String,
                    let availableHours = currentSpot["availableHours"] as? [String : [String]],
                       let numberOfSpaces = currentSpot["numberOfSpaces"] as? Int,
                       let parkingInstructions = currentSpot["parkingInstructions"] as? String,
                       let rate = currentSpot["rate"] as? Double {
                        let registeredSpot = RegisteredSpot(imageURLString: imageURL, address: address, numberOfSpaces: numberOfSpaces, rate: rate, parkingInstructions: parkingInstructions, availableHours: availableHours, coordinates: nil)
                        
                        registeredSpots.append(registeredSpot)
                    }
                }

                if let completion = completion {
                    let currentUser = User(firstName: firstName, lastName: lastName, email: email, password: password, registeredSpots: registeredSpots, reservations: [])
                    completion(currentUser)
                }
            } else {
                if let completion = completion {
                    completion(nil)
                }
            }
        }
    }
    
    func updateCurrentUser() {
        guard let currentUser = ParkingController.shared.getCurrentUser() else { return }
        
        var registeredSpots: [String : [String : Any]] = [:]
        var reservations: [String : Any] = [:]
        
        for i in currentUser.registeredSpots {
            registeredSpots[i.address] = [
                "address" : i.address,
                "imageURLString" : i.imageURLString,
                "numberOfSpaces" : i.numberOfSpaces,
                "rate" : i.rate,
                "parkingInstructions" : i.parkingInstructions,
                "availableHours" : i.availableHours
            ]
            
            Firestore.firestore().collection("RegisteredSpots").document(i.address).setData([
                "address" : i.address,
                "imageURLString" : i.imageURLString,
                "numberOfSpaces" : i.numberOfSpaces,
                "rate" : i.rate,
                "parkingInstructions" : i.parkingInstructions,
                "availableHours" : i.availableHours
                ])
        }
        
        for i in currentUser.reservations {
            reservations[i.reservationID] = [
                "time" : i.time,
                "reservationID" : i.reservationID,
                "reservedSpot" : [
                    "address" : i.reservedSpot.address,
                    "imageURLString" : i.reservedSpot.imageURLString,
                    "numberOfSpaces" : i.reservedSpot.numberOfSpaces,
                    "rate" : i.reservedSpot.rate,
                    "parkingInstructions" : i.reservedSpot.parkingInstructions,
                    "availableHours" : i.reservedSpot.availableHours
                ]
            ]
        }
        
        Firestore.firestore().collection("Users").document(currentUser.email).setData([
            "firstName" : currentUser.firstName,
            "lastName" : currentUser.lastName,
            "email" : currentUser.email,
            "password" : currentUser.password,
            "reservations" : reservations,
            "registeredSpots" : registeredSpots
            ])
    }
    
    func checkIfEmailHasBeenUsed(email: String, completion: @escaping (Bool) -> Void) {
        //Used to check if a specific email has been used to create an account
        Firestore.firestore().collection("Users").whereField("email", isEqualTo: email).getDocuments { (snapshot, error) in
            if let snapshot = snapshot, snapshot.documents.count > 0 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func getRegisteredSpots(completion: @escaping ([RegisteredSpot]) -> Void) {
        Firestore.firestore().collection("RegisteredSpots").getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            
            var registeredSpots: [RegisteredSpot] = []
            
            for i in snapshot.documents {
                let currentSpot = i.data()
                
                if let imageURL = currentSpot["imageURLString"] as? String,
                    let address = currentSpot["address"] as? String,
                    let availableHours = currentSpot["availableHours"] as? [String : [String]],
                    let numberOfSpaces = currentSpot["numberOfSpaces"] as? Int,
                    let parkingInstructions = currentSpot["parkingInstructions"] as? String,
                    let rate = currentSpot["rate"] as? Double {
                    
                    let registeredSpot = RegisteredSpot(imageURLString: imageURL, address: address, numberOfSpaces: numberOfSpaces, rate: rate, parkingInstructions: parkingInstructions, availableHours: availableHours, coordinates: nil)
                    
                    registeredSpots.append(registeredSpot)
                }
            }
            completion(registeredSpots)
        }
    }
    
    func addImageToStorage(image: UIImage) {
        let storageRef = Storage.storage().reference().child("myImage.png")
        
        guard let uploadData = image.pngData() else { return }
        
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            
            if error != nil {
                return
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil {
                    return
                } else if let url = url {
                    ParkingController.shared.setCurrentRegisteredSpotImageURL(url)
                }
            })
        }
    }
}
