//
//  ReservationViewController.swift
//  capstoneParking
//
//  Created by Justin Snider on 4/29/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

protocol calendarDelegate {
    func dateTapped(sender: DateCollectionViewCell)
}

class ReservationViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, calendarDelegate {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    let daysOfMonth = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var daysInMonths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    
    var currentMonth = String()
    
    var numberOfEmptyBoxes = Int()
    
    var nextNumberOfEmptyBoxes = Int()
    
    var previousNumberOfEmptyBoxes = Int()
    
    var direction = 0
    
    var positionIndex = 0
    
    var leapYearCounter = 1
    
    var dayCounter = 0
    
    //========================================
    //MARK: - IBOutlets
    //========================================
    
    @IBOutlet weak var calendarView: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    //========================================
    //MARK: - IBActions
    //========================================
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        switch currentMonth {
        case "December":
            direction = 1
            
            month = 0
            year += 1
            
            if leapYearCounter < 5 {
                leapYearCounter += 1
            }
            
            if leapYearCounter == 4 {
                daysInMonths[1] = 29
            }
            
            if leapYearCounter == 5 {
                leapYearCounter = 1
                daysInMonths[1] = 28
            }
            
            getStartDateDayPosition()
            
            currentMonth = months[month]
            monthLabel.text = "\(currentMonth) \(year)"
            calendarView.reloadData()
        default:
            direction = 1
            
            getStartDateDayPosition()
            
            month += 1
            
            currentMonth = months[month]
            monthLabel.text = "\(currentMonth) \(year)"
            calendarView.reloadData()
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        switch currentMonth {
        case "January":
            direction = -1
            
            month = 11
            year -= 1
            
            if leapYearCounter > 0{
                leapYearCounter -= 1
            }
            if leapYearCounter == 0{
                daysInMonths[1] = 29
                leapYearCounter = 4
            }else{
                daysInMonths[1] = 28
            }
            
            getStartDateDayPosition()
            
            currentMonth = months[month]
            monthLabel.text = "\(currentMonth) \(year)"
            calendarView.reloadData()
        default:
            direction = -1
            month -= 1
            
            getStartDateDayPosition()
            
            currentMonth = months[month]
            monthLabel.text = "\(currentMonth) \(year)"
            calendarView.reloadData()
        }
    }
    
    //========================================
    //MARK: - Collection View Data Source and Delegate Methods
    //========================================
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch direction {
        case 0:
            return daysInMonths[month] + numberOfEmptyBoxes
        case 1...:
            return daysInMonths[month] + nextNumberOfEmptyBoxes
        case -1:
            return daysInMonths[month] + previousNumberOfEmptyBoxes
        default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Calendar", for: indexPath) as! DateCollectionViewCell
        
        cell.backgroundColor = UIColor.clear
        
        cell.circleView.isHidden = true
        cell.dateLabel.textColor = UIColor.black
        cell.isUserInteractionEnabled = true
        
        if cell.isHidden {
            cell.isHidden = false
        }
        
        switch direction {
        case 0:
            cell.dateLabel.text = "\(indexPath.row + 1 - numberOfEmptyBoxes)"
        case 1...:
            cell.dateLabel.text = "\(indexPath.row + 1 - nextNumberOfEmptyBoxes)"
        case -1:
            cell.dateLabel.text = "\(indexPath.row + 1 - previousNumberOfEmptyBoxes)"
        default:
            fatalError()
        }
        
        if Int(cell.dateLabel.text!)! < 1 {
            cell.isHidden = true
        }
        
        if currentMonth == selectedMonth && year == selectedYear && selectedDay == Int(cell.dateLabel.text!)! {
            cell.circleView.isHidden = false
            cell.drawCircle()
        }
        
        cell.drawCircle()
        if let currentMonthIndex = months.firstIndex(of: currentMonth), let currentDateMonthIndex = months.firstIndex(of: months[calendar.component(.month, from: date) - 1]) {
            if Int(cell.dateLabel.text!)! < day || currentMonthIndex < currentDateMonthIndex || year < calendar.component(.year, from: date) {
                cell.dateLabel.textColor = UIColor.lightGray
                cell.isUserInteractionEnabled = false
            }
        }
        
        cell.delegate = self
        
        return cell
    }
    
    //========================================
    //MARK: - Calendar Delegate Methods
    //========================================
    
    func dateTapped(sender: DateCollectionViewCell) {
        for currentCell in calendarView.visibleCells {
            guard let currentCell = currentCell as? DateCollectionViewCell else { return }
            
            currentCell.circleView.isHidden = true
        }
        sender.circleView.isHidden = false
        
        selectedDay = Int(sender.dateLabel.text!)!
        selectedYear = year
        selectedMonth = currentMonth
    }
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentMonth = months[month]
        selectedMonth = currentMonth
        
        monthLabel.text = "\(currentMonth) \(year)"
        if weekday == 0 {
            weekday = 7
        }
        getStartDateDayPosition()
    }
    
    
    //========================================
    //MARK: - Helper methods
    //========================================
    
    func getStartDateDayPosition() {
        switch direction {
        case 0:
            numberOfEmptyBoxes = weekday
            dayCounter = day
            while dayCounter > 0 {
                numberOfEmptyBoxes -= 1
                dayCounter -= 1
                if numberOfEmptyBoxes == 0 {
                    numberOfEmptyBoxes = 7
                }
            }
            if numberOfEmptyBoxes == 7 {
                numberOfEmptyBoxes = 0
            }
            positionIndex = numberOfEmptyBoxes
            
        case 1...:
            nextNumberOfEmptyBoxes = (positionIndex + daysInMonths[month]) % 7
            positionIndex = nextNumberOfEmptyBoxes
        case -1:
            previousNumberOfEmptyBoxes = (7 - (daysInMonths[month] - positionIndex) % 7)
            if previousNumberOfEmptyBoxes == 7 {
                previousNumberOfEmptyBoxes = 0
            }
            positionIndex = previousNumberOfEmptyBoxes
            
        default:
            fatalError()
        }
    }

}
