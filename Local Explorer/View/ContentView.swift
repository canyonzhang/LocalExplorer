//
//  ContentView.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/16/23.
//

import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @ObservedObject var locationManager = LocationManager.shared
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText = ""
    @State private var results = [MKMapItem]()
    @StateObject var healthManager = HealthManager()
    
    init() {}
    
    var body: some View {
           MainTabView()
               .environmentObject(healthManager)
       }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension CLLocationCoordinate2D {
    // Extension to retreive user's latitude and longitude from UserDefaults
    static var userLocation: CLLocationCoordinate2D {
        let latitude = UserDefaults.standard.double(forKey: "UserLatitude")
        let longitude = UserDefaults.standard.double(forKey: "UserLongitude")
        // Check if the UserDefaults contains a valid coordinate; otherwise, return a default value
        if latitude != 0.0 && longitude != 0.0 {
            // Return if valid coordinates
            return .init(latitude: latitude, longitude: longitude)
        } else {
            // Return a default location in Miami if no location is found
            return .init(latitude: 25.7602, longitude: -80.1959)
        }
    }
}

// Extension to create a region centered around the user's location
extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
}


#Preview {
    ContentView()
}
