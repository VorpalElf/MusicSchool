//
//  SettingsNameView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 31/7/25.
//

import SwiftUI

struct SettingsNameView: View {
    @ObservedObject private var SetModel = SettingsViewModel()
    @State private var originFirst: String = ""
    @State private var originLast: String = ""
    @State private var newFirst: String = ""
    @State private var newLast: String = ""
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
            
            TextField(originFirst, text: $newFirst)
                .autocorrectionDisabled()
                .textContentType(.givenName)
            
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .focused($isFocused)
            
            TextField(originLast, text: $newLast)
                .autocorrectionDisabled()
                .textContentType(.familyName)
            
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .focused($isFocused)
            
            NavigationLink(destination: MainMenuView(), isActive: $changed) {
                Button("Save") {
                    Task {
                        (changed, showAlert, alertTitle, alertMessage) = try await SetModel.changeName(oldFirst: originFirst, oldLast: originLast, newFirst: newFirst, newLast: newLast)
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
        .onAppear() {
            Task {
                (originFirst, originLast) = try await SetModel.fetchName()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    SettingsNameView()
}
