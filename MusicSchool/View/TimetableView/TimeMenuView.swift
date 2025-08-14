//
//  TimeMenuView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 11/8/25.
//

import SwiftUI

struct TimeMenuView: View {
    @ObservedObject private var viewModel = AuthViewModel()
    @State private var isTeacher: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        VStack {
            Text("Timetable")
                .padding()
                .font(.title)
                .fontWeight(.bold)
            
            NavigationLink(destination: MyTimeView()) {
                Text("My Timetable")
                    .padding()
                    .padding(.horizontal, 5)
                    .background(Color(.orange))
                    .foregroundColor(.white)
                    .font(.title2)
                    .fontWeight(.bold)
                    .cornerRadius(8)
            }
            
            NavigationLink(destination: TimeSearchView(), isActive: $isTeacher) {
                Button {
                    Task {
                        (isTeacher, showAlert, alertMessage) = try await viewModel.checkTeacher()
                    }
                } label: {
                    Text("Other's Timetable")
                        .padding()
                        .padding(.horizontal, 5)
                        .background(Color(.blue))
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.bold)
                        .cornerRadius(8)
                }
            }
            
            NavigationLink(destination: GenTimeView(), isActive: $isTeacher) {
                Button {
                    Task {
                        (isTeacher, showAlert, alertMessage) = try await viewModel.checkTeacher()
                    }
                } label: {
                    Text("Generate Timetable")
                        .padding()
                        .padding(.horizontal, 5)
                        .background(Color(.green))
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.bold)
                        .cornerRadius(8)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Warning"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    TimeMenuView()
}
