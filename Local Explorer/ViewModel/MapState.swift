//
//  MapState.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/20/23.
//

import SwiftUI
import MapKit

// Published var to track user's location
class MapState: ObservableObject {
    @Published var centerCoordinate: CLLocationCoordinate2D = .userLocation
}
