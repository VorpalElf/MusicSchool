//
//  GenViewModel.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 8/9/25.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class GenViewModel: ObservableObject {
    @Published private var classes: [String:[String]] = [:]  // [Duration: Pupil names]
    @Published private var pupilList: [String] = []
    
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
    
    // Toggle Selection
    func toggleSelection(pupil: String) {
        if pupilList.contains(pupil) {
            pupilList.removeAll { $0 == pupil}
        } else {
            pupilList.append(pupil)
        }
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
    
    // Remove Pupil List
    func removePupilList() {
        pupilList.removeAll()
    }
    
    // Check contain user
    func checkContainUser(pupil: String) -> Bool {
        return pupilList.contains(pupil) == true
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
