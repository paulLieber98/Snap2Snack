//
//  ExercisePlan.swift
//  Snap2Snack
//
//  Created by Nathan on 2024-12-19.
//

import SwiftUI

// MARK: - Exercise Plan Models
struct RecommendedActivity: Identifiable {
    let id = UUID()
    let activity: Activity
    let sessionsPerWeek: Int
    let durationMinutes: Int
    let notes: [String]
}

struct PersonalizedExercisePlan {
    let activities: [RecommendedActivity]
    let weeklySessions: Int
    let averageDuration: Int
    let intensityLevel: String
    let safetyConsiderations: [String]
}

// MARK: - Exercise Plan Generation Algorithm
func generatePersonalizedPlan(for biometrics: UserBiometrics) -> PersonalizedExercisePlan {
    var activities: [RecommendedActivity] = []
    var weeklySessions = 0
    var averageDuration = 0
    var baseIntensity = "Moderate"
    var safetyConsiderations: [String] = []
    
    // Base activity selection based on fitness level
    let baseActivities = getBaseActivities(for: biometrics)
    
    // Filter activities based on contraindications
    let filteredActivities = filterActivities(baseActivities, for: biometrics)
    
    // Create personalized recommendations
    for activity in filteredActivities.prefix(5) { // Limit to 5 activities
        let sessions = calculateSessionsPerWeek(for: biometrics)
        let duration = calculateDuration(for: activity, biometrics: biometrics)
        let notes = generateActivityNotes(for: activity, biometrics: biometrics)
        
        let recommended = RecommendedActivity(
            activity: activity,
            sessionsPerWeek: sessions,
            durationMinutes: duration,
            notes: notes
        )
        
        activities.append(recommended)
        weeklySessions += sessions
        averageDuration += duration
    }
    
    if !activities.isEmpty {
        averageDuration /= activities.count
    }
    
    // Adjust intensity based on biometrics
    baseIntensity = determineIntensityLevel(for: biometrics)
    
    // Generate safety considerations
    safetyConsiderations = generateSafetyConsiderations(for: biometrics)
    
    return PersonalizedExercisePlan(
        activities: activities,
        weeklySessions: weeklySessions,
        averageDuration: averageDuration,
        intensityLevel: baseIntensity,
        safetyConsiderations: safetyConsiderations
    )
}

private func getBaseActivities(for biometrics: UserBiometrics) -> [Activity] {
    // This would be a comprehensive list of activities
    // For now, return a sample based on the activity data
    return [
        Activity(
            name: "Walking",
            description: "Brisk walking for cardiovascular health",
            duration: "20-30 min",
            intensity: "Low to Moderate",
            benefits: "Improves cardiovascular health, helps with weight management",
            isSafe: true,
            difficulty: .low,
            durationMinutes: 30,
            category: .cardio,
            equipment: [],
            instructions: ["Start with a warm-up", "Maintain steady pace", "Cool down gradually"],
            safetyTips: ["Wear comfortable shoes", "Stay hydrated"],
            caloriesBurned: 150,
            heartRateZone: "50-70% max HR",
            suitableFor: [.diabetes, .hypertension],
            contraindications: [.mobilityIssues]
        ),
        Activity(
            name: "Chair Yoga",
            description: "Gentle yoga poses performed seated",
            duration: "15-20 min",
            intensity: "Low",
            benefits: "Improves flexibility, reduces stress, gentle on joints",
            isSafe: true,
            difficulty: .low,
            durationMinutes: 20,
            category: .flexibility,
            equipment: ["Chair"],
            instructions: ["Sit comfortably", "Follow breathing exercises", "Move slowly"],
            safetyTips: ["Stop if you feel pain", "Listen to your body"],
            caloriesBurned: 50,
            heartRateZone: "40-60% max HR",
            suitableFor: [.arthritis, .mobilityIssues],
            contraindications: []
        )
    ]
}

private func filterActivities(_ activities: [Activity], for biometrics: UserBiometrics) -> [Activity] {
    return activities.filter { activity in
        // Check contraindications
        for condition in activity.contraindications {
            if hasCondition(condition, biometrics: biometrics) {
                return false
            }
        }
        
        // Check if activity is suitable for user's conditions
        if !activity.suitableFor.isEmpty {
            let hasSuitableCondition = activity.suitableFor.contains { condition in
                hasCondition(condition, biometrics: biometrics)
            }
            if !hasSuitableCondition && !activity.suitableFor.contains(.none) {
                return false
            }
        }
        
        return true
    }
}

private func hasCondition(_ condition: HealthCondition, biometrics: UserBiometrics) -> Bool {
    switch condition {
    case .diabetes:
        return true // Assuming all users have diabetes for this app
    case .hypertension:
        return biometrics.bloodPressureSystolic >= 130 || biometrics.bloodPressureDiastolic >= 80
    case .heartDisease:
        return biometrics.chronicConditions.contains(.heartDisease)
    case .arthritis:
        return biometrics.chronicConditions.contains(.arthritis)
    case .obesity:
        return biometrics.bmi >= 30
    case .mobilityIssues:
        return biometrics.physicalLimitations.contains(.limitedRangeOfMotion) ||
               biometrics.physicalLimitations.contains(.poorBalance)
    case .visionProblems:
        return biometrics.disabilities.contains(.visualImpairment)
    case .neuropathy:
        return biometrics.chronicConditions.contains(.chronicFatigue) // Approximation
    case .kidneyDisease:
        return biometrics.chronicConditions.contains(.chronicFatigue) // Approximation
    case .none:
        return false
    }
}

private func calculateSessionsPerWeek(for biometrics: UserBiometrics) -> Int {
    switch biometrics.currentActivityLevel {
    case .sedentary:
        return 3
    case .lightlyActive:
        return 4
    case .moderatelyActive:
        return 5
    case .veryActive:
        return 6
    case .extremelyActive:
        return 7
    }
}

private func calculateDuration(for activity: Activity, biometrics: UserBiometrics) -> Int {
    let baseDuration = activity.durationMinutes
    
    // Adjust based on fitness level
    switch biometrics.cardiovascularFitness {
    case .poor:
        return min(baseDuration, 15)
    case .belowAverage:
        return min(baseDuration, 20)
    case .average:
        return baseDuration
    case .aboveAverage:
        return baseDuration + 5
    case .excellent:
        return baseDuration + 10
    }
}

private func generateActivityNotes(for activity: Activity, biometrics: UserBiometrics) -> [String] {
    var notes: [String] = []
    
    if biometrics.age > 65 {
        notes.append("Take it slow and listen to your body")
    }
    
    if biometrics.bloodPressureSystolic >= 140 {
        notes.append("Monitor blood pressure before and after activity")
    }
    
    if biometrics.stressLevel == .high {
        notes.append("Use this activity as stress relief")
    }
    
    return notes
}

private func determineIntensityLevel(for biometrics: UserBiometrics) -> String {
    if biometrics.cardiovascularFitness == .poor || biometrics.age > 70 {
        return "Low"
    } else if biometrics.cardiovascularFitness == .excellent && biometrics.currentActivityLevel == .veryActive {
        return "High"
    } else {
        return "Moderate"
    }
}

private func generateSafetyConsiderations(for biometrics: UserBiometrics) -> [String] {
    var considerations: [String] = []
    
    considerations.append("Check blood sugar before and after exercise")
    considerations.append("Carry identification and medical information")
    
    if biometrics.bloodPressureSystolic >= 140 {
        considerations.append("Monitor blood pressure during activity")
    }
    
    if biometrics.chronicConditions.contains(.arthritis) {
        considerations.append("Avoid high-impact activities that stress joints")
    }
    
    if biometrics.disabilities.contains(.visualImpairment) {
        considerations.append("Exercise in familiar, well-lit areas")
    }
    
    // General safety reminders
    considerations.append("Always warm up before exercise and cool down afterward")
    considerations.append("Listen to your body and stop if you experience pain, dizziness, or unusual symptoms")
    considerations.append("Stay hydrated and have water available during exercise")
    considerations.append("Consult your healthcare provider before starting any new exercise program")
    
    return considerations
}