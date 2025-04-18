import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appSettings: AppSettingsViewModel
    @State private var showAboutApp = false
    @State private var showContactUsForm = false
    
    var body: some View {
        NavigationView {
            List {
                // Account section
                Section(header: Text(appSettings.language == .arabic ? "الحساب" : "Account")) {
                    if let admin = authViewModel.currentAdmin {
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.orange)
                            
                            VStack(alignment: .leading) {
                                Text(admin.username)
                                    .font(.headline)
                                Text(admin.adminType.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                authViewModel.logout()
                            }) {
                                Text(appSettings.language == .arabic ? "تسجيل الخروج" : "Logout")
                                    .foregroundColor(.red)
                            }
                        }
                    } else {
                        Button(action: {
                            authViewModel.showLoginModal = true
                        }) {
                            HStack {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .foregroundColor(.orange)
                                Text(appSettings.language == .arabic ? "تسجيل الدخول" : "Sign In")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                // App settings
                Section(header: Text(appSettings.language == .arabic ? "إعدادات التطبيق" : "App Settings")) {
                    // Language picker
                    Picker(selection: $appSettings.language, label:
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.orange)
                                Text(appSettings.language == .arabic ? "اللغة" : "Language")
                            }
                    ) {
                        Text("English").tag(AppSettingsViewModel.AppLanguage.english)
                        Text("العربية").tag(AppSettingsViewModel.AppLanguage.arabic)
                    }
                    
                    // Appearance settings with dark mode toggle
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.orange)
                        Text(appSettings.language == .arabic ? "الوضع الداكن" : "Dark Mode")
                        Spacer()
                        Toggle("", isOn: $appSettings.isDarkMode)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: .orange))
                    }
                }
                
                // About section
                Section(header: Text(appSettings.language == .arabic ? "حول" : "About")) {
                    Button(action: {
                        showAboutApp = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.orange)
                            Text(appSettings.language == .arabic ? "حول التطبيق" : "About This App")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        showContactUsForm = true
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.orange)
                            Text(appSettings.language == .arabic ? "التواصل معنا" : "Contact Us")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Link(destination: URL(string: "https://www.example.com/termsofservice")!) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.orange)
                            Text(appSettings.language == .arabic ? "شروط الخدمة" : "Terms of Service")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Link(destination: URL(string: "https://www.example.com/privacypolicy")!) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(.orange)
                            Text(appSettings.language == .arabic ? "سياسة الخصوصية" : "Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // Version info section
                Section {
                    HStack {
                        Text(appSettings.language == .arabic ? "الإصدار" : "Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(appSettings.language == .arabic ? "الإعدادات" : "Settings")
            .environment(\.layoutDirection, appSettings.language.isRTL ? .rightToLeft : .leftToRight)
            .sheet(isPresented: $showContactUsForm) {
                ContactUsView()
            }
            .sheet(isPresented: $showAboutApp) {
                AboutAppView()
            }
        }
        .id("\(appSettings.language.rawValue)-\(appSettings.isDarkMode)")
    }
}

struct ContactUsView: View {
    @EnvironmentObject var appSettings: AppSettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var email = ""
    @State private var subject = ""
    @State private var message = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(appSettings.language == .arabic ? "البيانات الشخصية" : "Personal Information")) {
                    TextField(appSettings.language == .arabic ? "الاسم" : "Name", text: $name)
                    TextField(appSettings.language == .arabic ? "البريد الإلكتروني" : "Email", text: $email)
                        .keyboardType(.emailAddress)
                }
                
                Section(header: Text(appSettings.language == .arabic ? "رسالتك" : "Your Message")) {
                    TextField(appSettings.language == .arabic ? "الموضوع" : "Subject", text: $subject)
                    
                    ZStack(alignment: .topLeading) {
                        if message.isEmpty {
                            Text(appSettings.language == .arabic ? "أدخل رسالتك هنا..." : "Enter your message here...")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        TextEditor(text: $message)
                            .frame(minHeight: 150)
                    }
                }
                
                Section {
                    Button(action: sendMessage) {
                        Text(appSettings.language == .arabic ? "إرسال" : "Send")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .background(Color.orange)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle(appSettings.language == .arabic ? "التواصل معنا" : "Contact Us")
            .navigationBarItems(trailing: Button(appSettings.language == .arabic ? "إلغاء" : "Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(appSettings.language == .arabic ? "تم إرسال الرسالة" : "Message Sent"),
                    message: Text(appSettings.language == .arabic ? "سنتواصل معك قريبًا!" : "We'll get back to you soon!"),
                    dismissButton: .default(Text(appSettings.language == .arabic ? "حسنًا" : "OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
            .environment(\.layoutDirection, appSettings.language.isRTL ? .rightToLeft : .leftToRight)
        }
    }
    
    private func sendMessage() {
        // In a real app, this would send the message to a server
        showingAlert = true
    }
}

struct AboutAppView: View {
    @EnvironmentObject var appSettings: AppSettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "person.3.fill")
                        .resizable()
                        .frame(width: 80, height: 60)
                        .foregroundColor(.orange)
                    
                    Text("YU Community")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Divider()
                    
                    Text(appSettings.language == .arabic ? "حول التطبيق" : "About")
                        .font(.headline)
                        .padding(.top)
                    
                    Text(appSettings.language == .arabic ?
                         "تطبيق YU Community هو منصة تفاعلية لطلاب الجامعة للتواصل مع النوادي والأنشطة الطلابية. يمكن للطلاب متابعة أحدث أخبار وفعاليات النوادي، والتسجيل في الأنشطة، والتواصل مع إدارة النوادي." :
                         "YU Community is an interactive platform for university students to connect with clubs and student activities. Students can follow the latest news and events of clubs, register for activities, and communicate with club management.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Divider()
                    
                    Text(appSettings.language == .arabic ? "المطورون" : "Developers")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("YU Development Team")
                        .font(.body)
                    
                    Text("© 2025 YU Community. All rights reserved.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                }
                .padding()
            }
            .navigationTitle(appSettings.language == .arabic ? "حول التطبيق" : "About")
            .navigationBarItems(trailing: Button(appSettings.language == .arabic ? "إغلاق" : "Close") {
                presentationMode.wrappedValue.dismiss()
            })
            .environment(\.layoutDirection, appSettings.language.isRTL ? .rightToLeft : .leftToRight)
        }
    }
}
