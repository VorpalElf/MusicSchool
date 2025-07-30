//
//  ForgotPasswordView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 12/6/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @ObservedObject private var viewModel = AuthViewModel()
    @State private var email: String = ""
    @State private var emailSent: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var title: String = ""
    @State private var message: String = ""
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            Text("Forgot Password")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
            
            TextField("Email: ",text: $email)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .focused($isFocused)
            
            NavigationLink(destination: LaunchView(), isActive: $emailSent) {
                Button {
                    Task {
                        (emailSent, title, message) = try await viewModel.ForgotPassword(email: email)
                        showAlert = true
                    }
                } label: {
                    Text("Submit")
                    .padding()
                    .padding(.horizontal, 13)
                    .background(Color(.yellow))
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

#Preview {
    ForgotPasswordView()
}
