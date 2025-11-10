//
//  GenClassView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 11/8/25.
//

import SwiftUI

struct GenClassView: View {
    @EnvironmentObject var viewModel: GenViewModel
    @State private var classes: [String] = []
    @State private var anyClass: Bool = false
    @State private var startDate: Date = Date.now
    @State private var endDate: Date = Date.now
    
    @State private var showConfirmation: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    
    @State private var direct: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Classes")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                if anyClass {
                    // MARK: - Class List
                    List {
                        ForEach(classes, id: \.self) { className in
                            // Update values
                            let parts = className.split(separator: ":")
                            let displayName = "\(String(parts[0]))h \(String(parts[1]))min"
                            NavigationLink(destination: AddClassView(classID: className)) {
                                Text(displayName)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                    
                    // MARK: - Date Pickers
                    DatePicker(selection: $startDate, displayedComponents: .date) {
                        Text("Start: ")
                            .onChange(of: startDate) { newStart in
                                endDate = newStart
                            }
                    }
                    .padding()
                    
                    DatePicker(selection: $endDate, displayedComponents: .date) {
                        Text("End: ")
                    }
                    .padding()
                    
                    // MARK: - Generate Button
                    NavigationLink(destination: GenTimeView(viewModel: viewModel, startingWeek: GenTimeView.weekStart(for: startDate)), isActive: $direct) {
                        Button {
                            if startDate == endDate {
                                showAlert = true
                                alertTitle = "Same Starting & End Date"
                            } else {
                                Task {
                                    // TODO: Pass stuff to the model
                                    (showAlert, alertTitle) = await viewModel.generateTimetable(startDate: startDate, endDate: endDate)
                                    
                                    // TODO: Send Processed Data to GenTimeView
                                    
                                    // Direct the user
                                    if showAlert == false {
                                        direct = true
                                    }
                                }
                            }
                        } label: {
                            Text("Generate")
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
                    .padding(.bottom, 40)
                } else {
                    NavigationLink (destination: AddClassView(classID: "")) {
                        Image(systemName: "plus.app.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .padding()
                    }
                }
            }
        }
        
        // MARK: - Toolbar
        .toolbar {
            NavigationLink(destination: AddClassView(classID: "")) {
                Image(systemName: "plus.app")
            }
            
            Button {
                showConfirmation = true
            } label: {
                Image(systemName: "arrow.uturn.backward")
            }
        }
        
        
        // MARK: - Others
        .onAppear {
            viewModel.printList()   // TODO: Remove this
            classes = viewModel.fetchClassList()
            if classes.count == 0 {
                anyClass = false
            } else {
                anyClass = true
            }
        }
        
        // MARK: Alert
        .alert("Are you sure?" ,isPresented: $showConfirmation) {
            Button("Yes") {
                viewModel.resetClassList()
                anyClass = false
            }
            Button("No") {
                
            }
        } message: {
            Text("This operation cannot be undone.")
        }
        
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertTitle), dismissButton: .default(Text("OK")))
        }
    }
    
    // MARK: - Function
    // Function for Deleting Classes
    func delete(at offsets: IndexSet) {
        // Remove from Global List
        for index in offsets {
            let duration = classes[index]
            viewModel.deleteClass(duration: duration)
        }
        // Remove from View List
        classes.remove(atOffsets: offsets)
        
        // Update View
        classes = viewModel.fetchClassList()
        if classes.count == 0 {
            anyClass = false
        } else {
            anyClass = true
        }
    }
}
