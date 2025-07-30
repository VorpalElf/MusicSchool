//
//  AuthViewModel.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 19/6/25.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    // Initialise Firebase Database
    private let db = Firestore.firestore()
    
    // Register Teacher Function
    func RegTeacher(first: String, last: String, email: String, password: String, code: String) async throws -> (cond: Bool, title: String, message: String) {
        
        // MARK: Check field completion
        guard !first.isEmpty, !last.isEmpty, !email.isEmpty, !password.isEmpty, !code.isEmpty else {
            return (false, "Error", "Please fill in all fields.")
        }
        if password.count < 6 {
            return (false, "Error", "Minimum password length is 6, please reenter your password.")
        }
        
        // MARK: Check Special Characters
        let special = CharacterSet.letters.inverted
        guard first.rangeOfCharacter(from: special) == nil else {
            return (false, "Error", "Name Contains Non-alphabetical Characters")
        }
        guard last.rangeOfCharacter(from: special) == nil else {
            return (false, "Error", "Name Contains Non-alphabetical Characters")
        }
        
        // MARK: Check length of Name Fields
        if first.count < 2 {
            return (false, "Error", "Name is too Short")
        }
        if last.count < 2 {
            return (false, "Error", "Name is too Short")
        }
        
        // MARK: Query of verification code
        let codeRef = db.collection("verificationCodes").document(code)
        
        do {
            let document = try await codeRef.getDocument()
            if document.exists {
                let storedFirst = document.data()?["firstName"] as? String
                let storedLast = document.data()?["lastName"] as? String
                
                guard storedFirst == first && storedLast == last else {
                    return (false, "Error", "Invalid Code.")
                }
                
            } else {
                return (false, "Error", "Invalid Code")
            }
        } catch {
            return (false, "Error", "Failed to get documents.")
        }
        
        
        // MARK: Add email & password
        do {
            // Check for account exist details
            let querySnapshot = try await db.collection("Users")
                .whereField("firstName", isEqualTo: first)
                .whereField("lastName", isEqualTo: last)
                .getDocuments()
            
            if querySnapshot.documents.count > 0 {
                return (false, "Error", "Account already registered")
            }
            
            let AuthResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = AuthResult.user.uid
            
            
            // MARK: Add user details
            try await self.db.collection("Users").document(uid).setData([
                "firstName": first,
                "lastName": last,
                "Role": "Teacher"
            ])
            return (true, "Success", "Account registered successfully!")
        } catch {
            return (false, "Error", error.localizedDescription)
        }
    }
    
    // Register Student Function
    func RegStudent(first: String, last: String, email: String, password: String) async throws -> (cond: Bool, title: String, message: String) {
        // MARK: Check Empty fields
        guard !first.isEmpty, !last.isEmpty, !email.isEmpty, !password.isEmpty else {
            return (false, "Error", "Please fill in all fields")
        }
        if password.count < 6 {
            return (false, "Error", "Minimum password length is 6, please reenter your password.")
        }
        
        // MARK: Check Special Characters
        let special = CharacterSet.letters.inverted
        guard first.rangeOfCharacter(from: special) == nil else {
            return (false, "Error", "Name Contains Non-alphabetical Characters")
        }
        guard last.rangeOfCharacter(from: special) == nil else {
            return (false, "Error", "Name Contains Non-alphabetical Characters")
        }
        
        // MARK: Check length of Name Fields
        if first.count < 2 {
            return (false, "Error", "Name is too Short")
        }
        if last.count < 2 {
            return (false, "Error", "Name is too Short")
        }
        
        var uid = ""
        
        // MARK: Add email & password
        do {
            // Check for account exist details
            let querySnapshot = try await db.collection("Users")
                .whereField("firstName", isEqualTo: first)
                .whereField("lastName", isEqualTo: last)
                .getDocuments()
            
            if querySnapshot.documents.count > 0 {
                return (false, "Error", "Account already registered")
            }
            
            do {
                let AuthResult = try await Auth.auth().createUser(withEmail: email, password: password)
                uid = AuthResult.user.uid
                guard !uid.isEmpty else {
                    return (false, "Error", "Failed to create user.")
                }
            } catch {
                return (false, "Error", error.localizedDescription)
            }
            
            
            // MARK: Add user details
            try await self.db.collection("Users").document(uid).setData([
                "firstName": first,
                "lastName": last,
                "Role": "Student"
            ])
            return (true, "Success", "Account registered successfully!")
        } catch {
            return (false, "Error", error.localizedDescription)
        }
    }
    
    // Sign In Function
    func SignIn(email: String, password: String) async throws -> (cond: Bool, title: String, message: String) {
        do {
            if email == "" {
                return (true, "Error", "Missing Email")
            }
            
            if password == "" {
                return (true, "Error", "Missing Password")
            }
            
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            return (false, "", "")
        } catch {
            return (true, "Error", error.localizedDescription)
        }
        
    }
    
    // Forgot Password
    func ForgotPassword(email: String) async throws -> (Bool, String, String) {
        // MARK: Check for Empty Fields
        if email.isEmpty {
            return (false, "Error", "Please fill in all fields.")
        }
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            return (true, "Success", "If your address is correct, you should receive an email to reset your password. Don't forget to check your spam mailbox!")
        } catch {
            return (false, "Error", error.localizedDescription)
        }
    }
    
    // Sign Out Function
    func SignOut() -> (Bool, Bool, String){
        do {
            try Auth.auth().signOut()
            return (true, false, "")
        } catch {
            return (false, true, error.localizedDescription)
        }
    }
    
    // TODO: Fetch Username function
    func fetchUsername() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            return "Error"
        }
        
        let uid = user.uid
        let usersRef = db.collection("Users").document(uid)
        
        do {
            let document = try await usersRef.getDocument()
            if document.exists {
                if let storedFirst = document.data()?["firstName"] as? String {
                    return storedFirst
                } else {
                    return "Error"
                }
            } else {
                return "Error"
            }
        } catch {
            return ("Error")
        }
    }
    
}
