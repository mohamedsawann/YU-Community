import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var clubViewModel = ClubViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            ClubsView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Clubs")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(2)
        }
        .environmentObject(authViewModel)
        .environmentObject(clubViewModel)
        .sheet(isPresented: $authViewModel.showLoginModal) {
            LoginView()
                .environmentObject(authViewModel)
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username = ""
    @State private var password = ""
    @State private var rememberMe = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Nice to see you again")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .autocapitalization(.none)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                SecureField("Enter password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            HStack {
                Toggle("Remember me", isOn: $rememberMe)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                Spacer()
                Button("Forgot password?") {
                    // Handle forgot password
                }
                .foregroundColor(.blue)
            }
            
            if let error = authViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            Button(action: {
                authViewModel.login(username: username, password: password)
            }) {
                Text("Sign in")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Continue without signing in")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            List {
                if authViewModel.isAuthenticated {
                    Section(header: Text("Account")) {
                        Text("Logged in as: \(authViewModel.currentAdmin?.username ?? "")")
                        Text("Admin Type: \(authViewModel.currentAdmin?.adminType.rawValue ?? "")")
                        if let affiliation = authViewModel.currentAdmin?.clubAffiliation {
                            Text("Club: \(affiliation)")
                        }
                        
                        Button("Log Out") {
                            authViewModel.logout()
                        }
                        .foregroundColor(.red)
                    }
                } else {
                    Section {
                        Button("Log In") {
                            authViewModel.showLoginModal = true
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    Text("YU Community App v1.0")
                    Text("© YU Community Team")
                }
                
            }
            .navigationTitle("Settings")
        }
    }
}
