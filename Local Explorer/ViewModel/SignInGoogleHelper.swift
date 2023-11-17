//
//  SignInGoogleHelper.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/21/23.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import FirebaseDatabase
import FirebaseAuth

// struct to store the token and accesstoken

struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
}

final class SignInGoogleHelper {
    
    @MainActor
    func signIn() async throws -> GoogleSignInResultModel {
        guard let topVC = Utilities.shared.topViewController() else {
//            print("THERE WAS AN ERROR")
            throw URLError(.cannotFindHost)
        }

        // Async call using GIDSsignIn to sign in with the top view controller.
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)

        guard let idToken = gidSignInResult.user.idToken?.tokenString,
            let email = gidSignInResult.user.profile?.email else {
//            print("THERE WAS AN ERROR2")
            throw URLError(.badServerResponse)
        }

        // Get the access token from the result
        let accessToken = gidSignInResult.user.accessToken.tokenString
        // Authenticate with Firebase using the Google credential
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let authResult = try await Auth.auth().signIn(with: credential)
        let firebaseUser = authResult.user

        // Check if user data needs to be saved to the database
        try await saveUserProfileIfNeeded(uid: firebaseUser.uid,
                                          firstName: gidSignInResult.user.profile?.givenName ?? "",
                                          lastName: gidSignInResult.user.profile?.familyName ?? "",
                                          email: gidSignInResult.user.profile?.email ?? "")

        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        return tokens
    }
    
    private func saveUserProfileIfNeeded(uid: String, firstName: String, lastName: String, email: String) async throws {
            let usersRef = Database.database().reference().child("users").child(uid)
            // Check if the user data already exists
            let snapshot = try await usersRef.getData()
            // If the snapshot doesn't exist or doesn't have an email, assume the user is new
            if !snapshot.exists() || snapshot.childSnapshot(forPath: "email").value as? String == nil {
                let userRecord = ["firstName": firstName, "lastName": lastName, "email": email]
                try await usersRef.setValue(userRecord)
            }
        }

}

