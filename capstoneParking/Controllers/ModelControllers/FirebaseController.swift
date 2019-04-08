//
//  FirebaseController.swift
//  capstoneParking
//
//  Created by Justin Snider on 3/24/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FirebaseController {
    
    static var shared = FirebaseController()
    
    func createAccount(firstName: String, lastName: String, email: String, password: String) {
        //Adds account to the database
        Firestore.firestore().collection("Users").addDocument(data: [
            "firstName" : firstName,
            "lastName" : lastName,
            "email" : email,
            "password" : password,
            "reservedSpots" : [[
                "address" : "blah",
                "imageURL" : "",
                "numberOfSpaces" : 0,
                "rate" : 1.9,
                "parkingInstructions" : "",
                "availableHours" : [""]
                ]],
            "registeredSpots" : []
        ]) { (error) in
            if let error = error {
                print(error)
            } else {
                print("Yay we did it")
            }
        }
    }
    
    func fetchUser(for email: String, completion: ((User?) -> Void)? = nil) {
        //Graps password that comes along with the user email
        Firestore.firestore().collection("Users").whereField("email", isEqualTo: email).getDocuments { (snapshot, error) in
            if let data = snapshot?.documents.first?.data(),
               let firstName = data["firstName"] as? String,
               let lastName = data["lastName"] as? String,
               let email = data["email"] as? String,
               let password = data["password"] as? String,
               let reservedSpotsData = data["reservedSpots"] as? [[String : Any]],
               let registeredSpotsData = data["registeredSpots"] as? [[String : Any]] {
                
                var reservedSpots: [RegisteredSpot] = []
                var registeredSpots: [RegisteredSpot] = []
                
                for currentSpot in reservedSpotsData {
                    if let imageURL = currentSpot["imageURL"] as? String,
                       let address = currentSpot["address"] as? String,
                       let availableHours = currentSpot["availableHours"] as? [String],
                       let numberOfSpaces = currentSpot["numberOfSpaces"] as? Int,
                       let parkingInstructions = currentSpot["parkingInstructions"] as? String,
                       let rate = currentSpot["rate"] as? Double {
                        let reservedSpot = RegisteredSpot(imageURL: imageURL, address: address, numberOfSpaces: numberOfSpaces, rate: rate, parkingInstructions: parkingInstructions, availableHours: availableHours)
                        
                        reservedSpots.append(reservedSpot)
                    }
                }
                
                for currentSpot in registeredSpotsData {
                    if let imageURL = currentSpot["imageURL"] as? String,
                       let address = currentSpot["address"] as? String,
                       let availableHours = currentSpot["availableHours"] as? [String],
                       let numberOfSpaces = currentSpot["numberOfSpaces"] as? Int,
                       let parkingInstructions = currentSpot["parkingInstructions"] as? String,
                       let rate = currentSpot["rate"] as? Double {
                       let registeredSpot = RegisteredSpot(imageURL: imageURL, address: address, numberOfSpaces: numberOfSpaces, rate: rate, parkingInstructions: parkingInstructions, availableHours: availableHours)
                        
                        registeredSpots.append(registeredSpot)
                    }
                }

                if let completion = completion {
                    let currentUser = User(firstName: firstName, lastName: lastName, email: email, password: password, registeredSpots: registeredSpots, reservedSpots: reservedSpots)
                    completion(currentUser)
                }
            } else {
                if let completion = completion {
                    completion(nil)
                }
            }
        }
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
}
