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
            "password" : password
        ]) { (error) in
            if let error = error {
                print(error)
            } else {
                print("Yay we did it")
            }
        }
    }
    
    func fetchPassword(for email: String, completion: ((String?) -> Void)? = nil) {
        //Graps password that comes along with the user email
        Firestore.firestore().collection("Users").whereField("email", isEqualTo: email).getDocuments { (snapshot, error) in
            if let unwrappedPassword = snapshot?.documents.first?.data()["password"] as? String {
                if let completion = completion {
                    completion(unwrappedPassword)
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
