import SwiftUI

struct ClubDetailView: View {
    @State var club: Club
    @EnvironmentObject var clubViewModel: ClubViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appSettings: AppSettingsViewModel
    @State private var showingEditView = false
    
    var canEdit: Bool {
        authViewModel.canEditClub(club)
    }
    
    var clubPosts: [Post] {
        clubViewModel.approvedPostsForClub(clubId: club.id)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Club Header
                VStack(alignment: .center, spacing: 15) {
                    // Club logo
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        if let logoURL = club.logoURL, !logoURL.isEmpty {
                            // In a real app, use AsyncImage for remote images
                            Image(logoURL)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                        } else {
                            Text(String((appSettings.language == .arabic && club.nameAr != nil ? club.nameAr! : club.name).prefix(1)))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text(appSettings.language == .arabic && club.nameAr != nil ? club.nameAr! : club.name)
                        .font(.title)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                
                // Club Details
                VStack(alignment: .leading, spacing: 15) {
                    Group {
                        Text(appSettings.language == .arabic ? "نبذة عن النادي" : "About")
                            .font(.headline)
                        
                        Text(appSettings.language == .arabic && club.descriptionAr != nil ? club.descriptionAr! : club.description)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Contact Information
                    Group {
                        Text(appSettings.language == .arabic ? "معلومات الاتصال" : "Contact Information")
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
                                Label(appSettings.language == .arabic ? "رابط التسجيل" : "Registration Link", systemImage: "link")
                                Text(registrationLink)
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                    
                    // Club Posts
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(appSettings.language == .arabic ? "منشورات النادي" : "Club Posts")
                                .font(.headline)
                            
                            Spacer()
                            
                            if canEdit {
                                NavigationLink(destination: AddPostView()) {
                                    Label(appSettings.language == .arabic ? "منشور جديد" : "New Post", systemImage: "plus")
                                        .font(.caption)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if clubPosts.isEmpty {
                            Text(appSettings.language == .arabic ? "لا توجد منشورات حتى الآن" : "No posts yet")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(clubPosts) { post in
                                NavigationLink(destination: PostDetailView(post: post)) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(appSettings.language == .arabic && post.titleAr != nil ? post.titleAr! : post.title)
                                            .font(.headline)
                                        
                                        Text(appSettings.language == .arabic && post.descriptionAr != nil ? post.descriptionAr! : post.description)
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
        }
        .environment(\.layoutDirection, appSettings.language.isRTL ? .rightToLeft : .leftToRight)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
