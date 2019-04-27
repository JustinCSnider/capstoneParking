//
//  NewAccountViewController.swift
//  capstoneParking
//
//  Created by Justin Snider on 3/22/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

class CreateNewAccountViewController: UIViewController, UITextFieldDelegate {
    
    //========================================
    //MARK: - IBOutlets
    //========================================
    
    @IBOutlet weak var signInView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var generalErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    //========================================
    //MARK: - IBActions
    //========================================
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        guard let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text else { return }
        
        loadingView.isHidden = false
        loadingActivityIndicator.startAnimating()
        
        if firstName != "" && !firstName.containsNumbers() && lastName != "" && !lastName.containsNumbers() && password != "" && email.isValidEmail() && confirmPasswordTextField.text == password {
            //Resets error labels before checking if it's able to create the account
            resetErrorLabels()
            
            FirebaseController.shared.checkIfEmailHasBeenUsed(email: email) { (hasBeenUsed) in
                self.firstNameTextField.resignFirstResponder()
                self.lastNameTextField.resignFirstResponder()
                self.emailTextField.resignFirstResponder()
                self.passwordTextField.resignFirstResponder()
                self.confirmPasswordTextField.resignFirstResponder()
                
                self.loadingActivityIndicator.stopAnimating()
                self.loadingView.isHidden = true
                if hasBeenUsed {
                    self.emailLabel.isHidden = false
                    self.emailErrorLabel.isHidden = false
                } else {
                    self.emailLabel.isHidden = true
                    self.emailErrorLabel.isHidden = true
                    
                    FirebaseController.shared.createAccount(firstName: firstName, lastName: lastName, email: email, password: password)
                    
                    let currentUser = User(firstName: firstName, lastName: lastName, email: email, password: password, registeredSpots: [], reservations: [])
                    
                    ParkingController.shared.setCurrentUser(user: currentUser)
                    
                    self.performSegue(withIdentifier: "createdAccountSegue", sender: sender)
                }
            }
        } else {
            //Resets error labels before setting them back up again
            resetErrorLabels()
            
            //Checks why the account was unable to be created and sets error labels
            if firstName.containsNumbers() || firstName == "" {
                firstNameLabel.isHidden = false
            }
            if lastName.containsNumbers() || lastName == "" {
                lastNameLabel.isHidden = false
            }
            if !email.isValidEmail() {
                emailLabel.isHidden = false
                emailErrorLabel.isHidden = true
            } else {
                FirebaseController.shared.checkIfEmailHasBeenUsed(email: email) { (hasBeenUsed) in
                    self.firstNameTextField.resignFirstResponder()
                    self.lastNameTextField.resignFirstResponder()
                    self.emailTextField.resignFirstResponder()
                    self.passwordTextField.resignFirstResponder()
                    self.confirmPasswordTextField.resignFirstResponder()
                    
                    self.loadingActivityIndicator.stopAnimating()
                    self.loadingView.isHidden = true
                    
                    if hasBeenUsed {
                        self.emailLabel.isHidden = false
                        self.emailErrorLabel.isHidden = false
                    } else {
                        self.emailLabel.isHidden = true
                        self.emailErrorLabel.isHidden = true
                    }
                }
            }
            if password == "" {
                passwordLabel.isHidden = false
            }
            if confirmPasswordTextField.text != password || confirmPasswordTextField.text == "" {
                confirmPasswordLabel.isHidden = false
            }
            generalErrorLabel.isHidden = false
        }
    }
    
    //========================================
    //MARK: - Text field delegate methods
    //========================================
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Set up border for a specific side on the bottom view
        signInView.addBorder(side: .Top, thickness: 2, color: UIColor.lightGray)
    }
    
    //========================================
    //MARK: - Helper Methods
    //========================================
    
    private func resetErrorLabels() {
        firstNameLabel.isHidden = true
        lastNameLabel.isHidden = true
        emailLabel.isHidden = true
        passwordLabel.isHidden = true
        confirmPasswordLabel.isHidden = true
        generalErrorLabel.isHidden = true
        emailErrorLabel.isHidden = true
    }

}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
            "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func containsNumbers() -> Bool {
        var containsNumbers = false
        var count = 0
        
        while count < 10 {
            if self.contains(String(count)) {
                containsNumbers = true
            }
            count += 1
        }
        
        return containsNumbers
    }
}
