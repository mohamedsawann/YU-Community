import SwiftUI

struct HomeView: View {
    @EnvironmentObject var clubViewModel: ClubViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appSettings: AppSettingsViewModel
    
    var approvedPosts: [Post] {
        // Only show approved posts to everyone - hide any pending posts
        return clubViewModel.posts.filter { $0.isApproved == true && !$0.isPendingApproval }
    }
    
    var pendingPosts: [Post] {
        // Get all pending posts
        let allPending = clubViewModel.posts.filter { $0.isPendingApproval }
        
        // If user is an app admin, show all pending posts
        if authViewModel.currentAdmin?.adminType == .appAdmin {
            return allPending
        }
        
        // If user is a club admin, only show pending posts for their own club
        if let admin = authViewModel.currentAdmin,
           admin.adminType == .clubAdmin,
           let clubName = admin.clubAffiliation {
            
            // Find the club ID for this club admin
            if let clubId = clubViewModel.clubs.first(where: { $0.name == clubName })?.id {
                // Filter pending posts to only show those from this club
                return allPending.filter { $0.clubId == clubId }
            }
        }
        
        // For regular users or if filtering failed, return empty array
        return []
    }
    
    var showPendingSection: Bool {
        return !pendingPosts.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Logo and header
                    HStack {
                        Spacer()
                        VStack {
                                                    Image("yu_community_logo")
                                                                                    .resizable()
                                                                                    .scaledToFit()
                                                                                    .frame(width: 80, height: 80)
                                                }
                                                Spacer()
                                            }
                                            .padding(.top)
                    
                    
                                       // Pending approvals section for app admins and relevant club admins
                                       if showPendingSection {
                                           VStack(alignment: .leading, spacing: 10) {
                                               Text(appSettings.language == .arabic ? "منشورات تنتظر الموافقة" : "Posts Pending Approval")
                                                   .font(.title2)
                                                   .fontWeight(.bold)
                                                   .padding(.horizontal)
                                               
                                               ForEach(pendingPosts) { post in
                                                   PendingPostCard(post: post)
                                               }
                                           }
                                           .padding(.bottom)
                                           
                                           Divider()
                                       }
                                       
                                       // Only show the regular posts section if there are approved posts or the user has no admin rights
                                       if !approvedPosts.isEmpty || authViewModel.currentAdmin == nil {
                                           // Recent approved posts section
                                           Text(appSettings.language == .arabic ? "أحدث المنشورات" : "Recent Posts")
                                               .font(.title2)
                                               .fontWeight(.bold)
                                               .padding(.horizontal)
                                           
                                           // Posts list - only approved, non-pending posts
                                           ForEach(approvedPosts) { post in
                                               NavigationLink(destination: PostDetailView(post: post)) {
                                                   PostCardView(post: post)
                                               }
                                               .buttonStyle(PlainButtonStyle())
                                           }
                                       } else if approvedPosts.isEmpty && authViewModel.currentAdmin != nil && !showPendingSection {
                                           // Show a message when admin is logged in but there are no approved posts yet
                                           VStack(spacing: 20) {
                                               Spacer()
                                               
                                               Image(systemName: "doc.text")
                                                   .resizable()
                                                   .scaledToFit()
                                                   .frame(width: 60, height: 60)
                                                   .foregroundColor(.gray)
                                               
                                               Text(appSettings.language == .arabic ? "لا توجد منشورات معتمدة بعد" : "No approved posts yet")
                                                   .font(.title2)
                                                   .fontWeight(.medium)
                                                   .foregroundColor(.gray)
                                                   .multilineTextAlignment(.center)
                                               
                                               Text(appSettings.language == .arabic ? "ابدأ بإنشاء منشور جديد من خلال النقر على زر +" : "Start by creating a new post by clicking the + button")
                                                   .font(.body)
                                                   .foregroundColor(.secondary)
                                                   .multilineTextAlignment(.center)
                                                   .padding(.horizontal)
                                               
                                               Spacer()
                                           }
                                           .padding()
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
                               .environment(\.layoutDirection, appSettings.language.isRTL ? .rightToLeft : .leftToRight)
                           }
                           .id(appSettings.language.rawValue)
                       }
                   }

                   struct PendingPostCard: View {
                       let post: Post
                       @EnvironmentObject var clubViewModel: ClubViewModel
                       @EnvironmentObject var appSettings: AppSettingsViewModel
                       @State private var showingApprovalAlert = false
                       @State private var showingDisapprovalAlert = false
                       @State private var disapprovalReason = ""
                       
                       var club: Club? {
                           clubViewModel.clubs.first(where: { $0.id == post.clubId })
                       }
                       
                       var body: some View {
                           VStack(alignment: .leading, spacing: 10) {
                               HStack {
                                   Text(appSettings.language == .arabic && post.titleAr != nil ? post.titleAr! : post.title)
                                       .font(.headline)
                                       .foregroundColor(.primary)
                                   
                                   Spacer()
                                   
                                   Text(appSettings.language == .arabic ? "قيد الموافقة" : "Pending Approval")
                                       .font(.caption)
                                       .foregroundColor(.orange)
                                       .padding(.horizontal, 8)
                                       .padding(.vertical, 4)
                                       .background(Color.orange.opacity(0.1))
                                       .cornerRadius(4)
                               }
                               
                               Text(appSettings.language == .arabic && post.descriptionAr != nil ? post.descriptionAr! : post.description)
                                   .font(.subheadline)
                                   .foregroundColor(.secondary)
                                   .lineLimit(2)
                               
                               if let club = club {
                                   HStack {
                                       // Show club logo if available
                                       if let logoURL = club.logoURL, !logoURL.isEmpty {
                                           Image(logoURL)
                                               .resizable()
                                               .scaledToFill()
                                               .frame(width: 20, height: 20)
                                               .clipShape(Circle())
                                       } else {
                                           Circle()
                                               .fill(Color.orange.opacity(0.2))
                                               .frame(width: 20, height: 20)
                                               .overlay(
                                                   Text(String((appSettings.language == .arabic && club.nameAr != nil ? club.nameAr! : club.name).prefix(1)))
                                                       .font(.system(size: 10))
                                                       .fontWeight(.bold)
                                                       .foregroundColor(.orange)
                                               )
                                       }
                                       
                                       Text(appSettings.language == .arabic && club.nameAr != nil ? club.nameAr! : club.name)
                                           .font(.caption)
                                           .foregroundColor(.orange)
                                   }
                               }
                               
                               // Post link
                               NavigationLink(destination: PostDetailView(post: post)) {
                                   Text(appSettings.language == .arabic ? "عرض التفاصيل" : "View Details")
                                       .font(.caption)
                                       .padding(.vertical, 4)
                               }
                               
                               // Approval buttons
                               HStack {
                                   Button(action: {
                                       showingApprovalAlert = true
                                   }) {
                                       Text(appSettings.language == .arabic ? "موافقة" : "Approve")
                                           .font(.caption)
                                           .padding(.horizontal, 20)
                                           .padding(.vertical, 8)
                                           .background(Color.green)
                                           .foregroundColor(.white)
                                           .cornerRadius(8)
                                   }
                                   
                                   Button(action: {
                                       showingDisapprovalAlert = true
                                   }) {
                                       Text(appSettings.language == .arabic ? "رفض" : "Disapprove")
                                           .font(.caption)
                                           .padding(.horizontal, 20)
                                           .padding(.vertical, 8)
                                           .background(Color.red)
                                           .foregroundColor(.white)
                                           .cornerRadius(8)
                                   }
                               }
                           }
                           .padding()
                           .background(Color(.systemGray6))
                           .cornerRadius(15)
                           .padding(.horizontal)
                           .alert(isPresented: $showingApprovalAlert) {
                               Alert(
                                   title: Text(appSettings.language == .arabic ? "تأكيد الموافقة" : "Confirm Approval"),
                                   message: Text(appSettings.language == .arabic ? "هل أنت متأكد من أنك تريد الموافقة على هذا المنشور؟" : "Are you sure you want to approve this post?"),
                                   primaryButton: .default(Text(appSettings.language == .arabic ? "نعم" : "Yes")) {
                                       clubViewModel.approvePost(postId: post.id)
                                   },
                                   secondaryButton: .cancel(Text(appSettings.language == .arabic ? "إلغاء" : "Cancel"))
                               )
                           }
                           .sheet(isPresented: $showingDisapprovalAlert) {
                               PostDisapprovalView(postId: post.id)
                           }
                       }
                   }

                   struct PostDisapprovalView: View {
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

                   struct PostCardView: View {
                       let post: Post
                       @EnvironmentObject var clubViewModel: ClubViewModel
                       @EnvironmentObject var authViewModel: AuthViewModel
                       @EnvironmentObject var appSettings: AppSettingsViewModel
                       
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
                               if let image = post.image {
                                   // Use the actual image data
                                   Image(uiImage: image)
                                       .resizable()
                                       .aspectRatio(contentMode: .fit)
                                       .frame(height: 200)
                                       .frame(maxWidth: .infinity)
                                       .background(Color.gray.opacity(0.1))
                                       .cornerRadius(10)
                               } else if let imageURL = post.imageURL {
                                   // Fallback for URLs that couldn't be loaded
                                   Image(systemName: "photo")
                                       .resizable()
                                       .aspectRatio(contentMode: .fit)
                                       .frame(height: 200)
                                       .frame(maxWidth: .infinity)
                                       .background(Color.gray.opacity(0.3))
                                       .cornerRadius(10)
                                       .overlay(
                                           Text(appSettings.language == .arabic ? "صورة: \(imageURL)" : "Image: \(imageURL)")
                                               .foregroundColor(.white)
                                               .padding(8)
                                               .background(Color.black.opacity(0.7))
                                               .cornerRadius(5)
                                               .padding(8),
                                           alignment: .bottomLeading
                                       )
                               }
                               
                               Text(appSettings.language == .arabic && post.titleAr != nil ? post.titleAr! : post.title)
                                   .font(.title2)
                                   .fontWeight(.bold)
                               
                               Text(appSettings.language == .arabic && post.descriptionAr != nil ? post.descriptionAr! : post.description)
                                   .font(.body)
                                   .foregroundColor(.secondary)
                                   .lineLimit(2)
                               
                               if let club = club {
                                   HStack {
                                       // Show club logo if available
                                       if let logoURL = club.logoURL, !logoURL.isEmpty {
                                           Image(logoURL)
                                               .resizable()
                                               .scaledToFill()
                                               .frame(width: 20, height: 20)
                                               .clipShape(Circle())
                                       } else {
                                           Circle()
                                               .fill(Color.orange.opacity(0.2))
                                               .frame(width: 20, height: 20)
                                               .overlay(
                                                   Text(String((appSettings.language == .arabic && club.nameAr != nil ? club.nameAr! : club.name).prefix(1)))
                                                       .font(.system(size: 10))
                                                       .fontWeight(.bold)
                                                       .foregroundColor(.orange)
                                               )
                                       }
                                       
                                       Text(appSettings.language == .arabic && club.nameAr != nil ? club.nameAr! : club.name)
                                           .font(.caption)
                                           .foregroundColor(.orange)
                                   }
                               }
                               
                               HStack {
                                   Image(systemName: "calendar")
                                   Text(formattedDate(post.date))
                                       .font(.caption)
                                       .foregroundColor(.secondary)
                                   
                                   Spacer()
                                   
                                   // Remove pending approval badge in main posts list - these should be filtered out already
                                   // but this is a safety check
                                   
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
