import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var clubViewModel: ClubViewModel
    @EnvironmentObject var appSettings: AppSettingsViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var selectedDate = Date()
    @State private var showingEventForm = false
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    private var monthDays: [Date] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    private var weeks: [[Date]] {
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let weekdayOffset = firstWeekday - calendar.firstWeekday
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count
        let totalDays = weekdayOffset + daysInMonth
        let totalWeeks = (totalDays + 6) / 7
        
        var allDates: [Date] = []
        
        // Add days from previous month
        if weekdayOffset > 0 {
            let previousMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth)!
            let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: previousMonth)!.count
            
            for i in (daysInPreviousMonth - weekdayOffset + 1)...daysInPreviousMonth {
                let components = calendar.dateComponents([.year, .month], from: previousMonth)
                var dayComponents = DateComponents()
                dayComponents.year = components.year
                dayComponents.month = components.month
                dayComponents.day = i
                if let date = calendar.date(from: dayComponents) {
                    allDates.append(date)
                }
            }
        }
        
        // Add days from current month
        allDates += monthDays
        
        // Add days from next month
        let remainingDays = totalWeeks * 7 - allDates.count
        if remainingDays > 0 {
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth)!
            
            for i in 1...remainingDays {
                let components = calendar.dateComponents([.year, .month], from: nextMonth)
                var dayComponents = DateComponents()
                dayComponents.year = components.year
                dayComponents.month = components.month
                dayComponents.day = i
                if let date = calendar.date(from: dayComponents) {
                    allDates.append(date)
                }
            }
        }
        
        // Chunk into weeks
        return stride(from: 0, to: allDates.count, by: 7).map {
            Array(allDates[$0..<min($0 + 7, allDates.count)])
        }
    }
    
    var events: [Event] {
        clubViewModel.eventsForDate(selectedDate)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Month navigation
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    Text(dateFormatter.string(from: selectedDate))
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal)
                
                // Day names
                HStack {
                    ForEach(getDayNames(), id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                // Calendar grid
                VStack(spacing: 10) {
                    ForEach(weeks, id: \.self) { week in
                        HStack {
                            ForEach(week, id: \.self) { date in
                                DayView(date: date, selectedDate: $selectedDate, events: clubViewModel.eventsForDate(date))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Events list for selected day
                VStack {
                    HStack {
                        Text(appSettings.language == .arabic ? "أحداث اليوم" : "Today's Events")
                            .font(.headline)
                        
                        Spacer()
                        
                        if authViewModel.currentAdmin != nil {
                            Button(action: {
                                showingEventForm = true
                            }) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    if events.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                            
                            Text(appSettings.language == .arabic ? "لا توجد أحداث لهذا اليوم" : "No events for this day")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    } else {
                        ScrollView {
                            ForEach(events) { event in
                                EventCard(event: event)
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle(appSettings.language == .arabic ? "الجدول" : "Schedule")
            .sheet(isPresented: $showingEventForm) {
                AddEventView(selectedDate: selectedDate)
            }
            .environment(\.layoutDirection, appSettings.language.isRTL ? .rightToLeft : .leftToRight)
        }
        .id(appSettings.language.rawValue)
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func getDayNames() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: appSettings.language == .arabic ? "ar" : "en_US")
        
        var weekdaySymbols = formatter.shortWeekdaySymbols ?? []
        
        // Reorder to start with Sunday or Monday based on locale
        if calendar.firstWeekday == 1 { // Sunday
            // Already in correct order
        } else if calendar.firstWeekday == 2 { // Monday
            let sunday = weekdaySymbols.removeFirst()
            weekdaySymbols.append(sunday)
        }
        
        return weekdaySymbols
    }
}

struct DayView: View {
    let date: Date
    @Binding var selectedDate: Date
    let events: [Event]
    
    private let calendar = Calendar.current
    
    var isToday: Bool {
        calendar.isDate(date, inSameDayAs: Date())
    }
    
    var isSelected: Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    var isCurrentMonth: Bool {
        calendar.component(.month, from: date) == calendar.component(.month, from: selectedDate)
    }
    
    var body: some View {
        VStack {
            Text("\(calendar.component(.day, from: date))")
                .font(isToday ? .headline : .body)
                .foregroundColor(textColor)
            
            if !events.isEmpty {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 8, height: 8)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 8, height: 8)
            }
        }
        .frame(height: 45)
        .background(isSelected ? Color.orange.opacity(0.2) : Color.clear)
        .cornerRadius(8)
        .onTapGesture {
            selectedDate = date
        }
    }
    
    var textColor: Color {
        if isSelected {
            return .orange
        } else if isToday {
            return .blue
        } else if isCurrentMonth {
            return .primary
        } else {
            return .gray
        }
    }
}

struct EventCard: View {
    let event: Event
    @EnvironmentObject var clubViewModel: ClubViewModel
    @EnvironmentObject var appSettings: AppSettingsViewModel
    
    var club: Club? {
        clubViewModel.clubs.first(where: { $0.id == event.clubId })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(appSettings.language == .arabic && event.titleAr != nil ? event.titleAr! : event.title)
                        .font(.headline)
                    
                    if let club = club {
                        HStack {
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
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(formatTime(event.startDate))
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    if !event.isAllDay && !calendar.isDate(event.startDate, inSameDayAs: event.endDate) {
                        Text(formatTime(event.endDate))
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            Text(appSettings.language == .arabic && event.descriptionAr != nil ? event.descriptionAr! : event.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.secondary)
                
                Text(appSettings.language == .arabic && event.locationAr != nil ? event.locationAr! : event.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if event.isAllDay {
                    Text(appSettings.language == .arabic ? "طوال اليوم" : "All Day")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private let calendar = Calendar.current
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AddEventView: View {
    @EnvironmentObject var clubViewModel: ClubViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appSettings: AppSettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let selectedDate: Date
    
    @State private var title = ""
    @State private var titleAr = ""
    @State private var description = ""
    @State private var descriptionAr = ""
    @State private var location = ""
    @State private var locationAr = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isAllDay = false
    @State private var selectedClubId: UUID?
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        
        // Initialize with the selected date
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfHour = calendar.date(byAdding: .hour, value: 1, to: startOfDay)!
        
        // Initialize state properties
        _startDate = State(initialValue: startOfDay)
        _endDate = State(initialValue: endOfHour)
    }
    
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
        !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
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
                
                // Event details
                Section(header: Text(appSettings.language == .arabic ? "تفاصيل الحدث (الإنجليزية)" : "Event Details (English)")) {
                    TextField(appSettings.language == .arabic ? "العنوان (الإنجليزية)" : "Title", text: $title)
                    
                    TextField(appSettings.language == .arabic ? "الموقع (الإنجليزية)" : "Location", text: $location)
                    
                    VStack(alignment: .leading) {
                        Text(appSettings.language == .arabic ? "الوصف (الإنجليزية)" : "Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                
                // Arabic details (optional)
                Section(header: Text(appSettings.language == .arabic ? "تفاصيل الحدث (العربية)" : "Event Details (Arabic)")) {
                    Text(appSettings.language == .arabic ? "المحتوى باللغة العربية اختياري" : "Arabic content is optional")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField(appSettings.language == .arabic ? "العنوان (العربية)" : "Title (Arabic)", text: $titleAr)
                    
                    TextField(appSettings.language == .arabic ? "الموقع (العربية)" : "Location (Arabic)", text: $locationAr)
                    
                    VStack(alignment: .leading) {
                        Text(appSettings.language == .arabic ? "الوصف (العربية)" : "Description (Arabic)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $descriptionAr)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                
                // Time settings
                Section(header: Text(appSettings.language == .arabic ? "التوقيت" : "Time")) {
                    Toggle(appSettings.language == .arabic ? "طوال اليوم" : "All Day", isOn: $isAllDay)
                        .toggleStyle(SwitchToggleStyle(tint: .orange))
                    
                    if !isAllDay {
                        DatePicker(
                            appSettings.language == .arabic ? "وقت البدء" : "Start Time",
                            selection: $startDate
                        )
                        
                        DatePicker(
                            appSettings.language == .arabic ? "وقت الانتهاء" : "End Time",
                            selection: $endDate
                        )
                    } else {
                        DatePicker(
                            appSettings.language == .arabic ? "التاريخ" : "Date",
                            selection: $startDate,
                            displayedComponents: .date
                        )
                    }
                }
                
                // Submit button
                Section {
                    Button(action: createEvent) {
                        Text(appSettings.language == .arabic ? "إنشاء الحدث" : "Create Event")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .padding()
                            .background(formIsValid ? Color.orange : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!formIsValid)
                }
            }
            .navigationTitle(appSettings.language == .arabic ? "حدث جديد" : "New Event")
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
    
    private func createEvent() {
        guard formIsValid, let clubId = selectedClubId else {
            alertMessage = appSettings.language == .arabic ? "يرجى ملء جميع الحقول المطلوبة" : "Please fill out all required fields"
            showingAlert = true
            return
        }
        
        // If admin is club admin, ensure they only submit to their club
        if let admin = authViewModel.currentAdmin, admin.adminType == .clubAdmin, let clubName = admin.clubAffiliation {
            let club = clubViewModel.clubs.first(where: { $0.id == clubId })
            if club?.name != clubName {
                alertMessage = appSettings.language == .arabic ? "لا يمكنك إنشاء حدث لنادٍ آخر" : "You cannot create an event for another club"
                showingAlert = true
                return
            }
        }
        
        // Create event in view model
        _ = clubViewModel.createEvent(
            title: title,
            description: description,
            clubId: clubId,
            startDate: startDate,
            endDate: isAllDay ? Calendar.current.date(byAdding: .day, value: 1, to: startDate)! : endDate,
            location: location,
            isAllDay: isAllDay,
            titleAr: titleAr.isEmpty ? nil : titleAr,
            descriptionAr: descriptionAr.isEmpty ? nil : descriptionAr,
            locationAr: locationAr.isEmpty ? nil : locationAr
        )
        
        alertMessage = appSettings.language == .arabic ? "تم إنشاء الحدث بنجاح" : "Event created successfully"
        showingAlert = true
        
        // Dismiss view after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}
