//
//  ClubEditView.swift
//  YU COMMUNITYS
//
//  Created by M7MD Sawan on 17/10/1446 AH.
//

import SwiftUI

struct ClubEditView: View {
    @Binding var club: Club
    @EnvironmentObject var clubViewModel: ClubViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String
    @State private var description: String
    @State private var logoURL: String
    @State private var email: String
    @State private var website: String
    @State private var registrationLink: String
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(club: Binding<Club>) {
        self._club = club
        
        // Initialize state properties from club
        _name = State(initialValue: club.wrappedValue.name)
        _description = State(initialValue: club.wrappedValue.description)
        _logoURL = State(initialValue: club.wrappedValue.logoURL ?? "")
        _email = State(initialValue: club.wrappedValue.email ?? "")
        _website = State(initialValue: club.wrappedValue.website ?? "")
        _registrationLink = State(initialValue: club.wrappedValue.registrationLink ?? "")
    }
    
    var formIsValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Club Information")) {
                    TextField("Club Name", text: $name)
                    
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    TextField("Logo URL", text: $logoURL)
                }
                
                Section(header: Text("Contact Information")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    
                    TextField("Website", text: $website)
                        .keyboardType(.URL)
                    
                    TextField("Registration Link", text: $registrationLink)
                        .keyboardType(.URL)
                }
                
                Section {
                    Button(action: saveClub) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .padding()
                            .background(formIsValid ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!formIsValid)
                }
            }
            .navigationTitle("Edit Club")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Form Validation"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func saveClub() {
        guard formIsValid else {
            alertMessage = "Please fill out all required fields."
            showingAlert = true
            return
        }
        
        // Update the club binding
        club.name = name
        club.description = description
        club.logoURL = logoURL.isEmpty ? nil : logoURL
        club.email = email.isEmpty ? nil : email
        club.website = website.isEmpty ? nil : website
        club.registrationLink = registrationLink.isEmpty ? nil : registrationLink
        
        // Update in the view model
        clubViewModel.updateClub(club)
        
        // Dismiss the sheet
        presentationMode.wrappedValue.dismiss()
    }
}
