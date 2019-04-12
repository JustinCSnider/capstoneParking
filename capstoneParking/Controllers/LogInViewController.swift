//
//  ViewController.swift
//  capstoneParking
//
//  Created by Justin Snider on 3/21/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    //========================================
    //MARK: - IBOutlets
    //========================================
    
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    //========================================
    //MARK: - IBActions
    //========================================
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        //Setting up view for loading process
        loadingView.isHidden = false
        loadingActivityIndicator.startAnimating()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        FirebaseController.shared.fetchUser(for: emailTextField.text ?? "") { (currentUser) in
            guard let currentUser = currentUser else {
                //If password is nil stop loading process and show error label
                self.errorLabel.isHidden = false
                self.loadingActivityIndicator.stopAnimating()
                self.loadingView.isHidden = true
                return
            }
            //If the password that was typed in the text field is equal to the fetched password log them in and if not show the error label
            if self.passwordTextField.text == currentUser.password {
                ParkingController.shared.setCurrentUser(user: currentUser)
                self.performSegue(withIdentifier: "loggedInSegue", sender: sender)
            } else {
                self.errorLabel.isHidden = false
            }
            
            //Stop loading process
            self.loadingActivityIndicator.stopAnimating()
            self.loadingView.isHidden = true
        }
    }
    
    //========================================
    //MARK: - Text field delegate methods
    //========================================
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        errorLabel.isHidden = true
        return true
    }
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //Set up border for a specific side on the bottom view
        signUpView.addBorder(side: .Top, thickness: 2, color: UIColor.lightGray)
    }


}


extension UIView {
    
    enum ViewSide {
        case Left, Right, Top, Bottom
    }
    func addBorder(side: ViewSide, thickness: CGFloat, color: UIColor, leftOffset: CGFloat = 0, rightOffset: CGFloat = 0, topOffset: CGFloat = 0, bottomOffset: CGFloat = 0) {
        
        switch side {
        case .Top:
            // Add leftOffset to our X to get start X position.
            // Add topOffset to Y to get start Y position
            // Subtract left offset from width to negate shifting from leftOffset.
            // Subtract rightoffset from width to set end X and Width.
            let border: CALayer = _getOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                                   y: 0 + topOffset,
                                                                   width: self.frame.size.width - leftOffset - rightOffset,
                                                                   height: thickness), color: color)
            self.layer.addSublayer(border)
        case .Right:
            // Subtract the rightOffset from our width + thickness to get our final x position.
            // Add topOffset to our y to get our start y position.
            // Subtract topOffset from our height, so our border doesn't extend past teh view.
            // Subtract bottomOffset from the height to get our end.
            let border: CALayer = _getOneSidedBorder(frame: CGRect(x: self.frame.size.width-thickness-rightOffset,
                                                                   y: 0 + topOffset, width: thickness,
                                                                   height: self.frame.size.height - topOffset - bottomOffset), color: color)
            self.layer.addSublayer(border)
        case .Bottom:
            // Subtract the bottomOffset from the height and the thickness to get our final y position.
            // Add a left offset to our x to get our x position.
            // Minus our rightOffset and negate the leftOffset from the width to get our endpoint for the border.
            let border: CALayer = _getOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                                   y: self.frame.size.height-thickness-bottomOffset,
                                                                   width: self.frame.size.width - leftOffset - rightOffset, height: thickness), color: color)
            self.layer.addSublayer(border)
        case .Left:
            let border: CALayer = _getOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                                   y: 0 + topOffset,
                                                                   width: thickness,
                                                                   height: self.frame.size.height - topOffset - bottomOffset), color: color)
            self.layer.addSublayer(border)
        }
    }
}

fileprivate func _getOneSidedBorder(frame: CGRect, color: UIColor) -> CALayer {
    let border:CALayer = CALayer()
    border.frame = frame
    border.backgroundColor = color.cgColor
    return border
}
