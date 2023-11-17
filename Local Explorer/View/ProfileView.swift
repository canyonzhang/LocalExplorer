//
//  ProfileView.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/20/23.
//

import SwiftUI
import FirebaseStorage
import FirebaseAuth
import CoreLocation

// Notification that is sent to and received by the MapView
extension Notification.Name {
    static let locationSharingDisabled = Notification.Name("LocationSharingDisabledNotification")
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showDeleteConfirmation = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @ObservedObject var locationManager = LocationManager.shared
    @Binding var shouldCenterOnUser: Bool
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var imageUrl: URL?
    
    var body: some View {
        List {
            Section {
                if let appUser = viewModel.appUser {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            profileImage(for: appUser)
                            userInfo(for: appUser)
                        }
                        .sheet(isPresented: $showingImagePicker) {
                            ImageUploader(image: $selectedImage)
                        }
                        .onAppear {
                            viewModel.fetchUserData()
                        }
                        .onChange(of: selectedImage) { newImage in
                            uploadProfileImage(newImage)
                        }
                    }
                }
            }
            Section("General") {
                VStack(spacing: 10) {
                    // Version Row
                    Button(action: {
                    }) {
                        HStack {
                            SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
                            Spacer()
                            Text("1.0.0")
                                .font(.subheadline)
                                .foregroundColor(Color(.systemGray))
                        }
                    }
                    
                    // Location Sharing Toggle Row
                    Button(action: {
                        let isLocationEnabled = !locationManager.isLocationSharingEnabled
                        locationManager.isLocationSharingEnabled = isLocationEnabled

                        if isLocationEnabled {
                            locationManager.startUpdatingLocation() // Start updating location
                            shouldCenterOnUser = true
                        } else {
                            locationManager.stopUpdatingLocation() // Stop updating location
                            shouldCenterOnUser = false
                            locationManager.setUserLocation(to: CLLocationCoordinate2D(latitude: 25.7617, longitude: -80.1918)) // Set to Miami
                            NotificationCenter.default.post(name: .locationSharingDisabled, object: nil)
                        }
                    }) {
                        SettingsToggleRowView(
                            imageName: "location",
                            title: "Share Location",
                            tintColor: Color.blue,
                            isToggleOn: Binding(
                                get: { locationManager.isLocationSharingEnabled },
                                set: {
                                    locationManager.isLocationSharingEnabled = $0
                                    if $0 {
                                        locationManager.startUpdatingLocation() // Start updating location
                                        shouldCenterOnUser = true
                                    } else {
                                        locationManager.stopUpdatingLocation() // Stop updating location
                                        shouldCenterOnUser = false
                                        locationManager.setUserLocation(to: CLLocationCoordinate2D(latitude: 25.7617, longitude: -80.1918)) // Set to Miami
                                        NotificationCenter.default.post(name: .locationSharingDisabled, object: nil)
                                    }
                                }
                            )
                        )
                    }

                }
            }
            

            Section("Account") {
                Button {
                    AuthenticationManager.shared.signOut()
                } label: {
                    SettingsRowView(imageName: "arrow.left.circle.fill",
                                    title: "Sign Out",
                                    tintColor: .red)
                }
                
                Button {
                    // This button action sets the flag to show the delete confirmation alert
                    self.showDeleteConfirmation = true
                } label: {
                    SettingsRowView(imageName: "xmark.circle.fill",
                                    title: "Delete Account",
                                    tintColor: .red)
                }
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("Delete Account"),
                        message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            AuthenticationManager.shared.deleteUser { error in
                                if let error = error {
                                    // Handle error in deletion
                                    self.alertMessage = error.localizedDescription
                                    self.showAlert = true
                                } else {
                        
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                
            }.onAppear {
                viewModel.fetchUserData()
            }
        }
    }
    @ViewBuilder
    // Fetch and render the user's profile image useing the raw url fetched from Firebase Storage
        private func profileImage(for appUser: AppUser) -> some View {
            if let imageUrl = appUser.profileImageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit()
                    } else if phase.error != nil {
                        Text("Failed to load image").foregroundColor(.gray)
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 100, height: 100)
                .cornerRadius(50)
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(50)
            }
            Button("Upload Profile Picture") {
                showingImagePicker = true
            }
            
            if appUser.profileImageUrl != nil {
                    Button("Delete Profile Picture") {
                        deleteProfileImage()
                    }
                }
            
        }
    
    private func deleteProfileImage() {
        viewModel.deleteProfileImage { success in
            if success {
                showingImagePicker = false
            }
        }
    }
    
    @ViewBuilder
    // Abstracted these views into separate methods for greater readability in the body
    private func userInfo(for appUser: AppUser) -> some View {
        Text("\(appUser.firstName) \(appUser.lastName)")
            .font(.subheadline)
            .fontWeight(.semibold)
            .padding(.top, 4)
        Text(appUser.email)
            .font(.footnote)
            .accentColor(.gray)
    }
    
    private func uploadProfileImage(_ newImage: UIImage?) {
        guard let newImage = newImage, let currentUser = Auth.auth().currentUser else { return }
        print("UPLOADING USER IMAGE")
        viewModel.uploadImage(newImage) { result in
            switch result {
            case .success(let url):
                if var appUser = viewModel.appUser {
                    appUser.profileImageUrl = url.absoluteString // Update the profile image URL
                    print("UPDATING USER IMAGE")
                    viewModel.updateProfileImageUrl(url, for: appUser) // Pass the URL and the AppUser object
                }
            case .failure(let error):
                print("ERROR UPLOADING IT IS: \(error)")
            }
        }
    }
    
    func loadImage(){
        guard let selectedImage = selectedImage else { return }
        image = Image(uiImage: selectedImage)
    }
    
    
}


//#Preview {
//    ProfileView()
//}
