//
//  AuthenticationManager.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/20/23.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth


struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    
    init(user: User){
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}

final class AuthenticationManager: ObservableObject {
    
    static let shared = AuthenticationManager()
    @Published var isAuthenticated = false
    
    private init() {
            self.checkAuthentication()
        }
    
    // Function to check and update the isAuthenticated published var
    private func checkAuthentication() {
            Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
                if user != nil {
                    // User is signed in, update isAuthenticated
                    DispatchQueue.main.async {
                        self?.isAuthenticated = true
                    }
                } else {
                    // No user is signed in, update isAuthenticated
                    DispatchQueue.main.async {
                        self?.isAuthenticated = false
                    }
                }
            }
        }


        func signOut() {
            do {
                try Auth.auth().signOut()
                UserDefaults.standard.set(false, forKey: "isUserAuthenticated") // Update UserDefaults flag
                self.isAuthenticated = false
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }
        
        func deleteUser(completion: @escaping (Error?) -> Void) {
            guard let user = Auth.auth().currentUser else {
                completion(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user logged in"]))
                return
            }
            
            // Delete the user data from the database
            let dbRef = Database.database().reference()
            dbRef.child("users").child(user.uid).removeValue { error, _ in
                if let error = error {
                    completion(error)
                    return
                }

                // Delete the user account
                user.delete { deleteError in
                    if let deleteError = deleteError {
                        completion(deleteError)
                    } else {
                        UserDefaults.standard.set(false, forKey: "isUserAuthenticated") // Update UserDefaults flag
                        DispatchQueue.main.async {
                            self.isAuthenticated = false
                        }
                        completion(nil)
                    }
                }
            }
        }

    
    }

// Email authentication functions

extension AuthenticationManager {
    func register(firstName: String, lastName: String, email: String, password: String) async throws {
        // Create a new user with FirebaseAuth
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let newUser = AuthDataResultModel(user: authDataResult.user)

        // Set the first and last name in the database
        let dbRef = Database.database().reference() // Ensure FirebaseDatabase is imported
        let usersRef = dbRef.child("users").child(newUser.uid)
        
        let userRecord = ["firstName": firstName, "lastName": lastName, "email": email]
        try await usersRef.setValue(userRecord)

        DispatchQueue.main.async {
            self.isAuthenticated = true
        }
    }
    
    func createUser(email: String, password: String) async throws {
            let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let _ = AuthDataResultModel(user: authDataResult.user)
            // After a successful sign-up, set isAuthenticated to true
            DispatchQueue.main.async {
                self.isAuthenticated = true
            }
        }
    
    func signIn(email: String, password: String) async throws {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        let _ = AuthDataResultModel(user: authDataResult.user)
        DispatchQueue.main.async {
            self.isAuthenticated = true
        }
    }
}

// Google sign in methods

extension AuthenticationManager {
    
    @discardableResult
    // Use the tokens GoogleSignInResult model as a credential for the GoogleAuthProvider
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        self.isAuthenticated = true
        return try await signIn(credential: credential)
    }

    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}

