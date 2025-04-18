import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var clubViewModel = ClubViewModel()
    @StateObject var appSettings = AppSettingsViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(appSettings.language == .arabic ? "الرئيسية" : "Home")
                }
                .tag(0)
            
            ClubsView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text(appSettings.language == .arabic ? "النوادي" : "Clubs")
                }
                .tag(1)
            
            ScheduleView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text(appSettings.language == .arabic ? "الجدول" : "Schedule")
                }
                .tag(2)
                
            NotificationsView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text(appSettings.language == .arabic ? "الإشعارات" : "Notifications")
                }
                .badge(clubViewModel.filteredNotificationsForUser(admin: authViewModel.currentAdmin).filter { !$0.isRead }.count)
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text(appSettings.language == .arabic ? "الإعدادات" : "Settings")
                }
                .tag(4)
        }
        .accentColor(.orange)
        // Apply layout direction to the root view
        .environment(\.layoutDirection, appSettings.language.isRTL ? .rightToLeft : .leftToRight)
        // Apply color scheme based on appearance setting
        .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
        // Force view refresh when language or appearance changes
        .id("\(appSettings.language.rawValue)-\(appSettings.isDarkMode)")
        .environmentObject(authViewModel)
        .environmentObject(clubViewModel)
        .environmentObject(appSettings)
        .sheet(isPresented: $authViewModel.showLoginModal) {
            LoginView()
                .environmentObject(authViewModel)
                .environmentObject(appSettings)
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appSettings: AppSettingsViewModel
    @State private var username = ""
    @State private var password = ""
    @State private var rememberMe = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Text(appSettings.language == .arabic ? "من الجميل رؤيتك مرة أخرى" : "Nice to see you again")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(appSettings.language == .arabic ? "اسم المستخدم" : "Username")
                    .font(.headline)
                
                TextField("", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(appSettings.language == .arabic ? "كلمة المرور" : "Password")
                    .font(.headline)
                
                SecureField("", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            HStack {
                Toggle(appSettings.language == .arabic ? "تذكرني" : "Remember me", isOn: $rememberMe)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                Spacer()
                Button(appSettings.language == .arabic ? "نسيت كلمة المرور؟" : "Forgot password?") {
                    // Handle forgot password
                }
                .foregroundColor(.orange)
            }
            
            if let error = authViewModel.errorMessage {
                Text(appSettings.language == .arabic ? "اسم المستخدم أو كلمة المرور غير صحيحة" : error)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
            
            Button(action: {
                authViewModel.login(username: username, password: password)
            }) {
                Text(appSettings.language == .arabic ? "تسجيل الدخول" : "Sign in")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text(appSettings.language == .arabic ? "الاستمرار بدون تسجيل الدخول" : "Continue without signing in")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .environment(\.layoutDirection, appSettings.language.isRTL ? .rightToLeft : .leftToRight)
    }
}
