//
//  SettingsEmailView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 3/8/25.
//

import SwiftUI

struct SettingsEmailView: View {
    @ObservedObject private var SetModel = SettingsViewModel()
    @State private var originEmail: String = ""
    @State private var password: String = ""
    @State private var newEmail: String = ""
    @State private var changed: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            Text("Email")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
            
            TextField("Current Email:", text: $originEmail)
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
            
            TextField("New Email:", text: $newEmail)
                .autocorrectionDisabled()
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .textContentType(.emailAddress)
                
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .focused($isFocused)
            
            NavigationLink(destination: LaunchView(), isActive: $changed) {
                Button("Save") {
                    Task {
                        (changed, showAlert, alertTitle, alertMessage) = try await SetModel.changeEmail(oldEmail: originEmail, newEmail: newEmail, password: password)
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
    SettingsEmailView()
}
