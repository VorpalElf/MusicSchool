//
//  ConMenuView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 18/8/25.
//

import SwiftUI

struct ConMenuView: View {
    @ObservedObject private var viewModel = AuthViewModel()
    @State private var isTeacher: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        VStack {
            Text("Constraints")
                .font(.title)
                .fontWeight(.bold)
            
            NavigationLink(destination: MyConView()) {
                Text("My Constraints")
                    .padding()
                    .padding(.horizontal, 5)
                    .background(Color(.orange))
                    .foregroundColor(.white)
                    .font(.title2)
                    .fontWeight(.bold)
                    .cornerRadius(8)
            }
            
            NavigationLink(destination: ConSearchView(), isActive: $isTeacher) {
                Button {
                    Task {
                        let uid = viewModel.fetchUID()
                        (isTeacher, showAlert, alertMessage) = try await viewModel.checkTeacher(uid: uid)
                    }
                } label: {
                    Text("Other Constraints")
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
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    ConMenuView()
}
