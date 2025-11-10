//
//  AddClassView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 8/9/25.
//

import SwiftUI

struct AddClassView: View {
    // View Models
    @ObservedObject private var authModel = AuthViewModel()
    @EnvironmentObject var viewModel: GenViewModel
    
    // Enter & Exit
    var classID: String
    @Environment(\.dismiss) private var dismiss
    
    // Alert
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    // User List
    @State private var users: [(uid: String, name: String)] = []
    @State private var searchText: String = ""
    
    var filteredNames: [(uid: String, name: String)] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    // Time
    @State var durHours: Int = 0
    @State var durMinutes: Int = 30

    var body: some View {
        NavigationStack {
            VStack {
                if durHours > 1 {
                    if durMinutes != 0 {
                        Text("\(durHours) hours \(durMinutes) minutes Class")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                            .frame(alignment: .leading)
                    } else {
                        Text("\(durHours) hours Class")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                            .frame(alignment: .leading)
                    }
                } else if durHours == 1 {
                    if durMinutes != 0 {
                        Text("\(durHours) hour \(durMinutes) minutes Class")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                            .frame(alignment: .leading)
                    } else {
                        Text("\(durHours) hour Class")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                            .frame(alignment: .leading)
                    }
                } else {
                    Text("\(durMinutes) minutes Class")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .frame(alignment: .leading)
                }
                
                
                
                // MARK: - Time
                HStack {
                    Text("Duration: ")
                    
                    Picker("Hours", selection: $durHours) {
                        ForEach(0..<10) { h in
                            Text("\(h)")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 100)
                    Text("h")
                    
                    Picker("Minutes", selection: $durMinutes) {
                        ForEach([0,30], id: \.self) { m in
                            Text("\(m)")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 100)
                    Text("min")
                }
                
                // MARK: - List of Students
                List {
                    ForEach(filteredNames, id: \.uid) { user in
                        let isSelected = viewModel.checkContainUser(pupil: user.uid)
                        
                        Button {
                            viewModel.toggleSelection(uid: user.uid)
                        } label: {
                            HStack {
                                Text(user.name)
                                    .foregroundColor(.primary)
                                
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .padding(5)
                                }
                            }
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search name here")
            }
        }
        
        // MARK: - Others
        .onAppear() {
            Task {
                (users, showAlert, alertMessage) = try await authModel.fetchAllStudents()
                if classID != "" {
                    // Update Pupil List
                    viewModel.updatePupilList(classID: classID)
                    viewModel.printPupilList()
                    
                    // Update values
                    let parts = classID.split(separator: ":")
                    durHours = Int(parts[0])!
                    durMinutes = Int(parts[1])!
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }

        .toolbar {
                Button {
                    let time = "\(String(durHours)):\(String(durMinutes))"
                    let pupilList: [String] = viewModel.fetchPupilList()
                    if pupilList.count == 0 {
                        alertMessage = "No Pupil Selected"
                        showAlert = true
                    } else {
                        if durMinutes != 0 || durHours != 0 {
                            (showAlert, alertMessage) = viewModel.updateClassList(duration: time, oldClassID: classID)
                            if !showAlert {
                                viewModel.removePupilList()
                                dismiss()
                            }
                        } else {
                            alertMessage = "Invalid hours"
                            showAlert = true
                        }
                    }
                } label: {
                    Image(systemName: "checkmark")
                }
        }
        .onDisappear() {
            // Clean classes if user pressed "Back" button
            viewModel.removePupilList()
        }

    }
}
