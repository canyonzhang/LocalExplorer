//
//  MapView.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/19/23.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @Binding var cameraPosition: MapCameraPosition // Binding to the MapCameraPosition
    @Binding var results: [MKMapItem] // An array to store the results of the user's search
    @Binding var searchText: String
    @State private var mapSelection: MKMapItem?
    @State private var showDetails = false
    @State private var getDirections = false
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    @ObservedObject var locationManager: LocationManager // Pass the LocationManager instance
    @State private var initialCameraPositionSet = false
    @Binding var shouldCenterOnUser: Bool
    
    var body: some View {
        ZStack{
            Map(position: $cameraPosition, selection: $mapSelection) {
                // Custom annotation to display the user's current location
                Annotation("My location", coordinate: locationManager.userLocation?.coordinate ?? CLLocationCoordinate2D()) {
                    ZStack {
                        Circle()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.blue.opacity(0.25))
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                        Circle()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.blue)
                    }
                }
                // Loop through each of the returned results in the user's search and display a Marker
                ForEach(results, id: \.self) { item in
                    if routeDisplaying {
                        if item == routeDestination {
                            let placemark = item.placemark
                            Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                        }
                    }
                    else {
                        if let mapItem = item as? MKMapItem {
                            let placemark = mapItem.placemark
                            Marker(mapItem.name ?? "", coordinate: placemark.coordinate)
                        }
                    }
                }
                // If there is a route (the user clicks get directions), display a MapPolyline
                if let route {
                    MapPolyline(route.polyline)
                        .stroke(.blue, lineWidth: 6)
                }
            }.mapControls{
                MapCompass()
                MapPitchToggle()
                MapUserLocationButton()
            }
            
            // Textfield to search for location
            VStack {
                TextField("Search for a location...", text: $searchText)
                    .font(.subheadline)
                    .padding(12)
                    .background(Color.black)
                    .cornerRadius(10)
                    .frame(width: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: UIScreen.main.bounds.width * 0.15))
                    .shadow(radius: 10)
                Spacer()
            }.onAppear {
                if !initialCameraPositionSet, let userLocation = locationManager.userLocation {
                    centerMapOnUserLocation(userLocation)
                    initialCameraPositionSet = true
                }
            
                // Use of NotificationCenter to detect when the user decides to share/unshare their location
                // Sets up an observer to recenter map on Miami and update the user's location in LocationManager whenever a locationSharingDisabled notification is posted
                NotificationCenter.default.addObserver(forName: .locationSharingDisabled, object: nil, queue: .main) { _ in
                    let miamiCoordinates = CLLocationCoordinate2D(latitude: 25.7617, longitude: -80.1918)
                    locationManager.setUserLocation(to: miamiCoordinates)
                    self.recenterToMiami()
                }

            }
            .onChange(of: shouldCenterOnUser) { newValue in
                if newValue {
                    locationManager.startUpdatingLocation() // Restart location updates
                    if let userLocation = locationManager.userLocation {
                        centerMapOnUserLocation(userLocation)
                    }
                } else {
                    let miamiCoordinates = CLLocationCoordinate2D(latitude: 25.7617, longitude: -80.1918)
                    locationManager.setUserLocation(to: miamiCoordinates)
                    self.recenterToMiami()
                }
            }
            // Call searchPlaces method when the user makes a search
            .onSubmit(of: .text) {
                Task {
                    await searchPlaces()
                }
            }
            .onChange(of: getDirections) {
                oldValue, newValue in
                if newValue {
                    fetchRoute()
                }
            }
            .onChange(of: mapSelection) { newValue, oldValue in
                print("mapSelection changed!")
                showDetails = (newValue != nil)
            }
            // Display the details of a location
            .sheet(isPresented: $showDetails) {
                LocationDetailsView(mapSelection: $mapSelection,
                                    show: $showDetails,
                                    getDirections: $getDirections)
                .presentationDetents([.height(340)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                .presentationCornerRadius(12)
            }
        }
    }
    private func centerMapOnUserLocation(_ location: CLLocation) {
            // Convert CLLocation to MapCameraPosition type
            cameraPosition = convertCLLocationToMapCameraPosition(location)
        }
    
    private func convertCLLocationToMapCameraPosition(_ location: CLLocation) -> MapCameraPosition {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 1000, // 1km span for latitude
            longitudinalMeters: 1000 // 1km span for longitude
        )
        return MapCameraPosition.region(coordinateRegion) 
    }
    
    private func recenterToMiami() {
        let miamiCoordinates = CLLocationCoordinate2D(latitude: 25.7617, longitude: -80.1918)
        let miamiRegion = MKCoordinateRegion(center: miamiCoordinates, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        cameraPosition = MapCameraPosition.region(miamiRegion)
    }
}

// Extension that uses MKLocalSearch and a naturalLangaugeQuery to search for whatever the user types into the search bar using MapKit
extension MapView {
    func searchPlaces() async {
        route = nil
        routeDisplaying = false

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .userRegion

        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? [] // Populate the results @Binding to be rendered
    }
    
    
    // Function to generate polyline when the user clicks get directions using the MKDirections.Request()
    func fetchRoute() {
        if let mapSelection {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: .userLocation))
            request.destination = mapSelection
            
            Task {
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                routeDestination = mapSelection
                withAnimation(.snappy) {
                    routeDisplaying = true
                    showDetails = false
                    if let rect = route?.polyline.boundingMapRect, routeDisplaying {
                        cameraPosition = .rect(rect)
                    }
                }
            }
        }
    }
}
