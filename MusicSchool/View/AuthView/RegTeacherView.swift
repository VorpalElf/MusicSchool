//
//  RegTeacherView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 12/6/25.
//

import SwiftUI

struct RegTeacherView: View {
    
    // Credentials Variable
    @ObservedObject private var viewModel = AuthViewModel()
    @State private var FirstName: String = ""
    @State private var LastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var code: String = ""
    
    // Condition Variable
    @FocusState private var isFocused: Bool
    @State private var isRegisterd: Bool = false
    
    // Alert
    @State private var showAlert: Bool = false
    @State private var AlertTitle: String = ""
    @State private var AlertMessage: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Teacher Register")
                    .padding()
                    .font(.title)
                    .fontWeight(.bold)
                
                // HStack for First Row
                HStack {
                    TextField("First Name:",text: $FirstName)
                        .autocorrectionDisabled()
                        .textContentType(.givenName)
                    
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .focused($isFocused)
                    
                    TextField("Last Name:", text: $LastName)
                        .autocorrectionDisabled()
                        .textContentType(.familyName)
                    
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .focused($isFocused)
                }
                .padding()
                .padding(.horizontal, 14)
                
                TextField("Email:", text: $email)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
                    .focused($isFocused)
                
                SecureField("Password:", text: $password)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .textContentType(.newPassword)
                
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
                    .focused($isFocused)
                
                TextField("Verification Code:", text: $code)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
                    .focused($isFocused)
                
                //MARK: Register Button
                // TODO: Documentation
                NavigationLink(destination: LaunchView(), isActive: $isRegisterd) {
                    Button("Register") {
                        Task {
                            (isRegisterd, AlertTitle, AlertMessage) = try await viewModel.RegTeacher(first: FirstName, last: LastName, email: email, password: password, code: code)
                            showAlert = true
                        }
                    }
                    .padding()
                    .padding(.horizontal, 13)
                    .background(Color(.green))
                    .foregroundColor(.white)
                    .font(.title2)
                    .fontWeight(.bold)
                    .cornerRadius(8)
                    .frame(width: 180)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(AlertTitle), message: Text(AlertMessage), dismissButton: .default(Text("OK")))
            
        }
    }
}

#Preview {
    RegTeacherView()
}
