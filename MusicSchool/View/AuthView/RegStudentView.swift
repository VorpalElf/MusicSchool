//
//  RegStudentView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 12/6/25.
//

import SwiftUI

struct RegStudentView: View {
    // Credentials Variab;e
    @State private var FirstName: String = ""
    @State private var LastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isRegistered: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var title: String = ""
    @State private var message: String = ""
    
    @ObservedObject private var viewModel = AuthViewModel()
    
    // Condition Variable
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Student Register")
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
                
                // MARK: Register Button
                NavigationLink(destination: LaunchView(), isActive: $isRegistered) {
                    Button {
                        Task {
                            (isRegistered, title, message) = try await viewModel.RegStudent(first: FirstName, last: LastName, email: email, password: password)
                            showAlert = true
                        }
                    } label: {
                        Text("Register")
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
                Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    RegStudentView()
}
