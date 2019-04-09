//
//  ParkingTabTableViewController.swift
//  capstoneParking
//
//  Created by Justin Snider on 3/22/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

class ParkingTabTableViewController: UITableViewController {
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    //========================================
    //MARK: - Table View Data Source
    //========================================

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Reservations"
        case 1:
            return "Registered Spots"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            guard let reservations = ParkingController.shared.getCurrentUser()?.reservations else { return CGFloat(70) }
            
            if indexPath.row == 0 && reservations.count < 1 {
                return CGFloat(100)
            }
        default:
            break
        }
        return CGFloat(70)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            guard let reservations = ParkingController.shared.getCurrentUser()?.reservations else { return 1 }
            if reservations.count < 1 {
                return 1
            } else {
                return reservations.count
            }
        case 1:
            guard let registeredSpots = ParkingController.shared.getCurrentUser()?.registeredSpots else { return 0 }
            return registeredSpots.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        guard let currentUser = ParkingController.shared.getCurrentUser() else { return UITableViewCell()}
        
        if indexPath.section == 0 {
            
            if currentUser.reservations.count < 1 {
                cell = UITableViewCell()
                cell.backgroundColor = UIColor.lightGray
                cell.textLabel?.numberOfLines = 0

                cell.textLabel?.text = "If you'd like to make a reservation, tap on any pin you might find in the area you want to reserve."
                cell.textLabel?.textAlignment = .center
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "reservedIdentifier", for: indexPath)
                guard let imageURL = URL(string: currentUser.reservations[indexPath.row].reservedSpot.imageURLString) else { return UITableViewCell() }
                
                ParkingController.shared.fetchImage(url: imageURL) { (image) in
                    guard let image = image else { return }
                    DispatchQueue.main.async {
                        cell.imageView?.image = image
                    }
                }
                
                cell.textLabel?.text = currentUser.reservations[indexPath.row].reservedSpot.address
                cell.detailTextLabel?.text = currentUser.reservations[indexPath.row].time
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "registeredIdentifier", for: indexPath)
            
            guard let imageURL = URL(string: currentUser.registeredSpots[indexPath.row].imageURLString) else { return UITableViewCell() }
            
            ParkingController.shared.fetchImage(url: imageURL) { (image) in
                guard let image = image else { return }
                DispatchQueue.main.async {
                    cell.imageView?.image = image
                }
            }
            
            cell.textLabel?.text = currentUser.registeredSpots[indexPath.row].address
            cell.detailTextLabel?.text = "Number of spaces: \(currentUser.registeredSpots[indexPath.row].numberOfSpaces)"
        }

        // Configure the cell...

        return cell
    }

}
