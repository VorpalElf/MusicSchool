//
//  GenViewModel.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 8/9/25.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class GenViewModel: ObservableObject {
    let AuthView = AuthViewModel()
    let ConView = ConViewModel()
    
    @Published private var classes: [String:[String]] = [:]  // [Duration: Pupil ID]
    @Published private var pupilList: [String] = []
    
    private let db = Firestore.firestore()
    // MARK: - Class List
    // Scan slotGroups list
    func fetchClassList() -> [String] {
        var classList: [String] = []
        
        for (duration, _) in classes {
            classList.append(duration)
        }
        return classList
    }
    
    // Clear class list
    func resetClassList() {
        classes.removeAll()
    }
    
    // Add pupilList to classes List
    func updateClassList(duration: String, oldClassID: String) -> (showAlert: Bool, alertMessage: String) {
        if classes[duration] != nil {
            if oldClassID != duration {
                return (true, "There is another class with the same duration.")
            }
        }
        classes[duration] = pupilList
        return (false, "")
    }
    
    // Update Classes List
    func deleteClass(duration: String) {
        classes.removeValue(forKey: duration)
    }
    
    // MARK: - Pupil List
    // Fetch Pupil List
    func fetchPupilList() -> [String] {
        return pupilList
    }
    
    // Fetch Existing Class Pupil List
    func updatePupilList(classID: String) {
        pupilList = classes[classID] ?? []
    }
    
    // Toggle Selection
    func toggleSelection(uid: String) {
        if pupilList.contains(uid) {
            pupilList.removeAll { $0 == uid}
        } else {
            pupilList.append(uid)
        }
    }
    
    // Remove Pupil List
    func removePupilList() {
        pupilList.removeAll()
    }
    
    // Check contain user
    func checkContainUser(pupil: String) -> Bool {
        return pupilList.contains(pupil) == true
    }
    
    // MARK: - Generate Timetable
    // 1.3 Temporary Lesson List
    var lessonTemp: [[String: Any]] = []     // [[Student, Day, Time]]
    var start: Date = Date.now
    var end: Date = Date.now
    
    func generateTimetable(startDate: Date, endDate: Date) async -> (showAlert: Bool, alertMsg: String) {
        var showAlert = false
        var alertMsg = ""
        start = startDate
        end = endDate
        lessonTemp.removeAll()
        
        // 0. Lock Constraints & Timetable -> Prevent Edit (from other users, current user can edit)
        let currentUID = AuthView.fetchUID()
        
        // 0.1 Check if current user is locked
        let isLocked = await fetchUserLock(uid: currentUID)
        if isLocked {
            return (true, "You are currently locked. Please wait until you are unlocked to generate a timetable.")
        }
        
        // 0.2 Modify userLock
        (showAlert, alertMsg) = await toggleUserLock(uid: currentUID, cond: true)
        
        if showAlert == true {
            return (showAlert, alertMsg)
        }
        
        // MARK: 1. Fetch List & Clean Data
        // 1.1 Fetch Teacher Constraints List
        do {
            (showAlert, alertMsg) = try await ConView.fetchConDocuments(uid: currentUID)
            if showAlert { return (showAlert, alertMsg) }
        }
        catch {
            return (true, error.localizedDescription)
        }
        
        // 1.2 Generate Free Period List, based on Teacher Constraints
        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        let times = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30",
                     "11:00", "11:30", "12:00", "12:30", "13:00", "13:30",
                     "14:00", "14:30", "15:00", "15:30", "16:00"]
        var teacherFree: [String: [String]] = [:] // [Day: [Time]]
        
        for day in days {
            teacherFree[day] = []
            for time in times {
                let (_, colour) = await ConView.fetchCons(day: day, time: time)
                if colour != .red { // Not an 'Avoid' constraint
                    teacherFree[day]?.append(time)
                }
            }
        }
        
        // 1.4 Fetch and Sort Pupils by Constraints
        var classes_new: [String: [(pupilID: String, constraints: [String])]] = [:]
        for (duration, pupilList) in classes {
            var pupilsWithConstraints: [(pupilID: String, constraints: [String])] = []
            for pupil in pupilList {
                let constraints = await ConView.fetchConstraintNumber(uid: pupil)
                pupilsWithConstraints.append((pupilID: pupil, constraints: constraints))
            }
            // Sort pupils: those with more constraints go first
            pupilsWithConstraints.sort { $0.constraints.count > $1.constraints.count }
            classes_new[duration] = pupilsWithConstraints
        }
        
        // 1.5 Check Feasibility
        var periodsRequired = 0
        for (duration, pupilList) in classes {
            periodsRequired += pupilList.count * Int(timeStringToMinutes(duration) / 30)
        }
        
        var periodsAvailable = 0
        for day in days {
            periodsAvailable += teacherFree[day]?.count ?? 0
        }
        
        if periodsRequired > periodsAvailable {
            return (true, "Not Enough Free Periods")
        }
        
        // TODO: Remove this
        print(teacherFree)
        
        // MARK: 2. Weeks Calculation
        let calendar = Calendar.current
        
        // 2.1 Reject Wrong Range
        if startDate > endDate {
            return (true, "Invalid Range")
        }
        
        // 2.2 Reject Weekend Dates
        let startDay = Calendar.current.component(.weekday, from: startDate)
        print(startDay)
        if startDay == 1 || startDay == 7 {
            return (true, "Starting Date is a weekend")
        }
        
        let endDay = Calendar.current.component(.weekday, from: endDate)
        print(endDay)
        if endDay == 1 || endDay == 7 {
            return (true, "Ending Date is a weekend")
        }
        
        // 2.3 Calculate number of weeks for the loop
        guard calendar.range(of: .weekOfYear, in: .year, for: startDate) != nil else {
            return (true, "Could not calculate weeks.")
        }
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startDate))!
        let weeks = calendar.dateComponents([.weekOfYear], from: startOfWeek, to: endDate).weekOfYear ?? 0
        let numWeeks = weeks + 1 // 0-indexed -> 1-indexed
        
        var currentDate = startDate
        
        // MARK: 3. Loop
        // MARK: Loop 1: Weeks
        for weekNum in 0..<numWeeks {
            // Advance Date is Start not
            if weekNum > 0 {
                guard let nextWeekDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate),
                      let startOfNextWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: nextWeekDate)) else {
                    return (true, "Error: Could not calculate the start of the next week.")
                }
                currentDate = startOfNextWeek
            }
            
            // Reset Queue every week
            var weeklyPupilQueues = classes_new
            var weeklyTeacherFreeSlots = teacherFree
            
            // MARK: Loop 2: Days
            for dayIndex in 0..<5 {
                var dateForThisDay: Date
                
                // Date Calculation (for upload)
                if weekNum == 0 {
                    let firstDayOfWeek = (startDay + 5) % 7 // Monday=0, ...
                    guard let calculatedDate = calendar.date(byAdding: .day, value: dayIndex - firstDayOfWeek, to: startDate) else {
                        return (true, "Error: Failed to calculate date within the first week.")
                    }
                    dateForThisDay = calculatedDate
                } else {
                    guard let calculatedDate = calendar.date(byAdding: .day, value: dayIndex, to: currentDate) else {
                        return (true, "Error: Failed to calculate date for the current day.")
                    }
                    dateForThisDay = calculatedDate
                }
                
                // Extra Validation Checks
                if dateForThisDay < startDate || dateForThisDay > endDate { continue }
                
                let weekday = calendar.component(.weekday, from: dateForThisDay)
                if weekday == 1 || weekday == 7 { continue }
                
                let currentDayName = days[weekday - 2]
                
                // MARK: Loop 3: Class Duration
                let sortedDurations = weeklyPupilQueues.keys.sorted { timeStringToMinutes($0) > timeStringToMinutes($1) }
                
                for duration in sortedDurations {
                    guard var pupilQueue = weeklyPupilQueues[duration], !pupilQueue.isEmpty else { continue }
                    
                    let periodsNeeded = Int(timeStringToMinutes(duration) / 30)
                    if periodsNeeded == 0 { continue }
                    
                    guard var daySlots = weeklyTeacherFreeSlots[currentDayName], daySlots.count >= periodsNeeded else { continue }
                    
                    var pupilIndex = 0
                    
                    // MARK: Loop 4: Pupil's Queue
                    while pupilIndex < pupilQueue.count {
                        let pupil = pupilQueue[pupilIndex]
                        var lessonScheduled = false
                        
                        if daySlots.count >= periodsNeeded {
                            for i in 0...(daySlots.count - periodsNeeded) {
                                let potentialTimes = Array(daySlots[i..<(i + periodsNeeded)])
                                let potentialKeys = potentialTimes.map { "\(currentDayName)_\($0)" }
                                
                                // Check for
                                let pupilIsFree = !potentialKeys.contains(where: { pupil.constraints.contains($0) })
                                
                                
                                if pupilIsFree {
                                    guard let lessonTime = potentialTimes.first else {
                                        return (true, "Critical Error: Could not get lesson start time.")
                                    }
                                    // Add Lessons
                                    do {
                                        let (firstName, lastName) = try await AuthView.fetchOtherUser(uid: pupil.pupilID)
                                        let studentName = "\(firstName) \(lastName)"
                                        let lesson: [String : Any] = [
                                            "studentID": pupil.pupilID,
                                            "teacherID": currentUID,
                                            "Date": dateForThisDay,
                                            "Day": currentDayName,
                                            "Times": potentialTimes,
                                            "studentName": studentName
                                        ]
                                        lessonTemp.append(lesson)
                                    }
                                    catch {
                                        return (true, "Failed to Fetch Student's Username")
                                    }
                                    
                                    pupilQueue.remove(at: pupilIndex)
                                    daySlots.removeSubrange(i..<(i + periodsNeeded))
                                    weeklyTeacherFreeSlots[currentDayName] = daySlots
                                    
                                    lessonScheduled = true
                                    break
                                }
                            }
                        }
                        
                        if !lessonScheduled {
                            pupilIndex += 1
                        }
                    }
                    
                    if !pupilQueue.isEmpty {
                        let unscheduledPupils = pupilQueue.map { $0.pupilID }
                        let errorMsg = "Could not schedule the following pupils for duration \(duration): " + unscheduledPupils.joined(separator: ", ")
                        return (true, errorMsg)
                    }
                    
                    weeklyPupilQueues[duration] = pupilQueue
                }
            }
        }
        
        print("--- Generated Timetable ---")
        for lesson in lessonTemp {
            print(lesson)
        }
        print("--------------------------")
        
        
        return (showAlert, alertMsg)
    }
    
    
    // Convert String to Time
    private func timeStringToMinutes(_ timeString: String) -> Double {
        let components = timeString.split(separator: ":")
        guard components.count == 2, let hour = Double(components[0]), let min = Double(components[1]) else { return 0 }
        return (hour * 60) + min
    }
    
    func toggleUserLock(uid: String, cond: Bool) async -> (showAlert: Bool, alertMsg: String) {
        // Fetch Document
        let docRef = db.collection("Users")
        
        do {
            let docSnapshot = try await docRef.getDocuments()
            
            for document in docSnapshot.documents {
                if document.documentID != uid {
                    let localDocRef = db.collection("Users").document(document.documentID)
                    try await localDocRef.updateData(["userLock": cond])
                }
            }
            return (false, "")
        } catch {
            return (true , error.localizedDescription)
        }
    }
    
    func fetchUserLock(uid: String) async -> Bool {
        do {
            let docRef = db.collection("Users").document(uid)
            let document = try await docRef.getDocument()
            
            if document.exists {
                guard let userLock = document.data()?["userLock"] as? Bool else { return true }
                return userLock
            } else {
                return true
            }
        } catch {
            return true
        }
    }
    
    // MARK: - Upload Generated Timetable
    func uploadTimetable() async -> (showAlert: Bool, alertMsg: String) {
        // 4. Upload Timetable
        let uid = AuthView.fetchUID()
        
        // Delete Previous Document
        do {
            let queryRef = try await db.collection("Lessons")
                .whereField("teacherID", isEqualTo: uid)
                .whereField("Date", isLessThanOrEqualTo: end)
                .whereField("Date", isGreaterThanOrEqualTo: start)
                .getDocuments()
            
            for document in queryRef.documents {
                let docID = document.documentID
                try await db.collection("Lessons").document(docID).delete()
            }
        } catch {
            return (true, error.localizedDescription)
        }

        // Iteration
        for lesson in lessonTemp {
            // Fetch Data from Temporary Timetable
            guard let studentID = lesson["studentID"] as? String,
                  let teacherID = lesson["teacherID"] as? String,
                  let date = lesson["Date"] as? Date,
                  let day = lesson["Day"] as? String,
                  let times = lesson["Times"] as? [String] else {
                return (true, "Some values are not correct types")
            }
        
            for time in times {
                let data: [String: Any] = [
                    "studentID": studentID,
                    "teacherID": teacherID,
                    "Date": date,
                    "Day": day,
                    "Time": time
                ]
                do {
                    try await db.collection("Lessons").addDocument(data: data)
                } catch {
                    return (true, error.localizedDescription)
                }
            }
        }
        
        // 5. Unlock Constraints & Timetable
        return await (toggleUserLock(uid: uid, cond: false))
    }
    
    // MARK: - Debug
    // TODO: Remove this
    func printList() {
        print(classes)
    }
    
    func printPupilList() {
        print(pupilList)
    }
    
}
