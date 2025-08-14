//
//  TimetableViewModel.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 12/8/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import SwiftUICore

class TimetableViewModel: ObservableObject {
    // Attributes
    @ObservedObject private var viewModel = AuthViewModel()
    @Published var lessonID: [String: String] = [:]     // Storing lessons document
    @Published var lessonColor: [String: Color] = [:]   // For Attendance Use
    @Published var selectedWeek: Date                   // Storing Selected Date
    
    struct Lesson {
        var name: String
        var color: Color
    }
    
    // MARK: - Date Picker
    init() {
        selectedWeek = Self.weekStart(for: Date())
    }
    
    // Extract Sunday Date
    static func weekStart(for date: Date) -> Date {
        let cal = Calendar.current
        let components = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)  // Extract Sunday Date
        return cal.date(from: components)!
    }
    
    // Return Week Range Text
    func weekRangeString(for weekStart: Date) -> String {
        let cal = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM YYYY"
        let weekEnd = cal.date(byAdding: .day, value: 6, to: weekStart)!
        return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
    }
    
    // MARK: - Firestore
    private let db = Firestore.firestore()
    
    // TODO: Add Attendnace Colour
    func fetchDocument(uid: String) async throws -> (showAlert: Bool, alertMessage: String) {
        
        // Date Format
        let start = selectedWeek
        let end = selectedWeek.addingTimeInterval(60 * 60 * 24 * 6)
        
        do {
            let (isTeacher, _, _) = try await viewModel.checkTeacher()
            var queryRef: Query
            // Set Query Path
            if isTeacher {
                queryRef = db.collection("Lessons")
                    .whereField("Date", isGreaterThanOrEqualTo: start)
                    .whereField("Date", isLessThanOrEqualTo: end)
                    .whereField("teacherID", isEqualTo: uid)
            } else {
                queryRef = db.collection("Lessons")
                    .whereField("Date", isGreaterThanOrEqualTo: start)
                    .whereField("Date", isLessThanOrEqualTo: end)
                    .whereField("studentID", isEqualTo: uid)
            }
            
            // Query Now
            let querySnapshot = try await queryRef.getDocuments()
            for document in querySnapshot.documents {
                // Set ID
                guard let day = document.get("Day") as? String,
                      let time = document.get("Time") as? String else {
                    return (true, "Failed to fetch Document")
                }
                var first = ""
                var last = ""
                
                // Find other name
                if isTeacher {
                    guard let uid = document.get("studentID") as? String else {
                        return (true, "No Other UID found")
                    }
                    (first, last) = try await viewModel.fetchOtherUser(uid: uid)
                } else {
                    guard let uid = document.get("teacherID") as? String else {
                        return (true, "No Other UID found")
                    }
                    (first, last) = try await viewModel.fetchOtherUser(uid: uid)
                }
                
                // Append Array
                let name = "\(first) \(last)"
                lessonID["\(day)_\(time)"] = name
            }
            print(lessonID)
            return (false, "")
            
        } catch {
            return (true, error.localizedDescription)
        }
    }
    
    func fetchLessons(day: String, time: String) -> Lesson {
        // Find Lesson in the array -> If have lesson, change colour
        let key = "\(day)_\(time)"
        guard let result = lessonID[key] else {
            return Lesson(name: "N/A", color: Color(.green))
        }
        return Lesson(name: result, color: Color(.orange))
    }
}
