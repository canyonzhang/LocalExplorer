//
//  LocationManager.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/16/23.
//

import CoreLocation
import Combine

extension LocationManager {
    func setFirstLaunchToFalse() {
        isFirstLaunch = false
        UserDefaults.standard.set(false, forKey: "HasLaunchedBefore")
    }
}

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    
    // @Published var to track when it is the user's first launch of the app.
    @Published var isFirstLaunch: Bool {
            didSet {
//                print("IT IS THE FIRST LAUNCH")
                UserDefaults.standard.set(isFirstLaunch, forKey: "HasLaunchedBefore")
//                print("USER DEFAULTS HAS LAUNCHED BEFORE IS", UserDefaults.standard.set(isFirstLaunch, forKey: "HasLaunchedBefore"))
            }
        }
    
    // @Published var to track when the location sharing is enabled / disabled
    @Published var isLocationSharingEnabled: Bool {
        didSet {
            if isLocationSharingEnabled {
                manager.startUpdatingLocation()
            } else {
                manager.stopUpdatingLocation()
                userLocation = nil // Reset location to nil if sharing is off
            }
            UserDefaults.standard.set(isLocationSharingEnabled, forKey: "LocationSharingEnabled")
        }
    }


    @Published var userLocation: CLLocation? {
        didSet {
            saveLocationToUserDefaults(location: userLocation)
        }
    }
    static let shared = LocationManager()

    override init() {
        // Determine if it's the first launch based on UserDefaults
        isFirstLaunch = !UserDefaults.standard.bool(forKey: "HasLaunchedBefore")

        // Initialize isLocationSharingEnabled
        isLocationSharingEnabled = UserDefaults.standard.bool(forKey: "LocationSharingEnabled")
        
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest

        // Update UserDefaults if it's the first launch
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
        }

        

        // Start or stop updating location based on isLocationSharingEnabled
        if isLocationSharingEnabled {
            manager.startUpdatingLocation()
        } else {
            manager.stopUpdatingLocation()
        }
    }

    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        // Start updating location as soon as the user grants permission
        // Actual location updates will depend on the authorization status
        isLocationSharingEnabled = true
        manager.startUpdatingLocation()
    }
    
    func checkLocationAuthorization() {
        if isFirstLaunch {
            isFirstLaunch = false
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            // Only request authorization and start updating the location after the initial launch
            requestLocation()
        }
    }
    
    private func saveLocationToUserDefaults(location: CLLocation?) {
            if let location = location {
                UserDefaults.standard.set(location.coordinate.latitude, forKey: "UserLatitude")
                UserDefaults.standard.set(location.coordinate.longitude, forKey: "UserLongitude")
            }
        }
    
    func loadLocationFromUserDefaults() {
            let latitude = UserDefaults.standard.double(forKey: "UserLatitude")
            let longitude = UserDefaults.standard.double(forKey: "UserLongitude")
            if latitude != 0 && longitude != 0 { // Checking for default values
                userLocation = CLLocation(latitude: latitude, longitude: longitude)
            }
        }
    
    func startUpdatingLocation() {
        manager.requestWhenInUseAuthorization() // Request permission if needed
        manager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
            case .notDetermined:
                print("DEBUG: Not determined")
            case .restricted:
                print("DEBUG: Restricted")
            case .denied:
                print("DEBUG: Denied")
            case .authorizedAlways:
                print("DEBUG: Auth always")
            case .authorizedWhenInUse:
                print("DEBUG: Auth when in use")
            @unknown default:
                break
        }
    }
    
    func toggleLocationSharing() {
        isLocationSharingEnabled.toggle()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location
    }
    
    func setUserLocation(to coordinates: CLLocationCoordinate2D?) {
        if let coordinates = coordinates {
            let newLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            self.userLocation = newLocation
        } else {
            self.userLocation = nil // Clear the user location
        }
    }
}

