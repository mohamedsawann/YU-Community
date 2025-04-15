//
//  PostDetailView.swift
//  YU COMMUNITYS
//
//  Created by M7MD Sawan on 17/10/1446 AH.
//

import SwiftUI

struct PostDetailView: View {
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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Post image
                if let imageURL = post.imageURL {
                    // In a real app, use AsyncImage for loading from URL
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.3))
                        .clipped()
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
                
                // Post details
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text(post.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        if canDelete {
                            Button(action: {
                                clubViewModel.deletePost(postId: post.id)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .padding(8)
                                    .background(Color.red.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Club info with navigation
                    if let club = club {
                        NavigationLink(destination: ClubDetailView(club: club)) {
                            HStack {
                                Image(systemName: "building.2")
                                Text(club.name)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 5)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                        Text(formattedDate(post.date))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Description section
                    Text("Description")
                        .font(.headline)
                    
                    Text(post.description)
                        .font(.body)
                        .padding(.bottom, 10)
                    
                    // Content section
                    Text("Details")
                        .font(.headline)
                    
                    Text(post.content)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}
