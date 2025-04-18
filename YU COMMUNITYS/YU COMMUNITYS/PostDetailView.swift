import SwiftUI

struct PostDetailView: View {
    let post: Post
    @EnvironmentObject var clubViewModel: ClubViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appSettings: AppSettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteAlert = false
    
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
    
    var canApprove: Bool {
        return authViewModel.currentAdmin?.adminType == .appAdmin && post.isPendingApproval
    }
    
    var isDisapproved: Bool {
        return post.isApproved == false
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Post title
                Text(appSettings.language == .arabic && post.titleAr != nil ? post.titleAr! : post.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Post image if available from either source
                if let image = post.image {
                    // Use the actual image data
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(10)
                        .padding(.horizontal)
                } else if let imageURL = post.imageURL {
                    // Fallback for URLs that couldn't be loaded
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.3))
                        .clipped()
                        .overlay(
                            Text(appSettings.language == .arabic ? "صورة: \(imageURL)" : "Image: \(imageURL)")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(5)
                                .padding(8),
                            alignment: .bottomLeading
                        )
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                // Post metadata
                HStack {
                    if let club = club {
                        VStack(alignment: .leading) {
                            Text(appSettings.language == .arabic ? "النادي" : "Club")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                // Club logo
                                if let logoURL = club.logoURL, !logoURL.isEmpty {
                                    Image(logoURL)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.orange.opacity(0.2))
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Text(String((appSettings.language == .arabic && club.nameAr != nil ? club.nameAr! : club.name).prefix(1)))
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.orange)
                                        )
                                }
                                
                                Text(appSettings.language == .arabic && club.nameAr != nil ? club.nameAr! : club.name)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(appSettings.language == .arabic ? "تاريخ النشر" : "Published")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(formattedDate(post.date))
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
                
                // Status indicators
                if post.isPendingApproval {
                    HStack {
                        Label(
                            title: { Text(appSettings.language == .arabic ? "قيد الموافقة" : "Pending Approval") },
                            icon: { Image(systemName: "clock") }
                        )
                        .foregroundColor(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                } else if isDisapproved {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Label(
                                title: { Text(appSettings.language == .arabic ? "تم الرفض" : "Disapproved") },
                                icon: { Image(systemName: "xmark.circle") }
                            )
                            .foregroundColor(.red)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        if let reason = post.disapprovalReason {
                            Text(appSettings.language == .arabic ? "سبب الرفض:" : "Reason:")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            
                            Text(reason)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 5)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                
                // Content
                VStack(alignment: .leading, spacing: 10) {
                    Text(appSettings.language == .arabic ? "المحتوى" : "Content")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Text(appSettings.language == .arabic && post.contentAr != nil ? post.contentAr! : post.content)
                        .padding(.horizontal)
                }
                
                // Approval/Disapproval buttons for admins
                if canApprove {
                    Divider()
                        .padding(.vertical)
                    
                    HStack {
                        Button(action: {
                            clubViewModel.approvePost(postId: post.id)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Label(
                                title: { Text(appSettings.language == .arabic ? "موافقة" : "Approve") },
                                icon: { Image(systemName: "checkmark.circle") }
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        NavigationLink(destination: DisapprovalView(postId: post.id)) {
                            Label(
                                title: { Text(appSettings.language == .arabic ? "رفض" : "Disapprove") },
                                icon: { Image(systemName: "xmark.circle") }
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            if canDelete {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text(appSettings.language == .arabic ? "حذف المنشور" : "Delete Post"),
                message: Text(appSettings.language == .arabic ? "هل أنت متأكد من حذف هذا المنشور؟" : "Are you sure you want to delete this post?"),
                primaryButton: .destructive(Text(appSettings.language == .arabic ? "حذف" : "Delete")) {
                    clubViewModel.deletePost(postId: post.id)
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
        .environment(\.layoutDirection, appSettings.language.isRTL ? .rightToLeft : .leftToRight)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DisapprovalView: View {
    let postId: UUID
    @Environment(\.presentationMode) var presentationMode
    @State private var reason = ""
    @EnvironmentObject var clubViewModel: ClubViewModel
    @EnvironmentObject var appSettings: AppSettingsViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(appSettings.language == .arabic ? "سبب الرفض" : "Reason for Disapproval")) {
                    TextEditor(text: $reason)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button(action: {
                        clubViewModel.disapprovePost(postId: postId, reason: reason.isEmpty ? "No reason provided" : reason)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(appSettings.language == .arabic ? "رفض المنشور" : "Disapprove Post")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle(appSettings.language == .arabic ? "رفض المنشور" : "Disapprove Post")
            .navigationBarItems(trailing: Button(appSettings.language == .arabic ? "إلغاء" : "Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .environment(\.layoutDirection, appSettings.language.isRTL ? .rightToLeft : .leftToRight)
        }
    }
}
