//
//  MyConView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 18/8/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct MyConView: View {
    @ObservedObject private var viewModel = ConViewModel()
    @State private var uid: String = ""
    @State private var tempFullDay: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var result: String = ""
    
    // MARK: - Colour Scheme
    // Colour Scheme for Dark Mode
    @Environment(\.colorScheme) var borderColourScheme
    
    var contrastColour: Color {
        borderColourScheme == .dark ? .white: .black
    }
    
    // MARK: - Graphics
    // Array for Day
    let day = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    
    // Array for time
    let time = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30",
                "11:00", "11:30", "12:00", "12:30", "13:00", "13:30",
                "14:00", "14:30", "15:00", "15:30", "16:00"]
    
    var body: some View {
        VStack {
            Text("My Constraints")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // MARK: - Constraints
            ScrollView(.horizontal) {
                ScrollView {
                    // Layout format: Day{Time}
                    LazyHGrid(rows: [GridItem(.fixed(6))]) {
                        LazyVGrid(columns: [GridItem(.fixed(CGFloat(time.count)))]) {
                            // First Column
                            Text("Time")
                                .frame(width: 100)
                                .padding(10)
                            
                            ForEach(time, id: \.self) { time in
                                Text(time)
                                    .padding(5)
                            }
                            .frame(width: 150)
                        }
                        
                        ForEach(day, id: \.self) { day in
                            LazyVGrid(columns: [GridItem(.fixed(CGFloat(time.count)))]) {
                                HStack {
                                    Text(day)
                                        .padding(5)
                                        
                                    if viewModel.selectionMode != nil {
                                        let cond = viewModel.fullDayCons(day: day, times: time)
                                        Image(systemName: cond ? "checkmark.circle.fill": "circle")
                                            .foregroundColor(.blue)
                                            .padding(5)
                                    }
                                }
                                .frame(minWidth: 150)
                                .padding(.leading, 10)
                                .padding(.trailing, 10)
                                .padding(.top, 5)
                                .padding(.bottom, 5)
                                .background(Color(.gray))
                                .cornerRadius(5)
                                
                                .onTapGesture {
                                    if viewModel.selectionMode != nil {
                                        let cond = viewModel.fullDayCons(day: day, times: time)
                                        for t in time {
                                            let key = "\(day)_\(t)"
                                            if viewModel.selectedCells.contains(key) == cond {
                                                viewModel.toggleSelection(for: key)
                                            }
                                        }
                                    }
                                }
                                
                                ForEach(time, id: \.self) { time in
                                    let (key, constraintColour) = viewModel.fetchCons(day: day, time: time)
                                    
                                    ZStack {
                                        Text("")
                                            .frame(width: 150, height: 20)
                                            .padding(5)
                                            .border(contrastColour, width: 1)
                                            .background(constraintColour)
                                        
                                        if viewModel.selectionMode != nil {
                                            // Is this cell in the array
                                            Image(systemName: viewModel.selectedCells.contains(key) ? "checkmark.circle.fill": "circle")
                                                .foregroundColor(.blue)
                                                .padding(5)
                                        }
                                    }
                                    .onTapGesture {
                                        if viewModel.selectionMode != nil {
                                            viewModel.toggleSelection(for: key)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // MARK: - Toolbar
            .toolbar {
                if (viewModel.selectionMode != nil) {
                    Button {
                        Task {
                            (showAlert, alertMessage) = try await viewModel.applyCons(mode: viewModel.selectionMode!)
                            (showAlert, alertMessage) = try await viewModel.fetchConDocuments(uid: uid)
                        }
                    } label: {
                        Text("Done")
                    }
                } else {
                    Menu {
                        Button {
                            viewModel.selectionMode = .avoid
                        } label: {
                            Text("Avoid")
                            Image(systemName: "exclamationmark.triangle")
                        }
                        
                        Button {
                            viewModel.selectionMode = .prefer
                        } label: {
                            Text("Prefer")
                            Image(systemName: "checkmark")
                        }
                        
                        Button {
                            viewModel.selectionMode = .free
                        } label: {
                            Text("Free")
                            Image(systemName: "eraser")
                        }
                    } label: {
                        Image(systemName: "plus.app")
                    }
                }
            }
            
            // MARK: - Others
            // Alert
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            
            // When screen initialised
            .onAppear() {
                Task {
                    guard let fetchedUID = Auth.auth().currentUser?.uid else {
                        (showAlert, alertMessage) = (true, "Failed to fetch UID")
                        return
                    }
                    uid = fetchedUID
                    (showAlert, alertMessage) = try await viewModel.fetchConDocuments(uid: uid)
                }
            }
        }
    }
}

#Preview {
    MyConView()
}
