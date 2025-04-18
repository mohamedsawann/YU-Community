import SwiftUI

struct ClubsView: View {
    @EnvironmentObject var clubViewModel: ClubViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appSettings: AppSettingsViewModel
    @State private var searchText = ""
    
    var filteredClubs: [Club] {
        if searchText.isEmpty {
            return clubViewModel.clubs
        } else {
            return clubViewModel.clubs.filter { club in
                club.name.localizedCaseInsensitiveContains(searchText) ||
                club.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search clubs...", text: $searchText)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Clubs grid
                ScrollView {
                    // Simple two-column layout using VStack and HStack
                    VStack(spacing: 15) {
                        // Process clubs in pairs
                        ForEach(0..<(filteredClubs.count + 1) / 2, id: \.self) { rowIndex in
                            HStack(spacing: 15) {
                                // Left column
                                if rowIndex * 2 < filteredClubs.count {
                                    clubCard(filteredClubs[rowIndex * 2])
                                }
                                
                                // Right column
                                if rowIndex * 2 + 1 < filteredClubs.count {
                                    clubCard(filteredClubs[rowIndex * 2 + 1])
                                } else {
                                    // Empty space to maintain grid alignment
                                    Spacer()
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(appSettings.language == .arabic ? "النوادي" : "Clubs")
            .environment(\.layoutDirection, appSettings.language.isRTL ? .rightToLeft : .leftToRight)
        }
        .id(appSettings.language.rawValue)
    }
    
    // Helper function to create a club card
    @ViewBuilder
    func clubCard(_ club: Club) -> some View {
        NavigationLink(destination: ClubDetailView(club: club)) {
            ZStack(alignment: .bottom) {
                // Club background
                Rectangle()
                    .fill(Color.orange.opacity(0.2))
                    .cornerRadius(12)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                
                // Club info
                VStack(alignment: .center, spacing: 4) {
                    // Club logo
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 50, height: 50)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        if let logoURL = club.logoURL, !logoURL.isEmpty {
                            Image(logoURL)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } else {
                            Text(String(club.name.prefix(1)))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                    }
                    .offset(y: -25)
                    .padding(.bottom, -15)
                    
                    Text(appSettings.language == .arabic && club.nameAr != nil ? club.nameAr! : club.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                    
                    Text(appSettings.language == .arabic ? "دخول" : "Enter")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                        .background(Color.black)
                        .cornerRadius(20)
                        .padding(.bottom, 10)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
