//
//  LocationDetailsView.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/19/23.
//

import SwiftUI
import MapKit

struct LocationDetailsView : View {
    @Binding var mapSelection: MKMapItem?
    @Binding var show : Bool
    @State private var lookAroundScene: MKLookAroundScene?
    @Binding var getDirections: Bool
    
    
    var body : some View{
        VStack {
            HStack{
                // Diplay location information (i.e. address, title, etc...)
                VStack(alignment: .leading) {
                    Text(mapSelection?.placemark.name ?? "")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding(.top, 30) 
                    Text(mapSelection?.placemark.title ?? "")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .lineLimit(2)
                        .padding(.trailing)
                }
                // X button to close view
                Button{
                    show.toggle()
                    mapSelection = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.gray, Color(.systemGray6))
                }
            } .padding(.vertical, 15)
            .padding(.horizontal, 15)
            
            Spacer()
            
            // Used LookAroundPreview from MapKit to display preview images
            if let scene = lookAroundScene {
                LookAroundPreview(initialScene: scene)
                    .frame(height:200)
                    .cornerRadius(12)
                    .padding()
            }
            else{
                ContentUnavailableView("No Preview Available", systemImage: "eye.slash")
            }
            
            // Buttons to generate polyline or open in maps
            HStack(spacing: 24) {
                Button {
                    if let mapSelection {
                        mapSelection.openInMaps()
                    }
                } label: {
                    Text("Open in Maps")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 170, height: 48)
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                Button {
                    getDirections = true
                } label: {
                    Text("Get Directions")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 170, height: 48)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)

        }
        .onAppear{
//            print("DID call on appear")
            fetchLookAroundDetailsPreview()
        }
        .onChange(of: mapSelection){ oldValue, newValue in
//            print("Did call on change")
            fetchLookAroundDetailsPreview()
        }
        
    }
    
}

// Extension that fetches a Look Around scene for a selected map item; uses Apple's MKLookAroundSceneRequest
extension LocationDetailsView {
    func fetchLookAroundDetailsPreview() {
        if let mapSelection {
            lookAroundScene = nil
            Task {
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookAroundScene = try? await request.scene
            }
        }
    }
}

#Preview {
    LocationDetailsView(mapSelection: .constant(nil), show: .constant(false), getDirections: .constant(false))
}
