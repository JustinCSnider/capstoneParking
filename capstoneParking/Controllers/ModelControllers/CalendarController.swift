//
//  CalendarController.swift
//  capstoneParking
//
//  Created by Justin Snider on 5/4/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import Foundation

class CalendarController {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    static var shared = CalendarController(day: Calendar.current.component(.day, from: Date()),
                                           weekday: Calendar.current.component(.weekday, from: Date() - 1),
                                           month: Calendar.current.component(.month, from: Date() - 1),
                                           year: Calendar.current.component(.year, from: Date()))
    
    let date = Date()
    let calendar = Calendar.current
    
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let daysOfMonth = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var daysInMonths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    var currentMonth = ""
    var numberOfEmptyBoxes = 0
    var nextNumberOfEmptyBoxes = 0
    var previousNumberOfEmptyBoxes = 0
    var direction = 0
    var positionIndex = 0
    var leapYearCounter = 1
    var dayCounter = 0
    
    var day = 0
    var weekday = 0
    var month = 0
    var year = 0
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================
    
    init(day: Int, weekday: Int, month: Int, year: Int) {
        self.day = day
        self.weekday = weekday
        self.month = month
        self.year = year
    }
    
    //========================================
    //MARK: - Calendar Functions
    //========================================
    
    func continueToNextMonth() {
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
            
            
        default:
            direction = 1
            
            getStartDateDayPosition()
            
            month += 1
            
        }
    }
    
    func continueToPreviousMonth() {
        switch currentMonth {
        case "January":
            
            direction = -1
            
            month = 11
            year -= 1
            
            if leapYearCounter > 0 {
                leapYearCounter -= 1
            }
            if leapYearCounter == 0 {
                daysInMonths[1] = 29
                leapYearCounter = 4
            } else {
                daysInMonths[1] = 28
            }
            
            getStartDateDayPosition()
            
        default:
            direction = -1
            month -= 1
            
            getStartDateDayPosition()
            
        }
    }
    
    //========================================
    //MARK: - Helper Methods
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
