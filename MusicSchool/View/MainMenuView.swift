//
//  MainMenuView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 12/6/25.
//

import SwiftUI

struct MainMenuView: View {
    @ObservedObject private var viewModel = AuthViewModel()
    @State private var signedOut: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var username: String = ""
   
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Welcome " + username)
                        .font(.title)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding()
                
                Spacer ()
                
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            NavigationLink(destination: SettingsMenuView()) {
                Image(systemName: "gear")
                    .foregroundStyle(.blue)
            }
            
            NavigationLink(destination: LaunchView(), isActive: $signedOut) {
                Button {
                    (signedOut, showAlert, alertMessage) = viewModel.SignOut()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
            }
            
        }
        
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            Task {
                username = try await viewModel.fetchUsername()
            }
        }
    }
}

#Preview {
    MainMenuView()
}
