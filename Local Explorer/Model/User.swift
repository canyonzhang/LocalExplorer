//
//  User.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/20/23.
//

import Foundation
import FirebaseAuth

// Had to rename as to not conflict with Firebase 'User'
// Data model to store user information
struct AppUser {
    let uid: String
    let firstName: String
    let lastName: String
    let email: String
    var profileImageUrl: String?
    
    init(uid: String, firstName: String, lastName: String, email: String, profileImageUrl: String? = nil) {
            self.uid = uid
            self.firstName = firstName
            self.lastName = lastName
            self.email = email
            self.profileImageUrl = profileImageUrl
        }
}


