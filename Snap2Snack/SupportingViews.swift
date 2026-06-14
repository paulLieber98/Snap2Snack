//
//  SupportingViews.swift
//  Snap2Snack
//
//  Created by Nathan on 2024-12-19.
//

import SwiftUI
import AVFoundation
import PhotosUI

// MARK: - Meal Detail View
struct MealDetailView: View {
    let meal: MealSuggestion
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Meal Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(meal.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("Total Calories: \(meal.calories)")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Text("Prep Time: \(meal.cookingTime) min")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Nutritional Information
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text("Nutrition Facts")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 20) {
                        
                        StatCard(
                            title: "Protein",
                            value: String(format: "%.1f", meal.protein ?? 0),
                            unit: "g",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Carbs",
                            value: String(format: "%.1f", meal.carbs ?? 0),
                            unit: "g",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Fat",
                            value: String(format: "%.1f", meal.fat ?? 0),
                            unit: "g",
                            color: .orange
                        )
                    }
                    
                    HStack(spacing: 20) {
                        
                        StatCard(
                            title: "Fiber",
                            value: "\(meal.nutrition.fiber)g",
                            unit: "g",
                            color: .purple
                        )
                        
                        StatCard(
                            title: "Sugar",
                            value: "\(meal.nutrition.sugar)g",
                            unit: "g",
                            color: .pink
                        )
                        
                        StatCard(
                            title: "Sodium",
                            value: "\(meal.nutrition.sodium)mg",
                            unit: "mg",
                            color: .red
                        )
                    }
                }
                .padding(.horizontal)
                
                // Ingredients
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ingredients")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ForEach(meal.ingredients ?? [], id: \.self) { ingredient in
                        Text("• \(ingredient)")
                            .font(.body)
                    }
                }
                .padding(.horizontal)
                
                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Instructions")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ForEach(Array((meal.instructions ?? []).enumerated()), id: \.offset) { index, instruction in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1).")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            
                            Text(instruction)
                                .font(.body)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Diabetes Notes
                if !meal.diabetesNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Diabetes Considerations")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                        
                        ForEach(meal.diabetesNotes, id: \.self) { note in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                
                                Text(note)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Meal Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Glucose Status View
struct GlucoseStatusView: View {
    @Binding var glucoseEntries: [GlucoseEntry]
    @State private var showingAddEntry = false
    @State private var newGlucoseLevel = ""
    @State private var newNotes = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Current Glucose Display
            if let latestEntry = glucoseEntries.first {
                VStack(spacing: 8) {
                    Text("Current Glucose")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("\(latestEntry.level) mg/dL")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(glucoseColor(for: latestEntry.level))
                    
                    Text(timeAgo(from: latestEntry.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !latestEntry.notes.isEmpty {
                        Text(latestEntry.notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue.opacity(0.5))
                    
                    Text("No glucose readings yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Add your first reading to start tracking")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            
            // Add New Entry Button
            Button(action: { showingAddEntry = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Glucose Reading")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            // Recent Entries
            if !glucoseEntries.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Readings")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ForEach(glucoseEntries.prefix(5)) { entry in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(entry.level) mg/dL")
                                    .font(.headline)
                                    .foregroundColor(glucoseColor(for: entry.level))
                                
                                Text(timeAgo(from: entry.timestamp))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if !entry.notes.isEmpty {
                                Image(systemName: "note.text")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingAddEntry) {
            NavigationView {
                Form {
                    Section(header: Text("Glucose Reading")) {
                        TextField("Glucose Level (mg/dL)", text: $newGlucoseLevel)
                            .keyboardType(.numberPad)
                        
                        TextField("Notes (optional)", text: $newNotes)
                    }
                }
                .navigationTitle("Add Reading")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        showingAddEntry = false
                        newGlucoseLevel = ""
                        newNotes = ""
                    },
                    trailing: Button("Save") {
                        if let level = Int(newGlucoseLevel), level > 0 {
                            let entry = GlucoseEntry(level: level, timestamp: Date(), notes: newNotes)
                            glucoseEntries.insert(entry, at: 0)
                            showingAddEntry = false
                            newGlucoseLevel = ""
                            newNotes = ""
                        }
                    }
                        .disabled(newGlucoseLevel.isEmpty)
                )
            }
        }
    }
    
    private func glucoseColor(for level: Int) -> Color {
        switch level {
        case 0..<70: return .red
        case 70..<140: return .green
        case 140..<180: return .orange
        default: return .red
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Add Reminder View
struct AddReminderView: View {
    @Binding var reminders: [Reminder]
    @Binding var showingAddReminder: Bool
    
    @State private var title = ""
    @State private var message = ""
    @State private var frequency: ReminderFrequency = .daily
    @State private var time = Date()
    @State private var isEnabled = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Reminder Details")) {
                    TextField("Title", text: $title)
                    TextField("Message", text: $message)
                    
                    Picker("Frequency", selection: $frequency) {
                        ForEach(ReminderFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                    
                    Toggle("Enabled", isOn: $isEnabled)
                }
            }
            .navigationTitle("Add Reminder")
            .navigationBarItems(
                leading: Button("Cancel") {
                    showingAddReminder = false
                },
                trailing: Button("Save") {
                    let reminder = Reminder(
                        title: title,
                        time: time,
                        type: .glucose
                    )
                    reminders.append(reminder)
                    showingAddReminder = false
                }
                    .disabled(title.isEmpty)
            )
        }
    }
}

// MARK: - Activity Detail View
struct ActivityDetailView: View {
    let activity: Activity
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Activity Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(activity.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        activity.difficulty.color
                            .frame(width: 12, height: 12)
                            .clipShape(Circle())
                        
                        Text(activity.difficulty.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(activity.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Activity Stats
                HStack(spacing: 20) {
                    StatCard(title: "Duration", value: activity.duration, unit: "min", color: .blue)
                    StatCard(title: "Calories", value: "\(activity.caloriesBurned)", unit: "cal", color: .orange)
                    StatCard(title: "Intensity", value: activity.intensity, unit: "", color: .green)
                }
                .padding(.horizontal)
                
                // Benefits
                VStack(alignment: .leading, spacing: 12) {
                    Text("Benefits")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(activity.benefits)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Equipment
                if !activity.equipment.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Equipment Needed")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        ForEach(activity.equipment, id: \.self) { item in
                            Text("• \(item)")
                                .font(.body)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Instructions")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ForEach(Array(activity.instructions.enumerated()), id: \.offset) { index, instruction in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1).")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            
                            Text(instruction)
                                .font(.body)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Safety Tips
                if !activity.safetyTips.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Safety Tips")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                        
                        ForEach(activity.safetyTips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                
                                Text(tip)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Heart Rate Zone
                VStack(alignment: .leading, spacing: 12) {
                    Text("Target Heart Rate Zone")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(activity.heartRateZone)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Activity Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Biometric Input View
struct BiometricInputView: View {
    @Binding var userBiometrics: UserBiometrics
    @Binding var showingBiometricInput: Bool
    
    @State private var currentPage = 1
    @State private var age = ""
    @State private var weight = ""
    @State private var height = ""
    @State private var waistCircumference = ""
    @State private var restingHeartRate = ""
    @State private var bloodPressureSystolic = ""
    @State private var bloodPressureDiastolic = ""
    @State private var currentMedications = ""
    @State private var sleepHours = ""
    @State private var stressLevel: StressLevel = .low
    @State private var energyLevel: EnergyLevel = .high
    @State private var mobilityRange: MobilityRange = .full
    
    var body: some View {
        NavigationView {
            VStack {
                // Progress Indicator
                HStack(spacing: 8) {
                    ForEach(1...2, id: \.self) { page in
                        Circle()
                            .fill(page <= currentPage ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top)
                
                TabView(selection: $currentPage) {
                    // Page 1: Physical Health Data
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Physical Health Data")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Group {
                                TextField("Age", text: $age)
                                    .keyboardType(.numberPad)
                                
                                TextField("Weight (lbs)", text: $weight)
                                    .keyboardType(.decimalPad)
                                
                                TextField("Height (inches)", text: $height)
                                    .keyboardType(.decimalPad)
                                
                                TextField("Waist Circumference (inches)", text: $waistCircumference)
                                    .keyboardType(.decimalPad)
                                
                                TextField("Resting Heart Rate (bpm)", text: $restingHeartRate)
                                    .keyboardType(.numberPad)
                                
                                HStack {
                                    TextField("Systolic", text: $bloodPressureSystolic)
                                        .keyboardType(.numberPad)
                                    
                                    Text("/")
                                        .font(.title)
                                    
                                    TextField("Diastolic", text: $bloodPressureDiastolic)
                                        .keyboardType(.numberPad)
                                }
                                
                                TextField("Current Medications", text: $currentMedications)
                                
                                TextField("Sleep Hours per Night", text: $sleepHours)
                                    .keyboardType(.decimalPad)
                                
                                Picker("Stress Level", selection: $stressLevel) {
                                    ForEach(StressLevel.allCases, id: \.self) { level in
                                        Text(level.rawValue).tag(level)
                                    }
                                }
                                
                                Picker("Energy Level", selection: $energyLevel) {
                                    ForEach(EnergyLevel.allCases, id: \.self) { level in
                                        Text(level.rawValue).tag(level)
                                    }
                                }
                                
                                Picker("Mobility Range", selection: $mobilityRange) {
                                    ForEach(MobilityRange.allCases, id: \.self) { range in
                                        Text(range.rawValue).tag(range)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .tag(1)
                    
                    // Page 2: Additional Details (Optional)
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Additional Details (Optional)")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("This information helps us provide more personalized recommendations.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            // We'll add more fields here in the future
                            Text("More detailed biometric input will be available in future updates.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        .padding()
                    }
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Navigation Buttons
                HStack(spacing: 20) {
                    if currentPage > 1 {
                        Button(action: { currentPage -= 1 }) {
                            Text("Previous")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                    
                    if currentPage < 2 {
                        Button(action: { currentPage += 1 }) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    } else {
                        Button(action: saveBiometrics) {
                            Text("Save")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                        .disabled(!isPage1Valid)
                    }
                }
                .padding()
            }
            .navigationTitle("Health Profile")
            .navigationBarItems(trailing: Button("Cancel") {
                showingBiometricInput = false
            })
        }
    }
    
    private var isPage1Valid: Bool {
        return !age.isEmpty && !weight.isEmpty && !height.isEmpty && !restingHeartRate.isEmpty
    }
    
    private func saveBiometrics() {
        userBiometrics.age = Int(age) ?? 0
        userBiometrics.weight = Double(weight) ?? 0.0
        userBiometrics.height = Double(height) ?? 0.0
        userBiometrics.waistCircumference = Double(waistCircumference) ?? 0.0
        userBiometrics.restingHeartRate = Int(restingHeartRate) ?? 0
        userBiometrics.bloodPressureSystolic = Int(bloodPressureSystolic) ?? 0
        userBiometrics.bloodPressureDiastolic = Int(bloodPressureDiastolic) ?? 0
        userBiometrics.currentMedications = currentMedications
        userBiometrics.sleepHours = Double(sleepHours) ?? 0.0
        userBiometrics.stressLevel = stressLevel
        userBiometrics.energyLevel = energyLevel
        userBiometrics.mobilityRange = mobilityRange
        
        userBiometrics.calculateDerivedValues()
        userBiometrics.save()
        
        showingBiometricInput = false
    }
}

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var showingCamera: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.showingCamera = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.showingCamera = false
        }
    }
}

// MARK: - Supporting View Components
struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct GlucoseHistoryRow: View {
    let entry: GlucoseEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.level) mg/dL")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(getGlucoseColor(entry.level))
                
                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(entry.timestamp, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func getGlucoseColor(_ level: Int) -> Color {
        switch level {
        case 0..<70: return .red
        case 70..<140: return .green
        case 140..<180: return .orange
        default: return .red
        }
    }
}

// MARK: - Resource Card
struct ResourceCard: View {
    let resource: Resource
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with name and type
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(resource.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(resource.type)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if resource.acceptsInsurance {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                            Text("Insurance")
                                .font(.caption)
                        }
                        .foregroundColor(.green)
                    }
                    
                    Text(resource.cost)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
            
            Divider()
            
            // Address
            HStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                Text(resource.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Phone
            HStack(spacing: 8) {
                Image(systemName: "phone.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                Text(resource.phone)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Hours
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                Text(resource.hours)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Services
            if !resource.services.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Services")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(resource.services, id: \.self) { service in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 4, height: 4)
                                
                                Text(service)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Meal Suggestion Card
struct MealSuggestionCard: View {
    let meal: MealSuggestion
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(meal.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(meal.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(meal.calories)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                        
                        Text("kcal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // Nutrition Info
                HStack(spacing: 12) {
                    VStack(alignment: .center, spacing: 2) {
                        Text("Protein")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(meal.protein ?? "0")g")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    Divider()
                        .frame(height: 30)
                    
                    VStack(alignment: .center, spacing: 2) {
                        Text("Carbs")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(meal.carbs ?? "0")g")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    Divider()
                        .frame(height: 30)
                    
                    VStack(alignment: .center, spacing: 2) {
                        Text("Fat")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(meal.fat ?? "0")g")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 2) {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Meta Info
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                        Text("\(meal.cookingTime)")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .font(.caption)
                        Text(meal.difficulty)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                        Text(meal.glycemicIndex)
                            .font(.caption)
                    }
                    .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Biometric Status Card
struct BiometricStatusCard: View {
    let biometrics: UserBiometrics
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Biometric Status")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if biometrics.age > 0 {
                        Text("Age: \(biometrics.age) | Weight: \(Int(biometrics.weight)) lbs | BMI: \(String(format: "%.1f", biometrics.bmi))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Please enter your biometric information")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                }
            }
            
            if biometrics.age > 0 {
                HStack(spacing: 16) {
                    StatCard(
                        title: "Heart Rate",
                        value: "\(biometrics.restingHeartRate)",
                        unit: "bpm",
                        color: .red
                    )
                    
                    StatCard(
                        title: "BP",
                        value: "\(biometrics.bloodPressureSystolic)/\(biometrics.bloodPressureDiastolic)",
                        unit: "mmHg",
                        color: .orange
                    )
                    
                    StatCard(
                        title: "Sleep",
                        value: String(format: "%.1f", biometrics.sleepHours),
                        unit: "hrs",
                        color: .purple
                    )
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

// MARK: - Enhanced Activity Card
struct EnhancedActivityCard: View {
    let activity: Activity
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(activity.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(activity.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: activity.difficulty.icon)
                                .font(.caption)
                            Text(activity.difficulty.rawValue)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(activity.difficulty.color)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                            Text("\(activity.durationMinutes) min")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("\(activity.caloriesBurned) cal")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}