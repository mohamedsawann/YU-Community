//
//  ClubDetailView.swift
//  YU COMMUNITYS
//
//  Created by M7MD Sawan on 17/10/1446 AH.
//

import SwiftUI

struct ClubDetailView: View {
    @State var club: Club
    @EnvironmentObject var clubViewModel: ClubViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingEditView = false
    
    var canEdit: Bool {
        authViewModel.canEditClub(club)
    }
    
    var clubPosts: [Post] {
        clubViewModel.postsForClub(clubId: club.id)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Club Header
                VStack(alignment: .center, spacing: 15) {
                    // Club logo
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Text(String(club.name.prefix(1)))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Text(club.name)
                        .font(.title)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                
                // Club Details
                VStack(alignment: .leading, spacing: 15) {
                    Group {
                        Text("About")
                            .font(.headline)
                        
                        Text(club.description)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Contact Information
                    Group {
                        Text("Contact Information")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            if let email = club.email {
                                Label(email, systemImage: "envelope")
                            }
                            
                            if let website = club.website {
                                Label(website, systemImage: "globe")
                            }
                            
                            if let registrationLink = club.registrationLink {
                                Label("Registration Link", systemImage: "link")
                                Text(registrationLink)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                    
                    // Club Posts
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Club Posts")
                                .font(.headline)
                            
                            Spacer()
                            
                            if canEdit {
                                NavigationLink(destination: AddPostView()) {
                                    Label("New Post", systemImage: "plus")
                                        .font(.caption)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if clubPosts.isEmpty {
                            Text("No posts yet")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(clubPosts) { post in
                                NavigationLink(destination: PostDetailView(post: post)) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(post.title)
                                            .font(.headline)
                                        
                                        Text(post.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                        
                                        HStack {
                                            Image(systemName: "calendar")
                                                .font(.caption)
                                            Text(formattedDate(post.date))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if canEdit {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingEditView = true
                    }) {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            ClubEditView(club: $club)
                .environmentObject(clubViewModel)
        }
        // Update the club reference when it changes in the ViewModel
        .onAppear {
            if let updatedClub = clubViewModel.clubs.first(where: { $0.id == club.id }) {
                self.club = updatedClub
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
