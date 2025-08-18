//
//  OtherTimeView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 18/8/25.
//

import SwiftUI

struct OtherTimeView: View {
    let uid: String
    
    // Array for Day
    let day = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    
    // Array for time
    let time = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30",
                "11:00", "11:30", "12:00", "12:30", "13:00", "13:30",
                "14:00", "14:30", "15:00", "15:30", "16:00"]
    
    @ObservedObject private var viewModel = TimetableViewModel()
    @State private var currentWeek: Date = Date()
    @State private var showPicker: Bool = false
    @State private var tempPickedDate: Date = Date()    // Date picked in the calendar
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State var color: Color = Color(.green)
    @State private var result: String = ""
    
    var body: some View {
        VStack {
            Text("My Timetable")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // MARK: - Date Picker
            HStack {
                Spacer()
                
                // Left Button
                Button {
                    viewModel.selectedWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: viewModel.selectedWeek)!
                } label: {
                    Image(systemName: "chevron.left")
                        .padding(.trailing, 5)
                }
                
                // Date Range Button
                Button {
                    tempPickedDate = viewModel.selectedWeek
                    showPicker = true
                } label: {
                    Text(viewModel.weekRangeString(for: viewModel.selectedWeek))
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(2)
                        .frame(width: 230)
                }
                // Right Button
                Button {
                    viewModel.selectedWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: viewModel.selectedWeek)!
                } label: {
                    Image(systemName: "chevron.right")
                        .padding(.leading, 5)
                }
                Spacer()
            }
            
            // Date Picker
            .sheet(isPresented: $showPicker) {
                VStack {
                    HStack {
                        Spacer()
                        Button("Done") {
                            viewModel.selectedWeek = TimetableViewModel.weekStart(for: tempPickedDate)
                            showPicker = false
                        }
                        .padding()
                    }
                    DatePicker(
                        "Pick a date in the week",
                        selection: $tempPickedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                }
            }
            
            // MARK: - Timetable View
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
                                Text(day)
                                    .frame(minWidth: 150)
                                    .padding(10)
                                    .background(Color(.gray))
                                    .cornerRadius(5)
                                
                                ForEach(time, id: \.self) { time in
                                    let lesson = viewModel.fetchLessons(day: day, time: time)
                                    Text(lesson.name)
                                        .frame(minWidth: 150)
                                        .padding(5)
                                        .border(Color.black, width: 1)
                                        .background(lesson.color)
                                }
                            }
                        }
                    }
                }
            }
        }
        // MARK: - Others
        
        // Alert
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        // Reset Date when user exits
        .onDisappear() {
            viewModel.selectedWeek = TimetableViewModel.weekStart(for: Date())
        }
        // When screen initialised
        .onAppear() {
            Task {
                (showAlert, alertMessage) = try await viewModel.fetchDocument(uid: uid)
            }
        }
        // Whenever selectedWeek changed
        .onChange(of: viewModel.selectedWeek) { _ in
            Task {
                (showAlert, alertMessage) = try await viewModel.fetchDocument(uid: uid)
            }
        }
    }
    
}

#Preview {
    OtherTimeView(uid: "u33CWfTCjeTftM9cgTFHoRGcbcs2")
}
