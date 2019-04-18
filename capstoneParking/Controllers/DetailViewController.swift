//
//  DetailViewController.swift
//  capstoneParking
//
//  Created by Justin Snider on 3/22/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    var currentTimeButton: UIButton?
    //========================================
    //MARK: - IBOutlets
    //========================================
    
    @IBOutlet weak var fromTimeButton: UIButton!
    @IBOutlet weak var toTimeButton: UIButton!
    
    @IBOutlet weak var fromTimeLabel: UILabel!
    @IBOutlet weak var toTimeLabel: UILabel!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var timePickerView: UIView!
    @IBOutlet weak var timePickerViewHeightConstraint: NSLayoutConstraint!
    
    
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
        updateCurrentTimeLabel(date: sender.date)
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
    //MARK: - Helper Methods
    //========================================
    
    func updateCurrentTimeLabel(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        if currentTimeButton == fromTimeButton {
            fromTimeLabel.text = dateFormatter.string(from: date)
        } else if currentTimeButton == toTimeButton {
            toTimeLabel.text = dateFormatter.string(from: date)
        }
    }

}
