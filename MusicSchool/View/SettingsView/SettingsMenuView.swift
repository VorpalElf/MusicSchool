//
//  SettingsMenuView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 31/7/25.
//

import SwiftUI

struct SettingsMenuView: View {
    @ObservedObject private var SetModel = SettingsViewModel()
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @Environment(\.colorScheme) var colourScheme
    
    
    // Colour Scheme
    var profileBackground: Color {
        colourScheme == .dark ? Color(.secondarySystemBackground): .white
    }
    var wholeBackground: Color {
        colourScheme == .light ? Color(.secondarySystemBackground): .black
    }
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 72, height: 72)
                    .foregroundColor(.gray)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(firstName + " " + lastName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                Spacer()
                    .frame(height: 5)
            }
            .padding()
            .background(profileBackground)
            .cornerRadius(16)
            .padding(.horizontal)
            .padding(.top, 24)
            
            List {
                Section(header: Text("Personal Information ℹ️")
                    .font(.caption)) {
                        NavigationLink (destination: SettingsNameView()) {
                            Text("Change Name")
                        }
                        
                        // TODO: Finish Change Email
                        NavigationLink(destination: SettingsEmailView()) {
                            Text("Change Email")
                        }
                        
                        NavigationLink (destination: SettingsPasswordView()) {
                            Text("Change Password")
                        }
                    }
            }
        }
        .background(wholeBackground)
        
        .onAppear() {
            Task {
                (firstName, lastName) = try await SetModel.fetchName()
            }
        }
    }
}

#Preview {
    SettingsMenuView()
}
