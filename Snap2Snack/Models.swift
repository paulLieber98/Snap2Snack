//
//  Models.swift
//  Snap2Snack
//
//  Created by Assistant on 5/13/26.
//

import Foundation

// MARK: - Grocery Analysis Models
struct ScanResult: Identifiable {
    let id = UUID()
    let foodName: String
    let isDiabetesFriendly: Bool
    let confidence: Double
    let recommendation: String
    let nutritionData: NutritionData
    let timestamp = Date()
}

struct NutritionData: Codable {
    let calories: Int
    let carbs: Double
    let protein: Double
    let fiber: Double
    let sugar: Double
    let glycemicIndex: String
}

// MARK: - Fridge Scan Models
struct DetectedFood: Identifiable {
    let id = UUID()
    let name: String
    let confidence: Double
    let category: String
    let isFresh: Bool
}

struct FridgeScan: Identifiable {
    let id = UUID()
    let timestamp: Date
    let detectedFoods: [DetectedFood]
    let generatedMeals: Int
}

struct MealSuggestion: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let cookingTime: String
    let difficulty: String
    let glycemicIndex: String
    let calories: String
    let protein: String?
    let carbs: String?
    let fiber: String?
    let ingredients: [String]?
    let instructions: [String]?
    let nutritionBenefits: String?
    
    // Default initializer for backward compatibility
    init(name: String, description: String, cookingTime: String, difficulty: String, glycemicIndex: String, calories: String) {
        self.name = name
        self.description = description
        self.cookingTime = cookingTime
        self.difficulty = difficulty
        self.glycemicIndex = glycemicIndex
        self.calories = calories
        self.protein = nil
        self.carbs = nil
        self.fiber = nil
        self.ingredients = nil
        self.instructions = nil
        self.nutritionBenefits = nil
    }
    
    // Enhanced initializer
    init(name: String, description: String, cookingTime: String, difficulty: String, glycemicIndex: String, calories: String, protein: String, carbs: String, fiber: String, ingredients: [String], instructions: [String], nutritionBenefits: String) {
        self.name = name
        self.description = description
        self.cookingTime = cookingTime
        self.difficulty = difficulty
        self.glycemicIndex = glycemicIndex
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fiber = fiber
        self.ingredients = ingredients
        self.instructions = instructions
        self.nutritionBenefits = nutritionBenefits
    }
}

struct Resource: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let address: String
    let phone: String
    let acceptsInsurance: Bool
    let cost: String
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
}

struct FridgeAnalysisResponse {
    let detectedFoods: [DetectedFood]
    let mealSuggestions: [MealSuggestion]
}

struct FridgeAnalysisResult {
    let detectedFoods: [DetectedFood]
    let mealSuggestions: [MealSuggestion]
}