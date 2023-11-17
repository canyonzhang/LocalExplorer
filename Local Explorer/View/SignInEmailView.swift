//
//  SignInEmailView.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/20/23.
//

import SwiftUI

@MainActor
final class SignInEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }

        Task {
            do {
                // This should call a signIn method, not createUser
                let returnedUserData = try await AuthenticationManager.shared.signIn(email: email, password: password)
                print("Success")
                print(returnedUserData)
            } catch {
                print("Error: \(error)")
            }
        }
    }

}

struct SignInEmailView: View {
    
    @StateObject private var viewModel = SignInEmailViewModel()
    
    // Simple View that contains email password and a sign in button in a nav view, uses the SignInWithEmailViewModel methods
    var body: some View {
        NavigationView {
            VStack {
                TextField("Email...", text: $viewModel.email)
                    .padding(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15)) // Add padding inside TextField
                    .background(Color.gray.opacity(0.2)) // Adjust background color for visibility
                    .cornerRadius(10)
                    .padding(.horizontal) // Add padding around the TextField
                
                SecureField("Password...", text: $viewModel.password)
                    .padding(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15)) // Same padding for SecureField
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal) // Same padding for consistency
                
                Button(action: {
                    viewModel.signIn()
                }) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55) // Set the height of the button
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                Spacer()
            }
            .navigationTitle("Sign In With Email")
        }
    }
}

struct SignInEmailView_Previews: PreviewProvider {
    static var previews: some View {
        SignInEmailView()
    }
}

