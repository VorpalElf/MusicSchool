//
//  GenTimeView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 29/9/25.
//

import SwiftUI
import FirebaseAuth

struct GenTimeView: View {
    @ObservedObject var viewModel: GenViewModel
    
    @State private var selectedWeek: Date // The parent view will provide the initial week.
    @State private var showPicker: Bool = false
    @State private var tempPickedDate: Date = Date()    // Date picked in the calendar
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State var color: Color = Color(.green)
    @State private var result: String = ""
    
    @State private var isUploaded: Bool = false
    
    // Colour Scheme for Dark Mode
    @Environment(\.colorScheme) var borderColourScheme
    
    var contrastColour: Color {
        borderColourScheme == .dark ? .white: .black
    }
    
    // Array for Day
    let day = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    
    // Array for time
    let time = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30",
                "11:00", "11:30", "12:00", "12:30", "13:00", "13:30",
                "14:00", "14:30", "15:00", "15:30", "16:00"]
    
    // Filter Lessons from Generated Array
    private var lessonsForSelectedWeek: [[String: Any]] {
        let calendar = Calendar.current
        let startOfWeek = Self.weekStart(for: selectedWeek)
        guard let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) else {
            return []
        }
        
        return viewModel.lessonTemp.filter { lesson in
            guard let lessonDate = lesson["Date"] as? Date else { return false }
            let lessonDay = calendar.startOfDay(for: lessonDate)
            return lessonDay >= startOfWeek && lessonDay <= endOfWeek
        }
    }
    
    init(viewModel: GenViewModel, startingWeek: Date) {
        self.viewModel = viewModel
        self._selectedWeek = State(initialValue: Self.weekStart(for: startingWeek))
    }
    
    
    // MARK: - Body
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
                    selectedWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedWeek)!
                } label: {
                    Image(systemName: "chevron.left")
                        .padding(.trailing, 5)
                }
                
                // Date Range Button
                Button {
                    tempPickedDate = selectedWeek
                    showPicker = true
                } label: {
                    Text(weekRangeString(for: selectedWeek))
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(2)
                        .frame(width: 230)
                }
                // Right Button
                Button {
                    selectedWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedWeek)!
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
                            selectedWeek = GenTimeView.weekStart(for: tempPickedDate)
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
                                    let lesson = lessonFor(day: day, time: time)
                                    let hasLesson = (lesson != nil)
                                    Text(lesson?["studentName"] as? String ?? "N/A")
                                        .frame(minWidth: 150)
                                        .padding(5)
                                        .border(contrastColour, width: 1)
                                        .background(hasLesson ? Color.orange : Color.green)
                                }
                            }
                        }
                    }
                }
            }
        }
        .toolbar {
            NavigationLink(destination: MainMenuView(), isActive: $isUploaded) {
                Button {
                    Task {
                        (showAlert, alertMessage) = try await viewModel.uploadTimetable()
                        isUploaded = !showAlert
                    }
                } label: {
                    Image(systemName: "checkmark")
                        .padding()
                }
            }
        }
        
        // MARK: - Others
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear() {
            print(lessonsForSelectedWeek)
        }
        .onDisappear {
            Task {
                _ = await viewModel.toggleUserLock(uid: viewModel.AuthView.fetchUID(), cond: false)
            }
        }
    }
    // MARK: - Functions
    
    // Extract Sunday Date
    static func weekStart(for date: Date) -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let daysToSubtract = (weekday == 1) ? 6 : (weekday - 2)
        guard let monday = calendar.date(byAdding: .day, value: -daysToSubtract, to: date) else {
            return date
        }
        return calendar.startOfDay(for: monday)
    }
    
    // Return Week Range Text
    func weekRangeString(for weekStart: Date) -> String {
        let cal = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM YYYY"
        let weekEnd = cal.date(byAdding: .day, value: 6, to: weekStart)!
        return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
    }
    
    // Fetch Specific Lesson from Array
    private func lessonFor(day: String, time: String) -> [String: Any]? {
        return lessonsForSelectedWeek.first { lesson in
            guard let lessonDay = lesson["Day"] as? String,
                  let lessonTimes = lesson["Times"] as? [String] else { return false }
            return lessonDay == day && lessonTimes.contains(time)
        }
    }
}

#Preview {
    GenTimeView(viewModel: GenViewModel(), startingWeek: Date())
}
