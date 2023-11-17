//
//  ProfileViewModel.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/20/23.
//

import Firebase
import FirebaseDatabase
import FirebaseStorage

class ProfileViewModel: ObservableObject {
    @Published var appUser: AppUser?
    
    // Method to fetch and populate AppUser with the current user's data
    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let usersRef = Database.database().reference().child("users").child(uid)
        usersRef.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self,
                  let value = snapshot.value as? [String: Any],
                  let firstName = value["firstName"] as? String,
                  let lastName = value["lastName"] as? String,
                  let email = value["email"] as? String else { return }
            let profileImageUrl = value["profileImageUrl"] as? String
            DispatchQueue.main.async {
                self.appUser = AppUser(uid: uid, firstName: firstName, lastName: lastName, email: email, profileImageUrl: profileImageUrl)
            }
        })
    }
    
}

// References Firebase Storage to update the user's profile image url
extension ProfileViewModel {
    func updateProfileImageUrl(_ url: URL, for user: AppUser) {
        let dbRef = Database.database().reference()
        let userRef = dbRef.child("users").child(user.uid)
        userRef.updateChildValues(["profileImageUrl": url.absoluteString]) { error, _ in
            if let error = error {
                print("Failed to update profile image URL: \(error)")
            } else {
                // Update the local user model with the new image URL
                DispatchQueue.main.async {
                    self.appUser?.profileImageUrl = url.absoluteString
                }
            }
        }
    }
}

// Function to compress the image and store it in the user's firebase storage as a .jpg
extension ProfileViewModel {
    func uploadImage(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            completion(.failure(NSError(domain: "AppError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image data not available."])))
            return
        }

        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("\(imageName).jpg")

        // Insert the imageData into firebase
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Upload error: \(error)")
                completion(.failure(error))
                return
            }
            print("Upload success, metadata: \(String(describing: metadata))")
            
            // Attempt to download the image url
            storageRef.downloadURL { url, error in
                if let url = url {
                    print("Download URL: \(url)")
                    completion(.success(url))
                } else if let error = error {
                    print("Download URL error: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
}


extension ProfileViewModel {
    func deleteProfileImage(completion: @escaping (Bool) -> Void) {
            guard let currentUser = Auth.auth().currentUser,
                  let appUser = appUser,
                  // Grab the current user and their profile Image url
                  let imageUrl = appUser.profileImageUrl else {
                completion(false)
                return
            }

            let urlComponents = imageUrl.components(separatedBy: "/")
            guard let lastComponent = urlComponents.last,
                  let decodedName = lastComponent.removingPercentEncoding,
                  let fileName = decodedName.split(separator: "?").first else {
                completion(false)
                return
            }

            // Delete from Firebase Storage
            let storageRef = Storage.storage().reference().child(String(fileName))
            storageRef.delete { [weak self] error in
            if let error = error {
                print("Error deleting image: \(error)")
                completion(false)
            } else {
                // Remove image URL from Firebase Database
                let dbRef = Database.database().reference()
                let userRef = dbRef.child("users").child(currentUser.uid)
                userRef.updateChildValues(["profileImageUrl": ""]) { error, _ in
                    if let error = error {
                        print("Failed to update profile image URL: \(error)")
                        completion(false)
                    } else {
                        // Update the local user model to remove the image URL
                        DispatchQueue.main.async {
                            self?.appUser?.profileImageUrl = nil
                            completion(true)
                        }
                    }
                }
            }
        }
    }
}





