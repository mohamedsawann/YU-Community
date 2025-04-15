//
//  AddPostView.swift
//  YU COMMUNITYS
//
//  Created by M7MD Sawan on 17/10/1446 AH.
//

import SwiftUI

struct AddPostView: View {
    @EnvironmentObject var clubViewModel: ClubViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var content = ""
    @State private var selectedClubId: UUID?
    @State private var imageURL: String?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var filteredClubs: [Club] {
        if authViewModel.currentAdmin?.adminType == .appAdmin {
            return clubViewModel.clubs
        } else if let clubAffiliation = authViewModel.currentAdmin?.clubAffiliation {
            return clubViewModel.clubs.filter { $0.name == clubAffiliation }
        } else {
            return []
        }
    }
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedClubId != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Post Details")) {
                    TextField("Title", text: $title)
                    
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $description)
                            .frame(minHeight: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Content")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $content)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                
                Section(header: Text("Club Affiliation")) {
                    Picker("Select Club", selection: $selectedClubId) {
                        Text("Select a club").tag(nil as UUID?)
                        
                        ForEach(filteredClubs) { club in
                            Text(club.name).tag(club.id as UUID?)
                        }
                    }
                }
                
                Section(header: Text("Image")) {
                    TextField("Image URL (optional)", text: Binding(
                        get: { imageURL ?? "" },
                        set: { imageURL = $0.isEmpty ? nil : $0 }
                    ))
                }
                
                Section {
                    Button(action: createPost) {
                        Text("Create Post")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .padding()
                            .background(isFormValid ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("New Post")
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
    
    private func createPost() {
        guard isFormValid else {
            alertMessage = "Please fill out all required fields."
            showingAlert = true
            return
        }
        
        if let clubId = selectedClubId {
            clubViewModel.addPost(
                title: title,
                content: content,
                description: description,
                clubId: clubId,
                imageURL: imageURL
            )
            
            presentationMode.wrappedValue.dismiss()
        }
    }
}
