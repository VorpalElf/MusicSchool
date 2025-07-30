//
//  SignInView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 12/6/25.
//

import SwiftUI
import Foundation

struct SignInView: View {
    // View Model
    @StateObject private var viewModel = AuthViewModel()
    
    // Credentials Variable
    @State private var email: String = ""
    @State private var password: String = ""
    
    // Condition Variable
    @FocusState private var isFocused: Bool
    @State private var isCorrect: Bool = false
    
    // Alert variable
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome Back")
                    .padding()
                    .font(.title)
                    .fontWeight(.bold)
                
                TextField("Email:", text: $email)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 14)
                    .focused($isFocused)
                
                SecureField("Password:", text: $password)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .textContentType(.password)
                
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 14)
                    .focused($isFocused)
                
                NavigationLink(destination: MainMenuView(), isActive: $isCorrect) {
                    Button("Sign In") {
                        Task {
                            (showAlert, alertTitle, alertMessage) = try await viewModel.SignIn(email: email, password: password)
                            if showAlert == false {
                                isCorrect = true
                            }
                        }
                    }
                    .padding()
                    .padding(.horizontal, 13)
                    .background(Color(.orange))
                    .foregroundColor(.white)
                    .font(.title2)
                    .fontWeight(.bold)
                    .cornerRadius(8)
                    .frame(width: 180)
                }
                
                NavigationLink(destination: ForgotPasswordView()) {
                    Text("Forgot Password")
                        .padding()
                        .font(.subheadline)
                        .foregroundColor(.indigo)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            
        }
    }
}

#Preview {
    SignInView()
}
