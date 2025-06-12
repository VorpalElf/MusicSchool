//
//  SignInView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 12/6/25.
//

import SwiftUI

struct SignInView: View {
    // Credentials Variable
    @State private var email: String = ""
    @State private var password: String = ""
    
    // Condition Variable
    @FocusState private var isFocused: Bool
    
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
                
                NavigationLink(destination: MainMenuView()) {
                    Text("Sign In")
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
        }
        .padding()
    }
}

#Preview {
    SignInView()
}
