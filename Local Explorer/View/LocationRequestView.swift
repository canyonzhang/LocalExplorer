//
//  LocationRequestView.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/16/23.
//


import SwiftUI
import MapKit

struct LocationRequestView: View {
    
    @ObservedObject var locationManager = LocationManager.shared
    
    var body: some View {
        ZStack {
            Color(.systemBlue).ignoresSafeArea()

            VStack {
                Spacer()
                
                Image(systemName: "paperplane.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 32)

                Text("Would you like to explore places nearby?")
                    .font(.system(size: 28, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .padding()

                Text("Start sharing your location with us")
                    .multilineTextAlignment(.center)
                    .frame(width: 140)
                    .padding()

                Spacer()

                VStack {
                    Button {
                        locationManager.requestLocation() // calls requestLocation() method from shared instance of location manager
                        locationManager.setFirstLaunchToFalse()
                    } label: {
                        Text("Allow location")
                            .padding()
                            .font(.headline)
                            .foregroundColor(Color(.systemBlue))
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .padding(.horizontal, -32)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .padding()

                    Button {
                        // Logic to set the map to show Miami coordinates
                        locationManager.userLocation = CLLocation(latitude: 25.7617, longitude: -80.1918)
                        // As soon as we allow or dismiss, render the AuthenticationView
                        locationManager.setFirstLaunchToFalse()
                       
                    } label: {
                        Text("Maybe later")
                            .padding()
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 32)

            }
            .foregroundColor(.white)
        }
    }

}

struct LocationRequestView_Previews: PreviewProvider {
    static var previews: some View {
        LocationRequestView()
    }
}

