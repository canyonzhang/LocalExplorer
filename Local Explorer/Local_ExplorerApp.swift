//
//  Local_ExplorerApp.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/16/23.
//

import SwiftUI
import Firebase

@main
struct Local_ExplorerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authenticationManager = AuthenticationManager.shared
    @StateObject private var locationManager = LocationManager.shared

    var body: some Scene {
        WindowGroup {
            // If it is the first launch of the app, render the location request view
            if locationManager.isFirstLaunch {
                LocationRequestView()
            } else if authenticationManager.isAuthenticated {
                // otherwise not first launch and user authenticated, render the maintabview
                ContentView()
            } else {
                // otherwise render the authenticationview
                AuthenticationView()
            }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    print("Configured firebase")
    return true
  }
}
