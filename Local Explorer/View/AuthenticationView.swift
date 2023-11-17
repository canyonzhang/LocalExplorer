//
//  AuthenticationView.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/20/23.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    // Sign in with google helper method
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        print("Signing in with google")
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    }
}


struct AuthenticationView: View {
    @StateObject var viewModel = AuthenticationViewModel()
    
    // Body lists 3 views in a NavigationView/Vstack, sign in, register, sign in with google
    var body: some View {
        NavigationView{
            VStack { 
                NavigationLink {
                    SignInEmailView()
                } label: {
                    Text("Sign In With Email")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                NavigationLink {
                    RegisterView()
                } label: {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)){
                    Task {
                        do {
                            try await viewModel.signInGoogle()
                        }
                        catch {
                            print("ERROR SIGNING IN WITH GOOGLE, IT IS", error)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Local Explorer")
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}

