//
//  DetailViewController.swift
//  capstoneParking
//
//  Created by Justin Snider on 3/22/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

protocol NavigationButtonDelegate {
    func cancelButtonTapped(sender: UIBarButtonItem)
}

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NavigationButtonDelegate {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    var currentTimeButton: UIButton?
    private var availableHours: [String : [String]] = [:]
    
    //========================================
    //MARK: - IBOutlets
    //========================================
    
    @IBOutlet weak var streetAddressTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    
    @IBOutlet weak var spacesTextField: UITextField!
    
    @IBOutlet weak var rateTextField: UITextField!
    
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var fromTimeButton: UIButton!
    @IBOutlet weak var toTimeButton: UIButton!
    
    @IBOutlet weak var spotImageView: UIImageView!
    
    @IBOutlet weak var availableHoursPromptLabel: UILabel!
    @IBOutlet weak var fromTimeLabel: UILabel!
    @IBOutlet weak var toTimeLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var parkingInstructionsTextView: CustomTextView!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var timePickerView: UIView!
    @IBOutlet weak var timePickerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var availableDaysSegmentedControl: UISegmentedControl!
    
    
    //========================================
    //MARK: - IBActions
    //========================================
    
    @IBAction func timeButtonTapped(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        
        if currentTimeButton != sender {
            if currentTimeButton != nil {
                currentTimeButton?.isSelected = false
            }
            currentTimeButton = sender
            
            currentTimeButton?.isSelected = true
            
            if sender == fromTimeButton, let time = dateFormatter.date(from: fromTimeLabel.text ?? "") {
                timePicker.date = time
            } else if sender == toTimeButton, let time = dateFormatter.date(from: toTimeLabel.text ?? "") {
                timePicker.date = time
            }
            
            UIView.animate(withDuration: 0.5) {
                self.timePickerViewHeightConstraint.constant = 216
                self.viewHeightConstraint.constant = 1200
                
                self.view.layoutIfNeeded()
            }
        } else {
            currentTimeButton?.isSelected = false
            
            currentTimeButton = nil
            
            UIView.animate(withDuration: 0.5) {
                self.timePickerViewHeightConstraint.constant = 0
                self.viewHeightConstraint.constant = 1000
                
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func timePickerChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        if currentTimeButton == fromTimeButton {
            fromTimeLabel.text = dateFormatter.string(from: sender.date)
        } else if currentTimeButton == toTimeButton {
            toTimeLabel.text = dateFormatter.string(from: sender.date)
        }
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 3 {
            performSegue(withIdentifier: "availableHoursSegue", sender: sender)
        } else {
            availableHoursPromptLabel.textColor = UIColor.black
            fromLabel.textColor = UIColor.black
            toLabel.textColor = UIColor.black
            fromTimeLabel.textColor = UIColor.black
            toTimeLabel.textColor = UIColor.black
            fromTimeButton.tintColor = UIColor.black
            toTimeButton.tintColor = UIColor.black
            
            fromTimeButton.isEnabled = true
            toTimeButton.isEnabled = true
        }
    }
    
    @IBAction func selectSpotImageView(_ sender: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        if let imageURLString = ParkingController.shared.getCurrentRegisteredSpotImageURL()?.absoluteString,
           let numberOfSpaces = Int(spacesTextField.text ?? ""),
           let rate = Double(rateTextField.text ?? "") {
            let address = "\(streetAddressTextField.text ?? ""), \(cityTextField.text ?? ""), \(stateTextField.text ?? "") \(zipCodeTextField.text ?? "")"
            let parkingInstructions = parkingInstructionsTextView.text ?? ""
            
            let newRegisteredSpot = RegisteredSpot(imageURLString: imageURLString, address: address, numberOfSpaces: numberOfSpaces, rate: rate, parkingInstructions: parkingInstructions, availableHours: availableHours)
            
            ParkingController.shared.addRegisteredSpot(newRegisteredSpot)
            FirebaseController.shared.updateCurrentUser()
        }
    }
    
    //========================================
    //MARK: - Image Picker Delegate Methods
    //========================================
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            spotImageView.image = selectedImage
            
            FirebaseController.shared.addImageToStorage(image: selectedImage)
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //========================================
    //MARK: - Navigation Delegate Methods
    //========================================
    
    func cancelButtonTapped(sender: UIBarButtonItem) {
        availableDaysSegmentedControl.selectedSegmentIndex = 0
    }
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()
        timePickerViewHeightConstraint.constant = 0
        
        timePickerView.clipsToBounds = true
        
        parkingInstructionsTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        viewHeightConstraint.constant = 1000
        
        updateAvailableHours(customAvailableHours: nil)
    }
    
    //========================================
    //MARK: - Navigation
    //========================================
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let destination = segue.destination as? AvailableHoursViewController {
            destination.delegate = self
        }
    }
    
    @IBAction func unwindToDetailViewController(segue: UIStoryboardSegue) {
        availableHoursPromptLabel.textColor = UIColor.lightGray
        fromLabel.textColor = UIColor.lightGray
        toLabel.textColor = UIColor.lightGray
        fromTimeLabel.textColor = UIColor.lightGray
        toTimeLabel.textColor = UIColor.lightGray
        fromTimeButton.tintColor = UIColor.lightGray
        toTimeButton.tintColor = UIColor.lightGray
        
        fromTimeButton.isEnabled = false
        toTimeButton.isEnabled = false
    }
    
    //========================================
    //MARK: - Helper methods
    //========================================
    
    func updateAvailableHours(customAvailableHours: [String : [String]]?) {
        switch availableDaysSegmentedControl.selectedSegmentIndex {
        case 0:
            availableHours = [
                "Monday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Tuesday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Wednesday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Thursday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Friday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Saturday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Sunday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""]
            ]
        case 1:
            availableHours = [
                "Monday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Tuesday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Wednesday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Thursday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Friday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Saturday" : ["Unavailable"],
                "Sunday" : ["Unavailable"]
            ]
        case 2:
            availableHours = [
                "Monday" : ["Unavailable"],
                "Tuesday" : ["Unavailable"],
                "Wednesday" : ["Unavailable"],
                "Thursday" : ["Unavailable"],
                "Friday" : ["Unavailable"],
                "Saturday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Sunday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""]
            ]
        case 3:
            guard let customAvailableHours = customAvailableHours else { return }
            availableHours = customAvailableHours
        default:
            break
        }
    }
    
}
