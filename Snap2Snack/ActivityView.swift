import SwiftUI

struct ActivityView: View {
    @State private var activities: [Activity] = []
    @State private var userBiometrics = UserBiometrics()
    @State private var showingBiometricInput = false
    @State private var selectedActivity: Activity?
    @State private var showingActivityDetail = false
    @State private var filteredActivities: [Activity] = []
    @State private var selectedCategory: ActivityCategory? = nil
    @State private var selectedDifficulty: ActivityDifficulty? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "figure.walk.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Physical Activity")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                        
                        Text("Get personalized exercise recommendations for diabetes management")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Biometric Status Card
                    BiometricStatusCard(
                        biometrics: userBiometrics,
                        onEdit: { showingBiometricInput = true }
                    )
                    .padding(.horizontal)
                    
                    // Filter Controls
                    if !activities.isEmpty {
                        VStack(spacing: 16) {
                            // Category Filter
                            ScrollView(.horizontal) {
                                HStack(spacing: 12) {
                                    FilterChip(
                                        title: "All",
                                        isSelected: selectedCategory == nil,
                                        action: { selectedCategory = nil }
                                    )
                                    
                                    ForEach(ActivityCategory.allCases, id: \.self) { category in
                                        FilterChip(
                                            title: category.rawValue,
                                            isSelected: selectedCategory == category,
                                            action: { selectedCategory = category }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Difficulty Filter
                            ScrollView(.horizontal) {
                                HStack(spacing: 12) {
                                    FilterChip(
                                        title: "All",
                                        isSelected: selectedDifficulty == nil,
                                        action: { selectedDifficulty = nil }
                                    )
                                    
                                    ForEach(ActivityDifficulty.allCases, id: \.self) { difficulty in
                                        FilterChip(
                                            title: difficulty.rawValue,
                                            isSelected: selectedDifficulty == difficulty,
                                            action: { selectedDifficulty = difficulty }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Activities List
                    if activities.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "figure.walk")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("Loading personalized activities...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Please complete your biometric information for personalized recommendations")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredActivities) { activity in
                                EnhancedActivityCard(activity: activity) {
                                    selectedActivity = activity
                                    showingActivityDetail = true
                                }
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingBiometricInput) {
            BiometricInputView(userBiometrics: $userBiometrics, showingBiometricInput: $showingBiometricInput)
        }
        .sheet(isPresented: $showingActivityDetail) {
            if let activity = selectedActivity {
                ActivityDetailView(activity: activity)
            }
        }
        .onAppear {
            userBiometrics = UserBiometrics.load()
            loadPersonalizedActivities()
        }
        .onChange(of: userBiometrics) { oldValue, newValue in
            userBiometrics.save()
            loadPersonalizedActivities()
        }
        .onChange(of: selectedCategory) { oldValue, newValue in
            filterActivities()
        }
        .onChange(of: selectedDifficulty) { oldValue, newValue in
            filterActivities()
        }
    }
    
    private func loadPersonalizedActivities() {
        activities = generatePersonalizedActivities(for: userBiometrics)
        filterActivities()
    }
    
    private func filterActivities() {
        filteredActivities = activities.filter { activity in
            let categoryMatch = selectedCategory == nil || activity.category == selectedCategory
            let difficultyMatch = selectedDifficulty == nil || activity.difficulty == selectedDifficulty
            return categoryMatch && difficultyMatch
        }
    }
    
    private func generatePersonalizedActivities(for biometrics: UserBiometrics) -> [Activity] {
        var activities: [Activity] = []
        
        // Base activities that are safe for everyone
        let baseActivities = [
            Activity(
                name: "Gentle Walking",
                description: "Low-impact walking perfect for beginners and those with mobility concerns. Great for blood sugar management.",
                duration: "15-30 min",
                intensity: "Low",
                benefits: "Improves circulation, helps manage blood sugar, reduces stress",
                isSafe: true,
                difficulty: .low,
                durationMinutes: 20,
                category: .cardio,
                equipment: ["Comfortable shoes"],
                instructions: [
                    "Start with a 5-minute warm-up at slow pace",
                    "Walk at a comfortable pace for 15-20 minutes",
                    "Cool down with 5 minutes of slow walking",
                    "Monitor your blood sugar before and after"
                ],
                safetyTips: [
                    "Check blood sugar before starting",
                    "Stay hydrated",
                    "Stop if you feel dizzy or unwell",
                    "Wear proper footwear"
                ],
                caloriesBurned: 100,
                heartRateZone: "50-70% max",
                suitableFor: [.diabetes, .hypertension, .obesity, .mobilityIssues],
                contraindications: []
            ),
            Activity(
                name: "Chair Yoga",
                description: "Seated yoga poses that improve flexibility and reduce stress without putting strain on joints.",
                duration: "20-30 min",
                intensity: "Low",
                benefits: "Improves flexibility, reduces stress, enhances balance",
                isSafe: true,
                difficulty: .low,
                durationMinutes: 25,
                category: .flexibility,
                equipment: ["Sturdy chair"],
                instructions: [
                    "Sit comfortably in a chair with feet flat on floor",
                    "Perform gentle neck rolls and shoulder stretches",
                    "Do seated spinal twists and forward folds",
                    "End with deep breathing exercises"
                ],
                safetyTips: [
                    "Move slowly and gently",
                    "Stop if you feel pain",
                    "Breathe deeply throughout",
                    "Use props if needed for support"
                ],
                caloriesBurned: 80,
                heartRateZone: "40-60% max",
                suitableFor: [.diabetes, .arthritis, .mobilityIssues],
                contraindications: []
            ),
            Activity(
                name: "Resistance Band Exercises",
                description: "Light strength training using resistance bands to build muscle and improve insulin sensitivity.",
                duration: "15-25 min",
                intensity: "Medium",
                benefits: "Builds muscle, improves insulin sensitivity, strengthens bones",
                isSafe: true,
                difficulty: .medium,
                durationMinutes: 20,
                category: .strength,
                equipment: ["Resistance bands", "Chair"],
                instructions: [
                    "Warm up with 5 minutes of light movement",
                    "Perform 2-3 sets of 10-15 repetitions for each exercise",
                    "Focus on major muscle groups: arms, legs, core",
                    "Cool down with gentle stretching"
                ],
                safetyTips: [
                    "Start with light resistance",
                    "Maintain proper form",
                    "Breathe during each repetition",
                    "Stop if you feel joint pain"
                ],
                caloriesBurned: 120,
                heartRateZone: "60-80% max",
                suitableFor: [.diabetes, .obesity],
                contraindications: [.arthritis]
            )
        ]
        
        activities.append(contentsOf: baseActivities)
        
        // Add more advanced activities based on fitness level
        if biometrics.energyLevel == .high || biometrics.energyLevel == .veryHigh {
            activities.append(contentsOf: [
                Activity(
                    name: "Brisk Walking",
                    description: "Moderate-intensity walking that significantly improves cardiovascular health and blood sugar control.",
                    duration: "30-45 min",
                    intensity: "Medium",
                    benefits: "Improves heart health, burns calories, enhances mood",
                    isSafe: true,
                    difficulty: .medium,
                    durationMinutes: 35,
                    category: .cardio,
                    equipment: ["Comfortable shoes", "Water bottle"],
                    instructions: [
                        "Start with 5-minute warm-up walk",
                        "Increase pace to brisk walking for 25-35 minutes",
                        "Maintain conversation pace (able to talk but not sing)",
                        "Cool down with 5 minutes of slow walking"
                    ],
                    safetyTips: [
                        "Monitor heart rate during exercise",
                        "Stay hydrated throughout",
                        "Check blood sugar before and after",
                        "Wear reflective clothing if walking at night"
                    ],
                    caloriesBurned: 200,
                    heartRateZone: "60-80% max",
                    suitableFor: [.diabetes, .hypertension],
                    contraindications: [.mobilityIssues]
                ),
                Activity(
                    name: "Swimming",
                    description: "Full-body workout that's easy on joints while providing excellent cardiovascular benefits.",
                    duration: "20-40 min",
                    intensity: "Medium",
                    benefits: "Full-body workout, joint-friendly, improves lung capacity",
                    isSafe: true,
                    difficulty: .medium,
                    durationMinutes: 30,
                    category: .cardio,
                    equipment: ["Swimsuit", "Goggles", "Pool access"],
                    instructions: [
                        "Start with 5 minutes of gentle swimming",
                        "Swim at moderate pace for 20-30 minutes",
                        "Mix different strokes: freestyle, backstroke, breaststroke",
                        "End with 5 minutes of cool-down swimming"
                    ],
                    safetyTips: [
                        "Never swim alone",
                        "Check blood sugar before entering pool",
                        "Stay hydrated",
                        "Stop if you feel dizzy or unwell"
                    ],
                    caloriesBurned: 250,
                    heartRateZone: "60-80% max",
                    suitableFor: [.diabetes, .arthritis, .obesity],
                    contraindications: [.visionProblems]
                )
            ])
        }
        
        // Add diabetes-specific activities
        activities.append(
            Activity(
                name: "Blood Sugar Balance Workout",
                description: "Specially designed exercises to help regulate blood sugar levels throughout the day.",
                duration: "15-30 min",
                intensity: "Low-Medium",
                benefits: "Regulates blood sugar, improves insulin sensitivity, reduces stress",
                isSafe: true,
                difficulty: .low,
                durationMinutes: 20,
                category: .diabetesSpecific,
                equipment: ["Water bottle", "Glucose monitor"],
                instructions: [
                    "Check blood sugar before starting",
                    "Perform 5 minutes of light warm-up",
                    "Do 10-15 minutes of moderate activity",
                    "Check blood sugar after completion",
                    "Have a healthy snack if needed"
                ],
                safetyTips: [
                    "Always check blood sugar before and after",
                    "Keep glucose tablets nearby",
                    "Stop if blood sugar drops below 70 mg/dL",
                    "Stay hydrated throughout"
                ],
                caloriesBurned: 150,
                heartRateZone: "50-70% max",
                suitableFor: [.diabetes],
                contraindications: []
            )
        )
        
        // Filter activities based on health conditions and disabilities
        return activities.filter { activity in
            // Match activity contraindications against the user's current conditions
            let userConditions: [HealthCondition] = [
                .diabetes,
                biometrics.chronicConditions.contains(.hypertension) ? .hypertension : nil,
                biometrics.chronicConditions.contains(.heartDisease) ? .heartDisease : nil,
                biometrics.chronicConditions.contains(.arthritis) ? .arthritis : nil,
                biometrics.chronicConditions.contains(.obesity) ? .obesity : nil,
                biometrics.disabilities.contains(.visualImpairment) ? .visionProblems : nil,
                (biometrics.disabilities.contains(.wheelchair) || biometrics.disabilities.contains(.limitedMobility) || biometrics.mobilityRange != .full) ? .mobilityIssues : nil
            ].compactMap { $0 }

            let hasContraindication = activity.contraindications.contains { userConditions.contains($0) }
            if hasContraindication { return false }
            
            // Check if activity is suitable for user's conditions
            let hasSuitableCondition = activity.suitableFor.contains(.diabetes)
            
            return hasSuitableCondition
        }
    }
}
