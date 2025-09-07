//
//  ConSearchView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 18/8/25.
//

import SwiftUI

struct ConSearchView: View {
    @ObservedObject private var viewModel = AuthViewModel()
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var users: [(uid: String, name: String)] = []
    @State private var searchText: String = ""
    
    var filteredNames: [(uid: String, name: String)] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        VStack {
            Text("Others' Constraints")
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .frame(alignment: .leading)
            
            List {
                ForEach(filteredNames, id: \.uid) { user in
                    NavigationLink(destination: OtherConView(uid: user.uid)) {
                        Text(user.name)
                            .onAppear() {
                                print(user.uid)
                            }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search name here")
        }
        .onAppear() {
            Task {
                (users, showAlert, alertMessage) = try await viewModel.fetchAllNames()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    ConSearchView()
}
