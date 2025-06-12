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
    
    // Condition Variable
    @FocusState private var isFocused: Bool
    
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
                        .textContentType(.name)
                    
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .focused($isFocused)
                    
                    TextField("Last Name:", text: $LastName)
                        .autocorrectionDisabled()
                        .textContentType(.name)
                    
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
                NavigationLink(destination: LaunchView()) {
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
    }
}

#Preview {
    RegStudentView()
}
