//
//  SettingsViewModel.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 31/7/25.
//

import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class SettingsViewModel: ObservableObject {
    private let db = Firestore.firestore()
    
    // Fetch Name Function
    func fetchName() async throws -> (String, String) {
        guard let user = Auth.auth().currentUser else {
            return ("Error", "Error")
        }
        
        let uid = user.uid
        let usersRef = db.collection("Users").document(uid)
        
        do {
            let document = try await usersRef.getDocument()
            if document.exists {
                if let storedFirst = document.data()?["firstName"] as? String, let storedLast = document.data()?["lastName"] as? String {
                    return (storedFirst, storedLast)
                } else {
                    return ("Error", "Error")
                }
            } else {
                return ("Error", "Error")
            }
        } catch {
            return ("Error", "Error")
        }
    }
    
    func changeName(oldFirst: String, oldLast: String, newFirst: String, newLast: String) async throws -> (Bool, Bool, String, String) {
        // return (changed, showAlert, title, alertMessage)
        if oldFirst == newFirst && oldLast == newLast {
            return (false, true, "Error","Name is identical. No changes made")
        }
        
        if newFirst.isEmpty && newLast.isEmpty {
            return (false, true, "Error", "No Name Inputted. No changes made")
        }
        
        guard let user = Auth.auth().currentUser else {
            return (false, true, "Error", "Error to find user")
        }
        
        let uid = user.uid
        let usersRef = db.collection("Users").document(uid)
        
        do {
            // Change First Name Field
            if !newFirst.isEmpty{
                if newFirst.count < 2 {
                    return (false, true, "Error", "Name must be at least 2 characters long.")
                }
                try await usersRef.setData(["firstName": newFirst], merge: true)
            }
            
            // Change Last Name Field
            if !newLast.isEmpty{
                if newLast.count < 2 {
                    return (false, true, "Error", "Name must be at least 2 characters long.")
                }
                try await usersRef.setData(["lastName": newLast], merge: true)
            }
            return (true, false, "Success", "New Names Applied")
        } catch {
            return (false, true, "Error", error.localizedDescription)
        }
    }
    
    func changeEmail(oldEmail: String, newEmail: String, password: String) async throws -> (Bool, Bool, String, String) {
        // Field Test
        if oldEmail == newEmail {
            return (false, true, "Error", "Email is identical. No changes made")
        }
        
        if newEmail.isEmpty || password.isEmpty || oldEmail.isEmpty {
            return (false, true, "Error", "Not All Fields Inputted. No changes made")
        }
        
        // Check is it the current user
        guard let currentUser = Auth.auth().currentUser else {
                return (false, true, "Error", "No user signed in.")
            }
        let userEmail = currentUser.email
        if oldEmail != userEmail {
            return (false, true, "Error", "You are not the current user. No changes made")
        }
        
        do {
            // Reauthenticate
            try await Auth.auth().signIn(withEmail: oldEmail, password: password)
            
            // Update Email
            try await currentUser.sendEmailVerification(beforeUpdatingEmail: newEmail)
            return (true, true, "Success", "If your new email is not occupied, a verification link will be sent shortly. \nPlease confirm your email and sign in again")
        } catch {
            return (false, true, "Error", error.localizedDescription)
        }
    }
    
    func changePassword(oldPassword: String, newPassword: String, email: String) async throws -> (Bool, Bool, String, String) {
        // Field Test
        if oldPassword == newPassword {
            return (false, true, "Error", "Password is identical. No changes made")
        }
        
        if newPassword.isEmpty || email.isEmpty || oldPassword.isEmpty {
            return (false, true, "Error", "Not All Fields Inputted. No changes made")
        }
        
        if newPassword.count < 6 {
            return (false, true, "Error", "Minimum password length is 6, please reenter your password.")
        }
        
        // Check User Session
        guard let currentUser = Auth.auth().currentUser else {
                return (false, true, "Error", "No user signed in.")
            }
        let userEmail = currentUser.email
        if email != userEmail {
            return (false, true, "Error", "You are not the current user. No changes made")
        }
        
        do {
            // Reauthenticate
            try await Auth.auth().signIn(withEmail: email, password: oldPassword)
            
            // Update Password
            try await currentUser.updatePassword(to: newPassword)
            return (true, true, "Success", "Password updated! Please sign in again")
        } catch {
            return (false, true, "Error", error.localizedDescription)
        }
    }
}
