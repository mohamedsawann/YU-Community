//
//  ClubsView.swift
//  YU COMMUNITYS
//
//  Created by M7MD Sawan on 17/10/1446 AH.
//

import SwiftUI

struct ClubsView: View {
    @EnvironmentObject var clubViewModel: ClubViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(clubViewModel.clubs) { club in
                    NavigationLink(destination: ClubDetailView(club: club)) {
                        ClubRowView(club: club)
                    }
                }
            }
            .navigationTitle("Clubs")
        }
    }
}

struct ClubRowView: View {
    let club: Club
    
    var body: some View {
        HStack(spacing: 15) {
            // Club logo
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Text(String(club.name.prefix(1)))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(club.name)
                    .font(.headline)
                
                Text(club.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 8)
    }
}
