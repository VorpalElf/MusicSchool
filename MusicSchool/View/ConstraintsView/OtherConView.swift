//
//  OtherConView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 6/9/25.
//

import SwiftUI

struct OtherConView: View {
    @ObservedObject private var viewModel = ConViewModel()
    @ObservedObject private var authModel = AuthViewModel()
    @State private var username: String = ""
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var result: String = ""
    
    let uid: String
    
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
            Text("\(username)'s Constraints")
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
                                }
                                .frame(minWidth: 150)
                                .padding(.leading, 10)
                                .padding(.trailing, 10)
                                .padding(.top, 5)
                                .padding(.bottom, 5)
                                .background(Color(.gray))
                                .cornerRadius(5)
                                
                                ForEach(time, id: \.self) { time in
                                    let (key, constraintColour) = viewModel.fetchCons(day: day, time: time)
                                    
                                    ZStack {
                                        Text("")
                                            .frame(width: 150, height: 20)
                                            .padding(5)
                                            .border(contrastColour, width: 1)
                                            .background(constraintColour)
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
            
            // When screen initialised
            .onAppear() {
                Task {
                    (username, _) = try await authModel.fetchOtherUser(uid: uid)
                    (showAlert, alertMessage) = try await viewModel.fetchConDocuments(uid: uid)
                }
            }
        }
    }
}

#Preview {
    OtherConView(uid: "")
}
