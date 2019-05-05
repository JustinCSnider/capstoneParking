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
    
    var currentRegisteredSpot: RegisteredSpot?
    var calendarController = CalendarController.shared
    
    //Calendar properties
    var selectedDay = CalendarController.shared.day
    var selectedWeekday = CalendarController.shared.weekday
    var selectedMonth = ""
    var selectedYear = CalendarController.shared.year
    
    //========================================
    //MARK: - IBOutlets
    //========================================
    
    @IBOutlet weak var calendarView: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var parkingTextView: CustomTextView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    
    //========================================
    //MARK: - IBActions
    //========================================
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        calendarController.continueToNextMonth()
        
        calendarController.currentMonth = calendarController.months[calendarController.month]
        monthLabel.text = "\(calendarController.currentMonth) \(calendarController.year)"
        calendarView.reloadData()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        calendarController.continueToPreviousMonth()
        
        calendarController.currentMonth = calendarController.months[calendarController.month]
        monthLabel.text = "\(calendarController.currentMonth) \(calendarController.year)"
        calendarView.reloadData()
    }
    
    @IBAction func reserveButtonTapped(_ sender: UIButton) {
        guard let reservedSpot = currentRegisteredSpot else { return }
        let time = timeLabel.text ?? ""
        let reservationID = UUID().uuidString
        
        let newReservation = Reservation(time: time, reservedSpot: reservedSpot, reservationID: reservationID)
        
        let group = DispatchGroup()
        
        group.enter()
        UserController.shared.addReseravtion(newReservation) { group.leave() }
        group.wait()
        
        FirebaseController.shared.updateCurrentUser()
    }
    
    
    //========================================
    //MARK: - Collection View Data Source and Delegate Methods
    //========================================
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch calendarController.direction {
        case 0:
            return calendarController.daysInMonths[calendarController.month] + calendarController.numberOfEmptyBoxes
        case 1...:
            return calendarController.daysInMonths[calendarController.month] + calendarController.nextNumberOfEmptyBoxes
        case -1:
            return calendarController.daysInMonths[calendarController.month] + calendarController.previousNumberOfEmptyBoxes
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
        
        switch calendarController.direction {
        case 0:
            cell.dateLabel.text = "\(indexPath.row + 1 - calendarController.numberOfEmptyBoxes)"
        case 1...:
            cell.dateLabel.text = "\(indexPath.row + 1 - calendarController.nextNumberOfEmptyBoxes)"
        case -1:
            cell.dateLabel.text = "\(indexPath.row + 1 - calendarController.previousNumberOfEmptyBoxes)"
        default:
            fatalError()
        }
        
        if Int(cell.dateLabel.text!)! < 1 {
            cell.isHidden = true
        }
        
        if calendarController.currentMonth == selectedMonth && calendarController.year == selectedYear && selectedDay == Int(cell.dateLabel.text!)! {
            cell.circleView.isHidden = false
            cell.drawCircle()
        }
        
        cell.drawCircle()
        if let currentMonthIndex = calendarController.months.firstIndex(of: calendarController.currentMonth), let currentDateMonthIndex = calendarController.months.firstIndex(of: calendarController.months[calendarController.calendar.component(.month, from: calendarController.date) - 1]) {
            if Int(cell.dateLabel.text!)! < calendarController.day &&
                currentMonthIndex == currentDateMonthIndex &&
                calendarController.year == calendarController.calendar.component(.year, from: calendarController.date) ||
                currentMonthIndex < currentDateMonthIndex &&
                calendarController.year == calendarController.calendar.component(.year, from: calendarController.date) ||
                calendarController.year < calendarController.calendar.component(.year, from: calendarController.date) {
                
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
        selectedYear = calendarController.year
        selectedMonth = calendarController.currentMonth
    }
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarController.currentMonth = calendarController.months[calendarController.month]
        selectedMonth = calendarController.currentMonth
        
        monthLabel.text = "\(calendarController.currentMonth) \(calendarController.year)"
        if calendarController.weekday == 0 {
            calendarController.weekday = 7
        }
        
        calendarController.getStartDateDayPosition()
        
        if currentRegisteredSpot?.parkingInstructions == "" {
            textViewHeightConstraint.constant = 0
            viewHeightConstraint.constant = 830
        } else {
            parkingTextView.layer.borderColor = UIColor.black.cgColor
            textViewHeightConstraint.constant = 166
            viewHeightConstraint.constant = 980
        }
        
        
    }

}
