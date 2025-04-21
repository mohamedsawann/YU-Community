import SwiftUI
import Combine

// MARK: - Data Models
struct Admin: Identifiable, Codable {
    let id: UUID
    let username: String
    let password: String
    let adminType: AdminType
    let clubAffiliation: String? // Only for club admins
}

enum AdminType: String, Codable {
    case appAdmin = "App Admin"
    case clubAdmin = "Club Admin"
}

struct Club: Identifiable, Codable {
    var id: UUID
    var name: String
    var description: String
    var logoURL: String?
    var email: String?
    var website: String?
    var registrationLink: String?
    var admins: [UUID] // References to Admin ids
    var nameAr: String? // Arabic name
    var descriptionAr: String? // Arabic description
}

struct Post: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let description: String
    let clubId: UUID
    let date: Date
    let imageURL: String?
    let imageData: Data?
    let isApproved: Bool?
    let disapprovalReason: String?
    let isPendingApproval: Bool
    let titleAr: String? // Arabic title
    let contentAr: String? // Arabic content
    let descriptionAr: String? // Arabic description
    
    // Helper computed property to get image from either source
    var image: UIImage? {
        if let imageData = imageData {
            return UIImage(data: imageData)
        } else if let imageURL = imageURL, let url = URL(string: imageURL), let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }
}

struct Event: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let clubId: UUID
    let startDate: Date
    let endDate: Date
    let location: String
    let isAllDay: Bool
    let titleAr: String? // Arabic title
    let descriptionAr: String? // Arabic description
    let locationAr: String? // Arabic location
}

struct Notification: Identifiable, Codable {
    let id: UUID
    let title: String
    let message: String
    let date: Date
    let isRead: Bool
    let relatedEventId: UUID?
    let relatedPostId: UUID?
    let clubId: UUID
    let notificationType: NotificationType
    let titleAr: String? // Arabic title
    let messageAr: String? // Arabic message
}

enum NotificationType: String, Codable {
    case newEvent = "New Event"
    case upcomingEvent = "Upcoming Event"
    case postApproval = "Post Approval"
    case postApproved = "Post Approved"
    case postDisapproved = "Post Disapproved"
    case newPost = "New Post"
}

class AppSettingsViewModel: ObservableObject {
    @Published var language: AppLanguage = .english
    @Published var isDarkMode: Bool = false
    
    enum AppLanguage: String {
        case english = "English"
        case arabic = "العربية"
        
        var isRTL: Bool {
            return self == .arabic
        }
    }
    
    var colorScheme: ColorScheme {
        return isDarkMode ? .dark : .light
    }
}

// MARK: - View Models
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentAdmin: Admin?
    @Published var errorMessage: String?
    @Published var showLoginModal = false
    
    private var admins: [Admin] = []
    
    init() {
        // Add app admins
        let appAdmin1 = Admin(id: UUID(), username: "admin1", password: "password1", adminType: .appAdmin, clubAffiliation: nil)
        let appAdmin2 = Admin(id: UUID(), username: "admin2", password: "password2", adminType: .appAdmin, clubAffiliation: nil)
        
        // Create club admins for all the clubs
        let clubsList = [
            "Student Council Club",
            "Industrial Engineering Club",
            "Engineering & Architecture Club",
            "Marketing Club",
            "Finance Club",
            "Management Club",
            "Debates and Pleadings Club",
            "Accounting Club",
            "Law Club",
            "MIS Club",
            "Nazaha Club",
            "Club of Social Responsibility",
            "Summit Club",
            "Stage & Art Club",
            "Google Developers Club",
            "ToastMasters",
            "TakeOne"
        ]
        
        var clubAdmins: [Admin] = []
        
        for (index, clubName) in clubsList.enumerated() {
            let clubAdmin = Admin(
                id: UUID(),
                username: "clubadmin\(index + 1)",
                password: "pass\(index + 1)",
                adminType: .clubAdmin,
                clubAffiliation: clubName
            )
            clubAdmins.append(clubAdmin)
        }
        
        admins = [appAdmin1, appAdmin2] + clubAdmins
    }
    
    func login(username: String, password: String) {
        if let admin = admins.first(where: { $0.username == username && $0.password == password }) {
            currentAdmin = admin
            isAuthenticated = true
            errorMessage = nil
            showLoginModal = false
        } else {
            errorMessage = "Invalid username or password"
        }
    }
    
    func logout() {
        currentAdmin = nil
        isAuthenticated = false
    }
    
    func canEditClub(_ club: Club) -> Bool {
        guard let admin = currentAdmin else { return false }
        
        if admin.adminType == .appAdmin {
            return true
        } else if admin.adminType == .clubAdmin && admin.clubAffiliation == club.name {
            return true
        }
        
        return false
    }
}

class ClubViewModel: ObservableObject {
    @Published var clubs: [Club] = []
    @Published var posts: [Post] = []
    @Published var events: [Event] = []
    @Published var notifications: [Notification] = []
    @Published var unreadNotificationCount: Int = 0
    
    init() {
        // Create all the clubs with their details
        let clubsData: [(String, String, String, String?)] = [
            ("Student Council Club", "The official student council representing student interests.", "student_council_logo.png", "مجلس الطلاب"),
            ("Industrial Engineering Club", "Promoting the field of industrial engineering and its applications.", "industrial_eng_logo.png", "نادي الهندسة الصناعية"),
            ("Engineering & Architecture Club", "Dedicated to engineering and architectural projects and competitions.", "eng_arch_logo.png", "نادي الهندسة والعمارة"),
            ("Marketing Club", "Exploring modern marketing strategies and practices.", "marketing_logo.png", "نادي التسويق"),
            ("Finance Club", "Focused on financial education and investment strategies.", "finance_logo.png", "نادي التمويل"),
            ("Management Club", "Developing leadership and management skills.", "management_logo.png", "نادي الإدارة"),
            ("Debates and Pleadings Club", "Enhancing debate and public speaking skills.", "debates_logo.png", "نادي المناظرات والمرافعات"),
            ("Accounting Club", "Promoting accounting knowledge and professional development.", "accounting_logo.png", "نادي المحاسبة"),
            ("Law Club", "Supporting law students and providing legal awareness.", "law_logo.png", "النادي القانوني"),
            ("MIS Club", "Exploring management information systems and technology.", "mis_logo.png", "نادي نظم المعلومات الإدارية"),
            ("Nazaha Club", "Promoting integrity and transparency in professional conduct.", "nazaha_logo.png", "نادي النزاهة"),
            ("Club of Social Responsibility", "Engaging in community service and social initiatives.", "social_responsibility_logo.png", "نادي المسؤولية الاجتماعية"),
            ("Summit Club", "Leadership development and personal growth initiatives.", "summit_logo.png", "نادي القمة"),
            ("Stage & Art Club", "Focused on theatrical performances and artistic expression.", "stage_art_logo.png", "نادي المسرح والفنون"),
            ("Google Developers Club", "Club for developers interested in Google technologies.", "gdsc_logo.png", "نادي مطوري جوجل"),
            ("ToastMasters", "Public speaking club designed to improve communication skills.", "toastmasters_logo.png", "توستماسترز"),
            ("TakeOne", "Media and film club focused on creating visual media.", "takeone_logo.png", "تيك ون")
        ]
        
        // Create clubs
        for (name, description, logoURL, nameAr) in clubsData {
            let clubId = UUID()
            let club = Club(
                id: clubId,
                name: name,
                description: description,
                logoURL: logoURL,
                email: "\(name.lowercased().replacingOccurrences(of: " ", with: "."))@example.com",
                website: "https://\(name.lowercased().replacingOccurrences(of: " ", with: "")).example.com",
                registrationLink: "https://\(name.lowercased().replacingOccurrences(of: " ", with: "")).example.com/register",
                admins: [],
                nameAr: nameAr,
                descriptionAr: "وصف \(nameAr ?? name) باللغة العربية."
            )
            clubs.append(club)
            
            // Add some sample posts for this club
            addSamplePost(for: clubId, name: name, nameAr: nameAr)
        }
        
        // Add some sample events and notifications
        addSampleEvents()
        addSampleNotifications()
    }
    
    private func addSamplePost(for clubId: UUID, name: String, nameAr: String?) {
        let post = Post(
            id: UUID(),
            title: "\(name) Announcement",
            content: "This is a sample post from \(name). It contains information about upcoming activities and events.",
            description: "Latest news from \(name)",
            clubId: clubId,
            date: Date(),
            imageURL: nil,
            imageData: nil,
            isApproved: Bool.random() ? true : nil,
            disapprovalReason: nil,
            isPendingApproval: Bool.random(),
            titleAr: nameAr != nil ? "إعلان \(nameAr!)" : nil,
            contentAr: nameAr != nil ? "هذا منشور نموذجي من \(nameAr!). يحتوي على معلومات حول الأنشطة والفعاليات القادمة." : nil,
            descriptionAr: nameAr != nil ? "أحدث الأخبار من \(nameAr!)" : nil
        )
        posts.append(post)
    }
    
    private func addSampleEvents() {
        // Add some sample events for each club
        for club in clubs {
            let event = Event(
                id: UUID(),
                title: "\(club.name) Workshop",
                description: "A workshop organized by \(club.name) to enhance skills and knowledge in the field.",
                clubId: club.id,
                startDate: Date().addingTimeInterval(Double.random(in: 86400...604800)), // 1-7 days in the future
                endDate: Date().addingTimeInterval(Double.random(in: 604800...1209600)), // 7-14 days in the future
                location: "YU Campus, Building \(Int.random(in: 1...10)), Room \(Int.random(in: 101...399))",
                isAllDay: Bool.random(),
                titleAr: club.nameAr != nil ? "ورشة عمل \(club.nameAr!)" : nil,
                descriptionAr: club.nameAr != nil ? "ورشة عمل منظمة من قبل \(club.nameAr!) لتعزيز المهارات والمعرفة في هذا المجال." : nil,
                locationAr: club.nameAr != nil ? "حرم YU، مبنى \(Int.random(in: 1...10))، غرفة \(Int.random(in: 101...399))" : nil
            )
            events.append(event)
        }
    }
    
    private func addSampleNotifications() {
        // Add notifications for posts and events
        for post in posts where post.isPendingApproval {
            let notification = Notification(
                id: UUID(),
                title: "New Post Pending Approval",
                message: "A new post from \(clubs.first(where: { $0.id == post.clubId })?.name ?? "a club") is waiting for your approval.",
                date: Date(),
                isRead: Bool.random(),
                relatedEventId: nil,
                relatedPostId: post.id,
                clubId: post.clubId,
                notificationType: .postApproval,
                titleAr: "منشور جديد ينتظر الموافقة",
                messageAr: "منشور جديد من \(clubs.first(where: { $0.id == post.clubId })?.nameAr ?? "نادي") ينتظر موافقتك."
            )
            notifications.append(notification)
        }
        
        for event in events {
            let notification = Notification(
                id: UUID(),
                title: "New Event: \(event.title)",
                message: "A new event by \(clubs.first(where: { $0.id == event.clubId })?.name ?? "a club") has been scheduled.",
                date: Date(),
                isRead: Bool.random(),
                relatedEventId: event.id,
                relatedPostId: nil,
                clubId: event.clubId,
                notificationType: .newEvent,
                titleAr: "حدث جديد: \(event.titleAr ?? event.title)",
                messageAr: "تم جدولة حدث جديد بواسطة \(clubs.first(where: { $0.id == event.clubId })?.nameAr ?? "نادي")."
            )
            notifications.append(notification)
        }
    }
    
    // MARK: - Club Methods
    func updateClub(_ club: Club) {
        if let index = clubs.firstIndex(where: { $0.id == club.id }) {
            clubs[index] = club
        }
    }
    
    // MARK: - Post Methods
    func approvePost(postId: UUID) {
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            let post = posts[index]
            let approvedPost = Post(
                id: post.id,
                title: post.title,
                content: post.content,
                description: post.description,
                clubId: post.clubId,
                date: post.date,
                imageURL: post.imageURL,
                imageData: post.imageData,
                isApproved: true,
                disapprovalReason: nil,
                isPendingApproval: false,
                titleAr: post.titleAr,
                contentAr: post.contentAr,
                descriptionAr: post.descriptionAr
            )
            posts[index] = approvedPost
            
            // Create notification for the club admin
            let clubAdminNotification = Notification(
                id: UUID(),
                title: "Post Approved",
                message: "Your post '\(post.title)' has been approved.",
                date: Date(),
                isRead: false,
                relatedEventId: nil,
                relatedPostId: post.id,
                clubId: post.clubId,
                notificationType: .postApproved,
                titleAr: "تمت الموافقة على المنشور",
                messageAr: "تمت الموافقة على منشورك '\(post.titleAr ?? post.title)'."
            )
            notifications.append(clubAdminNotification)
            
            // Create a public notification for all users about the new post
            let publicNotification = Notification(
                id: UUID(),
                title: "New Post: \(post.title)",
                message: "A new post from \(clubs.first(where: { $0.id == post.clubId })?.name ?? "a club") has been published.",
                date: Date(),
                isRead: false,
                relatedEventId: nil,
                relatedPostId: post.id,
                clubId: post.clubId,
                notificationType: .newPost,
                titleAr: "منشور جديد: \(post.titleAr ?? post.title)",
                messageAr: "تم نشر منشور جديد من \(clubs.first(where: { $0.id == post.clubId })?.nameAr ?? "نادي")."
            )
            notifications.append(publicNotification)
        }
    }
    
    func disapprovePost(postId: UUID, reason: String) {
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            let post = posts[index]
            let disapprovedPost = Post(
                id: post.id,
                title: post.title,
                content: post.content,
                description: post.description,
                clubId: post.clubId,
                date: post.date,
                imageURL: post.imageURL,
                imageData: post.imageData,
                isApproved: false,
                disapprovalReason: reason,
                isPendingApproval: false,
                titleAr: post.titleAr,
                contentAr: post.contentAr,
                descriptionAr: post.descriptionAr
            )
            posts[index] = disapprovedPost
            
            // Create notification for the club admin
            let notification = Notification(
                id: UUID(),
                title: "Post Disapproved",
                message: "Your post '\(post.title)' has been disapproved. Reason: \(reason)",
                date: Date(),
                isRead: false,
                relatedEventId: nil,
                relatedPostId: post.id,
                clubId: post.clubId,
                notificationType: .postDisapproved,
                titleAr: "تم رفض المنشور",
                messageAr: "تم رفض منشورك '\(post.titleAr ?? post.title)'. السبب: \(reason)"
            )
            notifications.append(notification)
        }
    }
    
    func deletePost(postId: UUID) {
        posts.removeAll(where: { $0.id == postId })
    }
    
    func createPost(title: String, description: String, content: String, clubId: UUID, imageURL: String? = nil, imageData: Data? = nil, titleAr: String? = nil, descriptionAr: String? = nil, contentAr: String? = nil) -> Post {
        let post = Post(
            id: UUID(),
            title: title,
            content: content,
            description: description,
            clubId: clubId,
            date: Date(),
            imageURL: imageURL,
            imageData: imageData,
            isApproved: nil,
            disapprovalReason: nil,
            isPendingApproval: true,
            titleAr: titleAr,
            contentAr: contentAr,
            descriptionAr: descriptionAr
        )
        
        posts.append(post)
        
        // Create a notification for app admins about the new pending post
        let notification = Notification(
            id: UUID(),
            title: "New Post Pending Approval",
            message: "A new post from \(clubs.first(where: { $0.id == clubId })?.name ?? "a club") is waiting for approval.",
            date: Date(),
            isRead: false,
            relatedEventId: nil,
            relatedPostId: post.id,
            clubId: clubId,
            notificationType: .postApproval,
            titleAr: "منشور جديد ينتظر الموافقة",
            messageAr: "منشور جديد من \(clubs.first(where: { $0.id == clubId })?.nameAr ?? "نادي") ينتظر الموافقة."
        )
        notifications.append(notification)
        
        return post
    }
    
    func approvedPostsForClub(clubId: UUID) -> [Post] {
        return posts.filter { $0.clubId == clubId && $0.isApproved == true }
    }
    
    // MARK: - Event Methods
    func createEvent(title: String, description: String, clubId: UUID, startDate: Date, endDate: Date, location: String, isAllDay: Bool, titleAr: String? = nil, descriptionAr: String? = nil, locationAr: String? = nil) -> Event {
        let event = Event(
            id: UUID(),
            title: title,
            description: description,
            clubId: clubId,
            startDate: startDate,
            endDate: endDate,
            location: location,
            isAllDay: isAllDay,
            titleAr: titleAr,
            descriptionAr: descriptionAr,
            locationAr: locationAr
        )
        
        events.append(event)
        
        // Create a notification about the new event
        let notification = Notification(
            id: UUID(),
            title: "New Event: \(title)",
            message: "A new event by \(clubs.first(where: { $0.id == clubId })?.name ?? "a club") has been scheduled.",
            date: Date(),
            isRead: false,
            relatedEventId: event.id,
            relatedPostId: nil,
            clubId: clubId,
            notificationType: .newEvent,
            titleAr: "حدث جديد: \(titleAr ?? title)",
            messageAr: "تم جدولة حدث جديد بواسطة \(clubs.first(where: { $0.id == clubId })?.nameAr ?? "نادي")."
        )
        notifications.append(notification)
        
        return event
    }
    
    func eventsForDate(_ date: Date) -> [Event] {
        let calendar = Calendar.current
        return events.filter { event in
            calendar.isDate(date, inSameDayAs: event.startDate) ||
            calendar.isDate(date, inSameDayAs: event.endDate) ||
            (date > event.startDate && date < event.endDate)
        }
    }
    
    // MARK: - Notification Methods
    func markNotificationAsRead(id: UUID) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            let notification = notifications[index]
            let updatedNotification = Notification(
                id: notification.id,
                title: notification.title,
                message: notification.message,
                date: notification.date,
                isRead: true,
                relatedEventId: notification.relatedEventId,
                relatedPostId: notification.relatedPostId,
                clubId: notification.clubId,
                notificationType: notification.notificationType,
                titleAr: notification.titleAr,
                messageAr: notification.messageAr
            )
            notifications[index] = updatedNotification
            updateUnreadCount()
        }
    }
    
    func markAllNotificationsAsRead() {
        var updatedNotifications: [Notification] = []
        
        for notification in notifications {
            let updatedNotification = Notification(
                id: notification.id,
                title: notification.title,
                message: notification.message,
                date: notification.date,
                isRead: true,
                relatedEventId: notification.relatedEventId,
                relatedPostId: notification.relatedPostId,
                clubId: notification.clubId,
                notificationType: notification.notificationType,
                titleAr: notification.titleAr,
                messageAr: notification.messageAr
            )
            updatedNotifications.append(updatedNotification)
        }
        
        notifications = updatedNotifications
        updateUnreadCount()
    }
    
    private func updateUnreadCount() {
        unreadNotificationCount = notifications.filter { !$0.isRead }.count
    }
    
    func filteredNotificationsForUser(admin: Admin?) -> [Notification] {
        guard let admin = admin else {
            // For regular users, show only public notifications (like new events and new approved posts)
            return notifications.filter { notification in
                notification.notificationType == .newEvent ||
                notification.notificationType == .upcomingEvent ||
                notification.notificationType == .newPost
            }
        }
        
        if admin.adminType == .appAdmin {
            // App admins see all notifications
            return notifications
        } else if admin.adminType == .clubAdmin, let clubName = admin.clubAffiliation {
            // Get this club admin's club ID
            let clubId = clubs.first(where: { $0.name == clubName })?.id
            
            return notifications.filter { notification in
                // Club admins see event notifications from all clubs
                if notification.notificationType == .newEvent ||
                   notification.notificationType == .upcomingEvent ||
                   notification.notificationType == .newPost {
                    return true
                }
                
                // Club admins see notifications about their own club posts
                if notification.clubId == clubId {
                    return true
                }
                
                return false
            }
        }
        
        return []
    }
}
