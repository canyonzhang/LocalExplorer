//
//  RegisterView.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/20/23.
//

import SwiftUI
import FirebaseAuth

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var showAlert = false
    @Published var alertMessage = ""

    // Function to register users and insert them into database with AuthenticationManager
    func register() {
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty else {
            print("Missing information.")
            showAlertWithMessage("Missing information. Please fill out all fields.")
            return
        }
        Task {
            do {
                try await AuthenticationManager.shared.register(firstName: firstName, lastName: lastName, email: email, password: password)
                print("registered user successfully")
            } catch {
                handleRegistrationError(error)
            }
        }
    }
    private func showAlertWithMessage(_ message: String) {
            alertMessage = message
            showAlert = true
        }
    
    // Function to handle various registration errors
    private func handleRegistrationError(_ error: Error) {
        let nsError = error as NSError

        if nsError.domain == AuthErrorDomain {
            // Directly use the rawValue for comparison
            let errorCode = nsError.code
            switch errorCode {
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                print("Email already in use")
                showAlertWithMessage("This email is already in use. Please use a different email.")
            default:
                showAlertWithMessage("Error: \(error.localizedDescription)")
            }
        } else {
            showAlertWithMessage("Error: \(error.localizedDescription)")
        }
    }
}

struct RegisterView: View {
    
    @StateObject private var viewModel = RegisterViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("First Name...", text: $viewModel.firstName)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                TextField("Last Name...", text: $viewModel.lastName)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                TextField("Email...", text: $viewModel.email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                SecureField("Password...", text: $viewModel.password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                Button(action: {
                    viewModel.register()
                }) {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                Spacer()
            }
            .navigationTitle("Register")
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Alert"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))}
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}

