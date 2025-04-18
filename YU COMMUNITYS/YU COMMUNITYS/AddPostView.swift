import SwiftUI

struct AddPostView: View {
    @EnvironmentObject var clubViewModel: ClubViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appSettings: AppSettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var content = ""
    @State private var titleAr = ""
    @State private var descriptionAr = ""
    @State private var contentAr = ""
    @State private var imageURL = ""
    @State private var selectedClubId: UUID?
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Image picker states
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var isUsingImagePicker = true // Default to using image picker instead of URL
    
    // Filter clubs based on admin permissions
    var adminClubs: [Club] {
        guard let admin = authViewModel.currentAdmin else { return [] }
        
        if admin.adminType == .appAdmin {
            return clubViewModel.clubs
        } else if admin.adminType == .clubAdmin, let clubName = admin.clubAffiliation {
            return clubViewModel.clubs.filter { $0.name == clubName }
        }
        
        return []
    }
    
    var formIsValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedClubId != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Club selection
                Section(header: Text(appSettings.language == .arabic ? "النادي" : "Club")) {
                    Picker(selection: $selectedClubId, label: Text(appSettings.language == .arabic ? "اختر النادي" : "Select Club")) {
                        Text(appSettings.language == .arabic ? "اختر النادي" : "Select Club").tag(nil as UUID?)
                        ForEach(adminClubs) { club in
                            Text(appSettings.language == .arabic && club.nameAr != nil ? club.nameAr! : club.name).tag(club.id as UUID?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // English content
                Section(header: Text(appSettings.language == .arabic ? "المحتوى (الإنجليزية)" : "Content (English)")) {
                    TextField(appSettings.language == .arabic ? "العنوان (الإنجليزية)" : "Title", text: $title)
                    
                    VStack(alignment: .leading) {
                        Text(appSettings.language == .arabic ? "الوصف المختصر (الإنجليزية)" : "Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $description)
                            .frame(minHeight: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    VStack(alignment: .leading) {
                        Text(appSettings.language == .arabic ? "المحتوى (الإنجليزية)" : "Content")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                
                // Arabic content (optional)
                Section(header: Text(appSettings.language == .arabic ? "المحتوى (العربية)" : "Content (Arabic)")) {
                    Text(appSettings.language == .arabic ? "المحتوى باللغة العربية اختياري" : "Arabic content is optional")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField(appSettings.language == .arabic ? "العنوان (العربية)" : "Title (Arabic)", text: $titleAr)
                    
                    VStack(alignment: .leading) {
                        Text(appSettings.language == .arabic ? "الوصف المختصر (العربية)" : "Description (Arabic)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $descriptionAr)
                            .frame(minHeight: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    VStack(alignment: .leading) {
                        Text(appSettings.language == .arabic ? "المحتوى (العربية)" : "Content (Arabic)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $contentAr)
                            .frame(minHeight: 150)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                
                // Image section
                Section(header: Text(appSettings.language == .arabic ? "الصورة" : "Image")) {
                    Picker(selection: $isUsingImagePicker, label: Text(appSettings.language == .arabic ? "نوع الصورة" : "Image Source")) {
                        Text(appSettings.language == .arabic ? "اختيار من الجهاز" : "Choose from Device").tag(true)
                        Text(appSettings.language == .arabic ? "رابط الصورة" : "Image URL").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if isUsingImagePicker {
                        HStack {
                            Spacer()
                            VStack {
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                        .cornerRadius(10)
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.gray)
                                        .padding()
                                }
                                
                                Button(action: {
                                    isShowingImagePicker = true
                                }) {
                                    Text(appSettings.language == .arabic ? "اختر صورة" : "Select Image")
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.orange)
                                        .cornerRadius(8)
                                }
                                .padding(.bottom)
                            }
                            Spacer()
                        }
                        .sheet(isPresented: $isShowingImagePicker) {
                            ImagePicker(selectedImage: $selectedImage, isPresented: $isShowingImagePicker)
                        }
                    } else {
                        TextField(appSettings.language == .arabic ? "رابط الصورة (اختياري)" : "Image URL (optional)", text: $imageURL)
                    }
                }
                
                // Submit button
                Section {
                    Button(action: createPost) {
                        Text(appSettings.language == .arabic ? "إرسال" : "Submit")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .padding()
                            .background(formIsValid ? Color.orange : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!formIsValid)
                }
            }
            .navigationTitle(appSettings.language == .arabic ? "منشور جديد" : "New Post")
            .navigationBarItems(trailing: Button(appSettings.language == .arabic ? "إلغاء" : "Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(appSettings.language == .arabic ? "معلومات" : "Information"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text(appSettings.language == .arabic ? "حسنًا" : "OK"))
                )
            }
            .environment(\.layoutDirection, appSettings.language.isRTL ? .rightToLeft : .leftToRight)
        }
    }
    
    private func createPost() {
        guard formIsValid, let clubId = selectedClubId else {
            alertMessage = appSettings.language == .arabic ? "يرجى ملء جميع الحقول المطلوبة" : "Please fill out all required fields"
            showingAlert = true
            return
        }
        
        // If admin is club admin, ensure they only submit to their club
        if let admin = authViewModel.currentAdmin, admin.adminType == .clubAdmin, let clubName = admin.clubAffiliation {
            let club = clubViewModel.clubs.first(where: { $0.id == clubId })
            if club?.name != clubName {
                alertMessage = appSettings.language == .arabic ? "لا يمكنك إنشاء منشور لنادٍ آخر" : "You cannot create a post for another club"
                showingAlert = true
                return
            }
        }
        
        let cleanImageURL = !isUsingImagePicker && !imageURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? imageURL : nil
        
        // Convert selected image to Data if using image picker
        var imageData: Data? = nil
        if isUsingImagePicker, let image = selectedImage {
            imageData = image.jpegData(compressionQuality: 0.8)
        }
        
        // Create post in view model
        _ = clubViewModel.createPost(
            title: title,
            description: description,
            content: content,
            clubId: clubId,
            imageURL: cleanImageURL,
            imageData: imageData,
            titleAr: titleAr.isEmpty ? nil : titleAr,
            descriptionAr: descriptionAr.isEmpty ? nil : descriptionAr,
            contentAr: contentAr.isEmpty ? nil : contentAr
        )
        
        alertMessage = appSettings.language == .arabic ? "تم إرسال المنشور للموافقة عليه" : "Post submitted for approval"
        showingAlert = true
        
        // Reset form
        title = ""
        description = ""
        content = ""
        titleAr = ""
        descriptionAr = ""
        contentAr = ""
        imageURL = ""
        selectedImage = nil
        selectedClubId = nil
        
        // Dismiss view after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}
