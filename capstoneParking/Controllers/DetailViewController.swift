//
//  DetailViewController.swift
//  capstoneParking
//
//  Created by Justin Snider on 3/22/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

protocol NavigationButtonDelegate {
    func navigationButtonTapped(sender: UIBarButtonItem)
}

class DetailViewController: UIViewController, NavigationButtonDelegate {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    var currentTimeButton: UIButton?
    
    //========================================
    //MARK: - IBOutlets
    //========================================
    
    @IBOutlet weak var fromTimeButton: UIButton!
    @IBOutlet weak var toTimeButton: UIButton!
    
    @IBOutlet weak var availableHoursPromptLabel: UILabel!
    @IBOutlet weak var fromTimeLabel: UILabel!
    @IBOutlet weak var toTimeLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    
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
                
                self.view.layoutIfNeeded()
            }
        } else {
            currentTimeButton?.isSelected = false
            
            currentTimeButton = nil
            
            UIView.animate(withDuration: 0.5) {
                self.timePickerViewHeightConstraint.constant = 0
                
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
    
    //========================================
    //MARK: - Navigation Delegate Methods
    //========================================
    
    func navigationButtonTapped(sender: UIBarButtonItem) {
        if sender.title == "Cancel" {
            availableDaysSegmentedControl.selectedSegmentIndex = 0
        } else if sender.title == "Save" {
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
    }
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()
        timePickerViewHeightConstraint.constant = 0
        
        timePickerView.clipsToBounds = true
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
    
}
