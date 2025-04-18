import SwiftUI

struct ClubEditView: View {
    @Binding var club: Club
    @EnvironmentObject var clubViewModel: ClubViewModel
    @EnvironmentObject var appSettings: AppSettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String
    @State private var nameAr: String
    @State private var description: String
    @State private var descriptionAr: String
    @State private var logoURL: String
    @State private var email: String
    @State private var website: String
    @State private var registrationLink: String
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(club: Binding<Club>) {
        self._club = club
        
        // Initialize state properties from club
        _name = State(initialValue: club.wrappedValue.name)
        _nameAr = State(initialValue: club.wrappedValue.nameAr ?? "")
        _description = State(initialValue: club.wrappedValue.description)
        _descriptionAr = State(initialValue: club.wrappedValue.descriptionAr ?? "")
        _logoURL = State(initialValue: club.wrappedValue.logoURL ?? "")
        _email = State(initialValue: club.wrappedValue.email ?? "")
        _website = State(initialValue: club.wrappedValue.website ?? "")
        _registrationLink = State(initialValue: club.wrappedValue.registrationLink ?? "")
    }
    
    var formIsValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(appSettings.language == .arabic ? "معلومات النادي" : "Club Information")) {
                    TextField(appSettings.language == .arabic ? "اسم النادي" : "Club Name", text: $name)
                    TextField(appSettings.language == .arabic ? "اسم النادي (عربي)" : "Club Name (Arabic)", text: $nameAr)
                    
                    VStack(alignment: .leading) {
                        Text(appSettings.language == .arabic ? "الوصف" : "Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    VStack(alignment: .leading) {
                        Text(appSettings.language == .arabic ? "الوصف (عربي)" : "Description (Arabic)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $descriptionAr)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    TextField(appSettings.language == .arabic ? "رابط الشعار" : "Logo URL", text: $logoURL)
                }
                
                Section(header: Text(appSettings.language == .arabic ? "معلومات الاتصال" : "Contact Information")) {
                    TextField(appSettings.language == .arabic ? "البريد الإلكتروني" : "Email", text: $email)
                        .keyboardType(.emailAddress)
                    
                    TextField(appSettings.language == .arabic ? "الموقع الإلكتروني" : "Website", text: $website)
                        .keyboardType(.URL)
                    
                    TextField(appSettings.language == .arabic ? "رابط التسجيل" : "Registration Link", text: $registrationLink)
                        .keyboardType(.URL)
                }
                
                Section {
                    Button(action: saveClub) {
                        Text(appSettings.language == .arabic ? "حفظ التغييرات" : "Save Changes")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .padding()
                            .background(formIsValid ? Color.orange : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!formIsValid)
                }
            }
            .navigationTitle(appSettings.language == .arabic ? "تعديل النادي" : "Edit Club")
            .navigationBarItems(trailing: Button(appSettings.language == .arabic ? "إلغاء" : "Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(appSettings.language == .arabic ? "التحقق من صحة النموذج" : "Form Validation"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text(appSettings.language == .arabic ? "حسنًا" : "OK"))
                )
            }
            .environment(\.layoutDirection, appSettings.language.isRTL ? .rightToLeft : .leftToRight)
        }
    }
    
    private func saveClub() {
        guard formIsValid else {
            alertMessage = appSettings.language == .arabic ? "يرجى ملء جميع الحقول المطلوبة." : "Please fill out all required fields."
            showingAlert = true
            return
        }
        
        // Update the club binding
        club.name = name
        club.nameAr = nameAr.isEmpty ? nil : nameAr
        club.description = description
        club.descriptionAr = descriptionAr.isEmpty ? nil : descriptionAr
        club.logoURL = logoURL.isEmpty ? nil : logoURL
        club.email = email.isEmpty ? nil : email
        club.website = website.isEmpty ? nil : website
        club.registrationLink = registrationLink.isEmpty ? nil : registrationLink
        
        // Update in the view model
        clubViewModel.updateClub(club)
        
        // Dismiss the sheet
        presentationMode.wrappedValue.dismiss()
    }
}
