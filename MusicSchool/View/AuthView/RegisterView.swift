//
//  RegisterView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 12/6/25.
//

import SwiftUI

struct RegisterView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Register as...")
                    .padding()
                    .font(.title)
                    .fontWeight(.bold)
                
                NavigationLink(destination: RegTeacherView()) {
                    Text("Teacher")
                    .padding()
                    .padding(.horizontal, 13)
                    .background(Color(.orange))
                    .foregroundColor(.white)
                    .font(.title2)
                    .fontWeight(.bold)
                    .cornerRadius(8)
                    .frame(width: 180)
                }
                
                NavigationLink(destination: RegStudentView()) {
                    Text("Student")
                    .padding()
                    .padding(.horizontal, 13)
                    .background(Color(.blue))
                    .foregroundColor(.white)
                    .font(.title2)
                    .fontWeight(.bold)
                    .cornerRadius(8)
                    .frame(width: 180)
                }
                
            }
        }
        .padding()
    }
}

#Preview {
    RegisterView()
}
