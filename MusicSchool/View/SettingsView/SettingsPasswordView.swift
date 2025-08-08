//
//  SettingsPasswordView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 31/7/25.
//

import SwiftUI

struct SettingsPasswordView: View {
    @ObservedObject private var SetModel = SettingsViewModel()
    @State private var email: String = ""
    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var changed: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            Text("Password")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
            
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
            
            SecureField("Current Password:", text: $oldPassword)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .textContentType(.newPassword)
            
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .focused($isFocused)
            
            SecureField("New Password:", text: $newPassword)
                .autocorrectionDisabled()
                .textContentType(.newPassword)
                .autocapitalization(.none)
            
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .focused($isFocused)
            
            NavigationLink(destination: LaunchView(), isActive: $changed) {
                Button("Save") {
                    Task {
                        (changed, showAlert, alertTitle, alertMessage) = try await SetModel.changePassword(oldPassword: oldPassword, newPassword: newPassword, email: email)
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
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    SettingsPasswordView()
}
