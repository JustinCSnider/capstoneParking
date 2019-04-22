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
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //========================================
    //MARK: - Navigation
    //========================================

    
    @IBAction func barButtonTapped(_ sender: UIBarButtonItem) {
        delegate?.navigationButtonTapped(sender: sender)
        dismiss(animated: true, completion: nil)
    }
    
    
}
