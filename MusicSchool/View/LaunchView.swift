//
//  LaunchView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 12/6/25.
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome")
                    .padding()
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Image("Norwich School")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(20)
                    .imageScale(.medium)
                
                // Sign In View Button
                NavigationLink(destination: SignInView()) {
                    Text("Sign In")
                    .padding()
                    .padding(.horizontal, 13)
                    .background(Color(.orange))
                    .foregroundColor(.white)
                    .font(.title2)
                    .fontWeight(.bold)
                    .cornerRadius(8)
                    .frame(width: 180)
                }
                
                // Register View Button
                NavigationLink(destination: RegisterView()) {
                    Text("Register")
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
    LaunchView()
}
