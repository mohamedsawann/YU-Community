//
//  Models.swift
//  YU COMMUNITYS
//
//  Created by M7MD Sawan on 17/10/1446 AH.
//

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
}

struct Post: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let description: String
    let clubId: UUID
    let date: Date
    let imageURL: String?
}

// MARK: - View Models
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentAdmin: Admin?
    @Published var errorMessage: String?
    @Published var showLoginModal = false
    
    private var admins: [Admin] = []
    
    init() {
        // Initialize with default admins (in a real app, this would come from a database)
        let appAdmin1 = Admin(id: UUID(), username: "admin1", password: "password1", adminType: .appAdmin, clubAffiliation: nil)
        let appAdmin2 = Admin(id: UUID(), username: "admin2", password: "password2", adminType: .appAdmin, clubAffiliation: nil)
        
        // Example club admins
        let clubAdmin1 = Admin(id: UUID(), username: "clubadmin1", password: "clubpass1", adminType: .clubAdmin, clubAffiliation: "Google Developers Club")
        let clubAdmin2 = Admin(id: UUID(), username: "clubadmin2", password: "clubpass2", adminType: .clubAdmin, clubAffiliation: "ToastMasters")
        let clubAdmin3 = Admin(id: UUID(), username: "clubadmin3", password: "clubpass3", adminType: .clubAdmin, clubAffiliation: "Google Developers Club")
        
        admins = [appAdmin1, appAdmin2, clubAdmin1, clubAdmin2, clubAdmin3]
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
    
    init() {
        // Initialize with sample data
        let googleClubId = UUID()
        let toastMastersId = UUID()
        let takeOneId = UUID()
        
        let googleClub = Club(
            id: googleClubId,
            name: "Google Developers Club",
            description: "Club for developers interested in Google technologies. We host workshops, hackathons, and tech talks to help students learn and develop their skills.",
            logoURL: "https://example.com/gdsc-logo.png",
            email: "gdsc@example.com",
            website: "https://gdsc.example.com",
            registrationLink: "https://gdsc.example.com/register",
            admins: []
        )
        
        let toastMasters = Club(
            id: toastMastersId,
            name: "ToastMasters",
            description: "Public speaking club designed to improve communication, public speaking, and leadership skills through practice and feedback in a supportive environment.",
            logoURL: "https://example.com/toastmasters-logo.png",
            email: "toastmasters@example.com",
            website: "https://toastmasters.example.com",
            registrationLink: "https://toastmasters.example.com/register",
            admins: []
        )
        
        let takeOne = Club(
            id: takeOneId,
            name: "TakeOne",
            description: "Media and film club focused on creating short films, documentaries, and other visual media. Open to students of all experience levels.",
            logoURL: "https://example.com/takeone-logo.png",
            email: "takeone@example.com",
            website: "https://takeone.example.com",
            registrationLink: "https://takeone.example.com/register",
            admins: []
        )
        
        clubs = [googleClub, toastMasters, takeOne]
        
        // Sample posts
        let post1 = Post(
            id: UUID(),
            title: "Summer Festival",
            content: "Join us for our annual Summer Festival at the University Quad! There will be food, games, and performances from various student groups.",
            description: "The Annual Summer Festival brings together the entire campus community to celebrate the end of the academic year with fun activities and performances.",
            clubId: googleClubId,
            date: Date(),
            imageURL: "summer_festival.jpg"
        )
        
        let post2 = Post(
            id: UUID(),
            title: "Ramadan Breakfast",
            content: "Join us for breakfast during Ramadan. Our club is hosting a special breakfast event to celebrate this important time.",
            description: "A community breakfast to celebrate Ramadan and build connections between students of all backgrounds. Everyone is welcome!",
            clubId: toastMastersId,
            date: Date(),
            imageURL: "ramadan_breakfast.jpg"
        )
        
        posts = [post1, post2]
    }
    
    func addPost(title: String, content: String, description: String, clubId: UUID, imageURL: String?) {
        let newPost = Post(
            id: UUID(),
            title: title,
            content: content,
            description: description,
            clubId: clubId,
            date: Date(),
            imageURL: imageURL
        )
        posts.insert(newPost, at: 0) // Add to beginning for latest first
    }
    
    func deletePost(postId: UUID) {
        posts.removeAll { $0.id == postId }
    }
    
    func updateClub(_ updatedClub: Club) {
        if let index = clubs.firstIndex(where: { $0.id == updatedClub.id }) {
            clubs[index] = updatedClub
        }
    }
    
    func postsForClub(clubId: UUID) -> [Post] {
        return posts.filter { $0.clubId == clubId }
    }
}
