//
//  MainTabView.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/20/23.
//

import SwiftUI
import MapKit

// Navigation View
struct MainTabView: View {
    @ObservedObject var locationManager = LocationManager.shared
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText = ""
    @State private var results = [MKMapItem]()
    @StateObject var profileViewModel = ProfileViewModel()
    @State private var shouldCenterOnUser = true
    @EnvironmentObject var healthManager: HealthManager
    
    var body: some View {
        // Renders the Map, Profile, and ActivityView in a TabView, uses the ViewModels where necessary
            TabView {
                MapView(cameraPosition: $cameraPosition, results: $results, searchText: $searchText, locationManager: locationManager, shouldCenterOnUser: $shouldCenterOnUser)
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }

                ProfileView(shouldCenterOnUser: $shouldCenterOnUser)
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }
                ActivityView()
                    .tag("Activity")
                    .tabItem{
                        Label("Activity", systemImage: "heart.fill")
                    }
                    .environmentObject(healthManager)
            }
            .onAppear {
                profileViewModel.fetchUserData() // user profileViewModel to fetch User data and render on profileView
            }
        }
}


#Preview {
    MainTabView()
}
