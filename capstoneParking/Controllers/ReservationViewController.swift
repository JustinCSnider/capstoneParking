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
    
    @IBOutlet weak var reserveButton: CustomButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    //Detail outlets
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var spacesLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var spotImage: UIImageView!
    
    
    //Calendar outlets
    @IBOutlet weak var calendarView: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var parkingTextView: CustomTextView!
    @IBOutlet weak var backButton: UIButton!
    
    //Constraints
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
            calendarController.weekday = ((Int(cell.dateLabel.text!)! + calendarController.numberOfEmptyBoxes - 1) % 7)
        case 1...:
            cell.dateLabel.text = "\(indexPath.row + 1 - calendarController.nextNumberOfEmptyBoxes)"
            calendarController.weekday = ((Int(cell.dateLabel.text!)! + calendarController.nextNumberOfEmptyBoxes - 1) % 7)
        case -1:
            cell.dateLabel.text = "\(indexPath.row + 1 - calendarController.previousNumberOfEmptyBoxes)"
            calendarController.weekday = ((Int(cell.dateLabel.text!)! + calendarController.previousNumberOfEmptyBoxes - 1) % 7)
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
        if let currentMonthIndex = calendarController.months.firstIndex(of: calendarController.currentMonth), let currentDateMonthIndex = calendarController.months.firstIndex(of: calendarController.months[calendarController.calendar.component(.month, from: calendarController.date) - 1]), let currentAvailability = currentRegisteredSpot?.availableHours[calendarController.daysOfMonth[calendarController.weekday]] {
            if Int(cell.dateLabel.text!)! < calendarController.day &&
                currentMonthIndex == currentDateMonthIndex && calendarController.year == calendarController.calendar.component(.year, from: calendarController.date) ||
                currentMonthIndex < currentDateMonthIndex && calendarController.year == calendarController.calendar.component(.year, from: calendarController.date) ||
                calendarController.year < calendarController.calendar.component(.year, from: calendarController.date) ||
                currentAvailability[0] == "Unavailable" {
                
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
        
        selectedWeekday = ((Int(sender.dateLabel.text!)! + calendarController.numberOfEmptyBoxes - 1) % 7)
        
        setTimeLabel()
    }
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentInset.top = -20
        scrollView.contentInset.bottom = contentView.frame.height - reserveButton.frame.minY
        
        guard let currentRegisteredSpot = currentRegisteredSpot else { fatalError() }
        
        
        //Setting up detail info
        if currentRegisteredSpot.parkingInstructions == "" {
            textViewHeightConstraint.constant = 0
            viewHeightConstraint.constant = 830
        } else {
            parkingTextView.layer.borderColor = UIColor.black.cgColor
            textViewHeightConstraint.constant = 166
            viewHeightConstraint.constant = 980
        }
        
        addressLabel.text = "\(currentRegisteredSpot.address)"
        spacesLabel.text = "Spaces: \(currentRegisteredSpot.numberOfSpaces)"
        rateLabel.text = "Rate: \(currentRegisteredSpot.rate)"
        setTimeLabel()
        
        if let imageURL = URL(string: currentRegisteredSpot.imageURLString) {
            let group = DispatchGroup()
            
            group.enter()
            UserController.shared.fetchImage(url: imageURL) { (image) in
                if let image = image {
                    DispatchQueue.main.async {
                        self.spotImage.image = image
                    }
                }
                group.leave()
            }
            group.wait()
        }
        
        
        //Setting up calendar
        calendarController.currentMonth = calendarController.months[calendarController.month]
        selectedMonth = calendarController.currentMonth
        monthLabel.text = "\(calendarController.currentMonth) \(calendarController.year)"
        if calendarController.weekday == 0 {
            calendarController.weekday = 7
        }
        calendarController.getStartDateDayPosition()
    }
    
    //========================================
    //MARK: - Helper Methods
    //========================================
    
    func setTimeLabel() {
        if let currentAvailability = currentRegisteredSpot?.availableHours[calendarController.daysOfMonth[selectedWeekday]] {
            timeLabel.text = "\(currentAvailability[0]) - \(currentAvailability[1])"
            reserveButton.isEnabled = true
            reserveButton.titleLabel?.textColor = UIColor.white
            reserveButton.tintColor = UIColor.blue
        }
    }
    
}
