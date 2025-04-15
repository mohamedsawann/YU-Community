//
//  HomeView.swift
//  YU COMMUNITYS
//
//  Created by M7MD Sawan on 17/10/1446 AH.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var clubViewModel: ClubViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Logo and header
                    HStack {
                        Spacer()
                        VStack {
                            Image(systemName: "person.3.fill")
                                .resizable()
                                .frame(width: 40, height: 30)
                                .foregroundColor(.orange)
                            Text("YU Community")
                                .font(.headline)
                                .foregroundColor(.orange)
                        }
                        Spacer()
                    }
                    .padding(.top)
                    
                    // Posts list
                    ForEach(clubViewModel.posts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            PostCardView(post: post)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationBarTitle("", displayMode: .inline)
            .toolbar {
                if authViewModel.currentAdmin != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: AddPostView()) {
                            Image(systemName: "plus")
                        }
                    }
                } else {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            authViewModel.showLoginModal = true
                        }) {
                            Image(systemName: "person.circle")
                        }
                    }
                }
            }
        }
    }
}

struct PostCardView: View {
    let post: Post
    @EnvironmentObject var clubViewModel: ClubViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var club: Club? {
        clubViewModel.clubs.first(where: { $0.id == post.clubId })
    }
    
    var canDelete: Bool {
        if let admin = authViewModel.currentAdmin {
            if admin.adminType == .appAdmin {
                return true
            } else if admin.adminType == .clubAdmin && admin.clubAffiliation == club?.name {
                return true
            }
        }
        return false
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let imageURL = post.imageURL {
                // In a real app, use AsyncImage for loading from URL
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.3))
                    .clipped()
                    .cornerRadius(10)
                    .overlay(
                        Text("Image: \(imageURL)")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(5)
                            .padding(8),
                        alignment: .bottomLeading
                    )
            }
            
            Text(post.title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(post.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            if let club = club {
                HStack {
                    Image(systemName: "building.2")
                    Text(club.name)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            HStack {
                Image(systemName: "calendar")
                Text(formattedDate(post.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if canDelete {
                    Button(action: {
                        clubViewModel.deletePost(postId: post.id)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
