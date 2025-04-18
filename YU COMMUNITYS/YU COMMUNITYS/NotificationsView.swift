import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var clubViewModel: ClubViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appSettings: AppSettingsViewModel
    @State private var selectedCategory: String? = nil
    @State private var showingClearConfirmation = false
    
    // Define notification categories
    var categories: [(String, String, String, String)] {
        let basicCategories = [
            ("all", "All", "الكل", "bell.fill"),
            ("events", "Events", "الفعاليات", "calendar")
        ]
        
        // Only show admin categories to admins
        let adminCategories = [
            ("approvals", "Approvals", "الموافقات", "clock.fill"),
            ("approved", "Approved", "تمت الموافقة", "checkmark.circle"),
            ("rejected", "Rejected", "تم الرفض", "xmark.circle")
        ]
        
        // Only add admin categories if the user is an admin
        if authViewModel.currentAdmin?.adminType == .appAdmin ||
           authViewModel.currentAdmin?.adminType == .clubAdmin {
            return basicCategories + adminCategories
        } else {
            return basicCategories
        }
    }
    
    var filteredNotifications: [Notification] {
        // First filter by user role
        let userFiltered = clubViewModel.filteredNotificationsForUser(admin: authViewModel.currentAdmin)
        
        // Then filter by selected category if any
        guard let category = selectedCategory else {
            // Default - all notifications for the user
            return userFiltered.sorted(by: { $0.date > $1.date })
        }
        
        switch category {
        case "events":
            return userFiltered.filter {
                $0.notificationType == .newEvent || $0.notificationType == .upcomingEvent
            }.sorted(by: { $0.date > $1.date })
        case "approvals":
            return userFiltered.filter {
                $0.notificationType == .postApproval
            }.sorted(by: { $0.date > $1.date })
        case "approved":
            return userFiltered.filter {
                $0.notificationType == .postApproved
            }.sorted(by: { $0.date > $1.date })
        case "rejected":
            return userFiltered.filter {
                $0.notificationType == .postDisapproved
            }.sorted(by: { $0.date > $1.date })
        default:
            return userFiltered.sorted(by: { $0.date > $1.date })
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.0) { id, name, arabicName, icon in
                            CategoryButton(
                                id: id,
                                title: appSettings.language == .arabic ? arabicName : name,
                                icon: icon,
                                isSelected: selectedCategory == id || (selectedCategory == nil && id == "all"),
                                selectCategory: { category in
                                    selectedCategory = category == "all" ? nil : category
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(.systemGray4)),
                    alignment: .bottom
                )
                
                if filteredNotifications.isEmpty {
                    // Empty state - takes full remaining height
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "bell.slash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                        
                        Text(appSettings.language == .arabic ? "لا توجد إشعارات في هذه الفئة" : "No notifications in this category")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure full size
                    .background(Color(.systemGroupedBackground))
                } else {
                    // Notifications list
                    List {
                        ForEach(filteredNotifications) { notification in
                            NotificationCell(notification: notification)
                                .onAppear {
                                    // Mark as read when it comes into view
                                    if !notification.isRead {
                                        clubViewModel.markNotificationAsRead(id: notification.id)
                                    }
                                }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle(appSettings.language == .arabic ? "الإشعارات" : "Notifications")
            .toolbar {
                if !filteredNotifications.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingClearConfirmation = true
                        }) {
                            Text(appSettings.language == .arabic ? "تحديد الكل كمقروء" : "Mark All as Read")
                                .font(.caption)
                        }
                    }
                }
            }
            .alert(isPresented: $showingClearConfirmation) {
                Alert(
                    title: Text(appSettings.language == .arabic ? "تعيين الكل كمقروء" : "Mark All as Read"),
                    message: Text(appSettings.language == .arabic ? "هل أنت متأكد من أنك تريد تعيين جميع الإشعارات كمقروءة؟" : "Are you sure you want to mark all notifications as read?"),
                    primaryButton: .default(Text(appSettings.language == .arabic ? "نعم" : "Yes")) {
                        clubViewModel.markAllNotificationsAsRead()
                    },
                    secondaryButton: .cancel(Text(appSettings.language == .arabic ? "إلغاء" : "Cancel"))
                )
            }
            .environment(\.layoutDirection, appSettings.language.isRTL ? .rightToLeft : .leftToRight)
        }
        .id(appSettings.language.rawValue)
    }
}

struct CategoryButton: View {
    let id: String
    let title: String
    let icon: String
    let isSelected: Bool
    let selectCategory: (String) -> Void
    
    var body: some View {
        Button(action: {
            selectCategory(id)
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.orange : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct NotificationCell: View {
    let notification: Notification
    @EnvironmentObject var clubViewModel: ClubViewModel
    @EnvironmentObject var appSettings: AppSettingsViewModel
    
    var club: Club? {
        clubViewModel.clubs.first(where: { $0.id == notification.clubId })
    }
    
    var post: Post? {
        if let postId = notification.relatedPostId {
            return clubViewModel.posts.first(where: { $0.id == postId })
        }
        return nil
    }
    
    var event: Event? {
        if let eventId = notification.relatedEventId {
            return clubViewModel.events.first(where: { $0.id == eventId })
        }
        return nil
    }
    
    var destination: some View {
        Group {
            if let post = post {
                PostDetailView(post: post)
            } else if let event = event {
                Text("Event: \(event.title)")
                    .font(.title)
                    .padding()
            } else {
                EmptyView()
            }
        }
    }
    
    var notificationColor: Color {
        switch notification.notificationType {
        case .newEvent, .upcomingEvent:
            return .green
        case .postApproval:
            return .orange
        case .postApproved:
            return .blue
        case .postDisapproved:
            return .red
        }
    }
    
    var iconName: String {
        switch notification.notificationType {
        case .newEvent, .upcomingEvent:
            return "calendar"
        case .postApproval:
            return "doc.badge.clock"
        case .postApproved:
            return "checkmark.circle"
        case .postDisapproved:
            return "xmark.circle"
        }
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 15) {
                // Notification icon
                ZStack {
                    Circle()
                        .fill(notificationColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: iconName)
                        .foregroundColor(notificationColor)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    // Notification title
                    HStack {
                        Text(appSettings.language == .arabic && notification.titleAr != nil ? notification.titleAr! : notification.title)
                            .font(.headline)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if !notification.isRead {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 10, height: 10)
                        }
                    }
                    
                    // Notification message
                    Text(appSettings.language == .arabic && notification.messageAr != nil ? notification.messageAr! : notification.message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Club name and time
                    HStack {
                        if let club = club {
                            // Club logo
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
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Text(relativeTimeString(for: notification.date))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.vertical, 5)
        }
    }
    
    func relativeTimeString(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let day = components.day, day > 0 {
            return "\(day)d \(appSettings.language == .arabic ? "مضت" : "ago")"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)h \(appSettings.language == .arabic ? "مضت" : "ago")"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)m \(appSettings.language == .arabic ? "مضت" : "ago")"
        } else {
            return appSettings.language == .arabic ? "الآن" : "Just now"
        }
    }
}
