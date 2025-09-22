//
//  MusicSchoolApp.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 12/6/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct MusicSchoolApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var viewModel = GenViewModel()
    
    var body: some Scene {
        WindowGroup {
            LaunchView()
                .environmentObject(viewModel)
        }
    }
}
