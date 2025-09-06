//
//  ConViewModel.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 18/8/25.
//

import Foundation
import SwiftUICore
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class ConViewModel: ObservableObject {
    // Attributes
    @ObservedObject private var viewModel = AuthViewModel()
    @Published var conColour: [String: (uid: String, colour: Color)] = [:]  // Storing lessons document
    @Published var celltoUID: [String: String] = [:]                        // [cellKey: documentUid]
    @Published var selectionMode: SelectionMode? = nil
    @Published var selectedCells: Set<String> = []
    
    // MARK: - Constraints
    
    private let db = Firestore.firestore()
    
    // Fetch Constraints Documents from Firebase
    func fetchConDocuments(uid: String) async throws -> (showAlert: Bool, alertMessage: String) {
        // Remove all previous constraints
        conColour.removeAll()
        celltoUID.removeAll()
        selectedCells.removeAll()
        
        do {
            var queryRef: Query
            // Set Query Path
            queryRef = db.collection("Constraints")
                .whereField("userID", isEqualTo: uid)
            
            let querySnapshot = try await queryRef.getDocuments()
            for document in querySnapshot.documents {
                // Set ID
                guard let day = document.get("Day") as? String,
                      let time = document.get("Time") as? String,
                      let status = document.get("Status") as? String else {
                    return (true, "Failed to fetch Document")
                }
                
                // Map Dictionary
                let key = "\(day)_\(time)"
                let documentUID = document.documentID
                celltoUID[key] = documentUID
                
                // Change Colour
                if status == "Avoid" {
                    let colour = Color.red
                    conColour[key] = (documentUID, colour)
                } else if status == "Prefer" {
                    let colour = Color.green
                    conColour[key] = (documentUID, colour)
                }
            }
        } catch {
            return (true, error.localizedDescription)
        }
        print(conColour)
        return (false, "")
    }
    
    // Show Contraints in the Timetable
    func fetchCons(day: String, time: String) -> (String, Color) {
        // Find Constraints in Array -> If no lesson found, return no colour
        let key = "\(day)_\(time)"
        guard let result = conColour[key] else {
            return (key, Color.clear)
        }
        return (key, result.colour)
    }
    
    // MARK: - Apply Constraints
    enum SelectionMode {
        case avoid, prefer, free
    }
    
    func toggleSelection(for key: String) {
        if selectedCells.contains(key) {
            selectedCells.remove(key)
        } else {
            selectedCells.insert(key)
        }
    }
    
    func applyCons(mode: SelectionMode) async throws -> (showAlert: Bool, msg: String) {
        var status: String = ""
        let uid = viewModel.fetchUID()
        
        // Convert mode to string
        if mode == .avoid {
            status = "Avoid"
        } else if mode == .prefer {
            status = "Prefer"
        } else if mode == .free {
            status = "Free"
            for key in selectedCells {
                // Fetch Key
                guard let cellUID = celltoUID[key] else {
                    // No Changes needed
                    return (false, "")
                }
                
                do {
                    // Delete Document
                    let documentRef = db.collection("Constraints").document(cellUID)
                    try await documentRef.delete()
                    
                    // Update Colour
                    conColour.removeValue(forKey: key)
                } catch {
                    return (true, error.localizedDescription)
                }
            }
            
            // Reset list
            selectedCells.removeAll()   // Clear selectedCells array
            selectionMode = nil
            return (false, "")
        } else {
            return (true, "Wrong Status")
        }
        
        // For every selected cells
        for key in selectedCells {
            // Fetch Day and Time
            let parts = key.split(separator: "_")
            let day = String(parts[0])
            let time = String(parts[1])
            
            // Check for keys
            // If key exists
            if celltoUID[key] != nil {
                let cellUID = celltoUID[key]!
                let documentRef = db.collection("Constraints").document(cellUID)
                
                // Update document
                do {
                    try await documentRef.updateData([
                        "Status": status
                    ])
                } catch {
                    return (true, error.localizedDescription)
                }
            } else {
                do {
                    // Add Document
                    let documentRef = try await db.collection("Constraints").addDocument(data: [
                        "Day": day,
                        "Time": time,
                        "Status": status,
                        "userID": uid
                        ])
                    
                    // Change Colour
                    let key = "\(day)_\(time)"  // Create key
                    
                    let cellUID = documentRef.documentID
                    
                    if status == "Avoid" {
                        let colour = Color.red
                        conColour[key] = (cellUID, colour)
                    } else if status == "Prefer" {
                        let colour = Color.green
                        conColour[key] = (cellUID, colour)
                    }
                    
                    print(conColour)
                    
                    // Add to
                    celltoUID[key] = cellUID
                    print(celltoUID)
                    
                } catch {
                    return (true, error.localizedDescription)
                }
            }
        }
        selectedCells.removeAll()   // Clear selectedCells array
        selectionMode = nil
        return (false, "")
    }
    
}
