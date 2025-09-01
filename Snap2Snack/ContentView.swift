//
//  ContentView.swift
//  Snap2Snack
//
//  Created by Paul Lieber on 9/1/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Grocery Store Assistant
            GroceryAssistantView()
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Grocery")
                }
                .tag(0)
            
            // Fridge Scan
            FridgeScanView()
                .tabItem {
                    Image(systemName: "refrigerator.fill")
                    Text("Fridge")
                }
                .tag(1)
            
            // Glucose & Meds
            GlucoseView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Health")
                }
                .tag(2)
            
            // Activity
            ActivityView()
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Activity")
                }
                .tag(3)
            
            // Resources
            ResourcesView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Resources")
                }
                .tag(4)
        }
        .accentColor(.green)
    }
}

// MARK: - Grocery Store Assistant
struct GroceryAssistantView: View {
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var selectedImage: UIImage?
    @State private var analysisResult = ""
    @State private var isAnalyzing = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Grocery Store Assistant")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("Take a photo of food items to check if they're diabetes-friendly")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(12)
                }
                
                HStack(spacing: 20) {
                    Button(action: {
                        showingCamera = true
                    }) {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.title)
                            Text("Camera")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        VStack {
                            Image(systemName: "photo.fill")
                                .font(.title)
                            Text("Gallery")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                }
                
                if isAnalyzing {
                    ProgressView("Analyzing...")
                        .progressViewStyle(CircularProgressViewStyle())
                }
                
                if !analysisResult.isEmpty {
                    VStack {
                        Text("Analysis Result")
                            .font(.headline)
                            .padding(.top)
                        
                        Text(analysisResult)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { _ in
            if selectedImage != nil {
                analyzeImage()
            }
        }
    }
    
    private func analyzeImage() {
        isAnalyzing = true
        analysisResult = ""
        
        // Simulate AI analysis
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let results = [
                "✅ Diabetes-friendly: Low glycemic index, high fiber content",
                "⚠️ Limit intake: High sugar content, refined carbohydrates",
                "✅ Safe choice: Moderate carbs, good protein balance",
                "❌ Avoid: High fructose corn syrup, excessive sodium"
            ]
            
            analysisResult = results.randomElement() ?? "Analysis complete"
            isAnalyzing = false
        }
    }
}

// MARK: - Fridge Scan View
struct FridgeScanView: View {
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var mealSuggestions: [MealSuggestion] = []
    @State private var isScanning = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Fridge Scan")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("Scan your fridge to get healthy meal suggestions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    showingImagePicker = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Scan Fridge")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                }
                
                if isScanning {
                    ProgressView("Scanning fridge...")
                        .progressViewStyle(CircularProgressViewStyle())
                }
                
                if !mealSuggestions.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(mealSuggestions) { meal in
                                MealSuggestionCard(meal: meal)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { _ in
            if selectedImage != nil {
                scanFridge()
            }
        }
    }
    
    private func scanFridge() {
        isScanning = true
        mealSuggestions = []
        
        // Simulate AI scanning
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            mealSuggestions = [
                MealSuggestion(
                    name: "Grilled Chicken Salad",
                    description: "Low-carb salad with fresh vegetables",
                    cookingTime: "15 min",
                    difficulty: "Easy",
                    glycemicIndex: "Low",
                    calories: "320"
                ),
                MealSuggestion(
                    name: "Quinoa Bowl",
                    description: "Protein-rich bowl with mixed greens",
                    cookingTime: "25 min",
                    difficulty: "Medium",
                    glycemicIndex: "Low",
                    calories: "280"
                ),
                MealSuggestion(
                    name: "Greek Yogurt Parfait",
                    description: "High-protein breakfast option",
                    cookingTime: "5 min",
                    difficulty: "Easy",
                    glycemicIndex: "Low",
                    calories: "180"
                )
            ]
            isScanning = false
        }
    }
}

// MARK: - Glucose & Medication View
struct GlucoseView: View {
    @State private var glucoseLevel = ""
    @State private var showingAddReminder = false
    @State private var reminders: [Reminder] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Glucose & Medication")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                // Glucose Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Glucose Level (mg/dL)")
                        .font(.headline)
                    
                    HStack {
                        TextField("Enter glucose level", text: $glucoseLevel)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Log") {
                            logGlucose()
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                // Glucose Status
                if !glucoseLevel.isEmpty {
                    GlucoseStatusView(level: Int(glucoseLevel) ?? 0)
                }
                
                // Reminders
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Reminders")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button("Add") {
                            showingAddReminder = true
                        }
                        .foregroundColor(.green)
                    }
                    .padding(.horizontal)
                    
                    if reminders.isEmpty {
                        Text("No reminders set")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(reminders) { reminder in
                                    ReminderCard(reminder: reminder)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.top)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView(reminders: $reminders)
        }
    }
    
    private func logGlucose() {
        guard !glucoseLevel.isEmpty else { return }
        // Here you would typically save to a database
        glucoseLevel = ""
    }
}

// MARK: - Activity View
struct ActivityView: View {
    @State private var selectedActivity: Activity?
    @State private var showingActivityDetail = false
    
    let activities = [
        Activity(name: "Walking", duration: "30 min", intensity: "Light", description: "Gentle walking helps regulate blood sugar"),
        Activity(name: "Yoga", duration: "20 min", intensity: "Light", description: "Low-impact stretching and breathing exercises"),
        Activity(name: "Swimming", duration: "45 min", intensity: "Moderate", description: "Full-body workout that's easy on joints"),
        Activity(name: "Cycling", duration: "30 min", intensity: "Moderate", description: "Cardio exercise that builds endurance")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Physical Activity")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("Choose an activity suitable for your current glucose levels")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(activities) { activity in
                            ActivityCard(activity: activity) {
                                selectedActivity = activity
                                showingActivityDetail = true
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingActivityDetail) {
            if let activity = selectedActivity {
                ActivityDetailView(activity: activity)
            }
        }
    }
}

// MARK: - Resources View
struct ResourcesView: View {
    @State private var searchText = ""
    
    let resources = [
        Resource(name: "Diabetes Care Center", type: "Clinic", phone: "(555) 123-4567", acceptsInsurance: true, cost: "$50-150"),
        Resource(name: "Nutritionist Sarah Johnson", type: "Dietitian", phone: "(555) 987-6543", acceptsInsurance: false, cost: "$80-120"),
        Resource(name: "Diabetes Support Group", type: "Support", phone: "(555) 456-7890", acceptsInsurance: true, cost: "Free"),
        Resource(name: "Local Pharmacy", type: "Pharmacy", phone: "(555) 321-0987", acceptsInsurance: true, cost: "Varies")
    ]
    
    var filteredResources: [Resource] {
        if searchText.isEmpty {
            return resources
        } else {
            return resources.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Local Resources")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredResources) { resource in
                            ResourceCard(resource: resource)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Supporting Views and Models
struct MealSuggestion: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let cookingTime: String
    let difficulty: String
    let glycemicIndex: String
    let calories: String
}

struct Reminder: Identifiable {
    let id = UUID()
    let title: String
    let time: Date
    let type: ReminderType
}

enum ReminderType: String, CaseIterable {
    case glucose = "Glucose Check"
    case medication = "Medication"
    case exercise = "Exercise"
}

struct Activity: Identifiable {
    let id = UUID()
    let name: String
    let duration: String
    let intensity: String
    let description: String
}

struct Resource: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let phone: String
    let acceptsInsurance: Bool
    let cost: String
}

// MARK: - Supporting View Components
struct MealSuggestionCard: View {
    let meal: MealSuggestion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(meal.name)
                .font(.headline)
                .foregroundColor(.green)
            
            Text(meal.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label(meal.cookingTime, systemImage: "clock")
                Spacer()
                Label(meal.difficulty, systemImage: "star")
                Spacer()
                Label(meal.glycemicIndex, systemImage: "heart")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ReminderCard: View {
    let reminder: Reminder
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(reminder.title)
                    .font(.headline)
                Text(reminder.time, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(reminder.type.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.2))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ActivityCard: View {
    let activity: Activity
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(activity.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Label(activity.duration, systemImage: "clock")
                    Spacer()
                    Label(activity.intensity, systemImage: "flame")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ResourceCard: View {
    let resource: Resource
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(resource.name)
                .font(.headline)
                .foregroundColor(.green)
            
            Text(resource.type)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Button(action: {
                    if let url = URL(string: "tel:\(resource.phone)") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Label(resource.phone, systemImage: "phone")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(resource.cost)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
            }
            
            if resource.acceptsInsurance {
                Text("Accepts Insurance")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct GlucoseStatusView: View {
    let level: Int
    
    var status: (color: Color, text: String) {
        switch level {
        case 0..<70:
            return (.red, "Low - Eat something with carbs")
        case 70..<140:
            return (.green, "Normal - Good range")
        case 140..<200:
            return (.orange, "Elevated - Monitor closely")
        default:
            return (.red, "High - Contact healthcare provider")
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(level) mg/dL")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(status.color)
            
            Text(status.text)
                .font(.subheadline)
                .foregroundColor(status.color)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(status.color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search resources...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct AddReminderView: View {
    @Binding var reminders: [Reminder]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var time = Date()
    @State private var type: ReminderType = .glucose
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Reminder Details")) {
                    TextField("Title", text: $title)
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                    Picker("Type", selection: $type) {
                        ForEach(ReminderType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
            }
            .navigationTitle("Add Reminder")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    let reminder = Reminder(title: title, time: time, type: type)
                    reminders.append(reminder)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(title.isEmpty)
            )
        }
    }
}

struct ActivityDetailView: View {
    let activity: Activity
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(activity.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(activity.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    InfoRow(icon: "clock", title: "Duration", value: activity.duration)
                    InfoRow(icon: "flame", title: "Intensity", value: activity.intensity)
                }
                
                Button("Start Activity") {
                    // Here you would start the activity tracking
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 30)
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}

// MARK: - Image Picker and Camera Views (Placeholder)
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
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
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    ContentView()
}
