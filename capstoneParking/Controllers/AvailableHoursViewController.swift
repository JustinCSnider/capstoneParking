//
//  AvailableHoursViewController.swift
//  capstoneParking
//
//  Created by Justin Snider on 4/22/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

class AvailableHoursViewController: UIViewController {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    var delegate: NavigationButtonDelegate?
    var currentTimeButton: UIButton?
    
    //========================================
    //MARK: - IBOutlets
    //========================================
    
    @IBOutlet weak var fromTimeButton: UIButton!
    @IBOutlet weak var toTimeButton: UIButton!
    
    @IBOutlet weak var fromTimeLabel: UILabel!
    @IBOutlet weak var toTimeLabel: UILabel!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBOutlet weak var firstFourDaySegmentedControl: UISegmentedControl!
    @IBOutlet weak var lastThreeDaySegmentedControl: UISegmentedControl!
    
    
    //Day label outlets
    @IBOutlet weak var mondayFromTimeLabel: UILabel!
    @IBOutlet weak var mondayToTimeLabel: UILabel!
    @IBOutlet weak var tuesdayFromTimeLabel: UILabel!
    @IBOutlet weak var tuesdayToTimeLabel: UILabel!
    @IBOutlet weak var wednesdayFromTimeLabel: UILabel!
    @IBOutlet weak var wednesdayToTimeLabel: UILabel!
    @IBOutlet weak var thursdayFromTimeLabel: UILabel!
    @IBOutlet weak var thursdayToTimeLabel: UILabel!
    @IBOutlet weak var fridayFromTimeLabel: UILabel!
    @IBOutlet weak var fridayToTimeLabel: UILabel!
    @IBOutlet weak var saturdayFromTimeLabel: UILabel!
    @IBOutlet weak var saturdayToTimeLabel: UILabel!
    @IBOutlet weak var sundayFromTimeLabel: UILabel!
    @IBOutlet weak var sundayToTimeLabel: UILabel!
    
    //========================================
    //MARK: - IBActions
    //========================================
    
    @IBAction func timeButtonTapped(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        
        if currentTimeButton != sender {
            currentTimeButton?.isSelected = false
            
            currentTimeButton = sender
            
            currentTimeButton?.isSelected = true
            
            if sender == fromTimeButton, let time = dateFormatter.date(from: fromTimeLabel.text ?? "") {
                timePicker.date = time
            } else if sender == toTimeButton, let time = dateFormatter.date(from: toTimeLabel.text ?? "") {
                timePicker.date = time
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
    
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"

        if let time = dateFormatter.date(from: fromTimeLabel.text ?? "") {
            timePicker.date = time
        }
        
        currentTimeButton = fromTimeButton
    }
    
    //========================================
    //MARK: - Navigation
    //========================================
    
    @IBAction func barButtonTapped(_ sender: UIBarButtonItem) {
        delegate?.navigationButtonTapped(sender: sender)
        dismiss(animated: true, completion: nil)
    }
    
    //========================================
    //MARK: - Helper Methods
    //========================================
    
    
    
}
