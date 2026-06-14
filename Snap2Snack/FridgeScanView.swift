//
//  FridgeScanView.swift
//  Snap2Snack
//
//  Created by Assistant on 5/13/26.
//

import SwiftUI

struct FridgeScanView: View {
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var mealSuggestions: [MealSuggestion] = []
    @State private var isScanning = false
    @State private var detectedFoods: [DetectedFood] = []
    @State private var showingMealDetail = false
    @State private var selectedMeal: MealSuggestion?
    @State private var scanHistory: [FridgeScan] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "refrigerator.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Fridge Scan")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                        
                        Text("Scan your fridge to get healthy meal suggestions")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Scan Button
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                            Text("Scan Fridge")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.green)
                                .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Selected Image Display
                    if let image = selectedImage {
                        VStack(spacing: 12) {
                            Text("Fridge Contents")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(16)
                                .shadow(radius: 8)
                            
                            if isScanning {
                                VStack(spacing: 8) {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                    Text("AI is analyzing your fridge...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Detected Foods
                    if !detectedFoods.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Detected Foods")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            LazyVStack(spacing: 8) {
                                ForEach(detectedFoods) { food in
                                    DetectedFoodRow(food: food)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                    }
                    
                    // Meal Suggestions
                    if !mealSuggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("AI-Generated Meal Suggestions")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("\(mealSuggestions.count) recipes")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(12)
                            }
                            
                            LazyVStack(spacing: 12) {
                                ForEach(mealSuggestions) { meal in
                                    MealSuggestionCard(meal: meal) {
                                        selectedMeal = meal
                                        showingMealDetail = true
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                    }
                    
                    // Scan History
                    if !scanHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Scans")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            LazyVStack(spacing: 8) {
                                ForEach(scanHistory.prefix(3)) { scan in
                                    FridgeScanHistoryRow(scan: scan)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingMealDetail) {
            if let meal = selectedMeal {
                MealDetailView(meal: meal)
            }
        }
        .onChange(of: selectedImage) {
            if selectedImage != nil {
                scanFridge()
            }
        }
    }
    
    private func scanFridge() {
        isScanning = true
        mealSuggestions = []
        detectedFoods = []
        
        // Enhanced AI simulation with realistic food detection
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 2.0...4.0)) {
            // Simulate detected foods
            detectedFoods = [
                DetectedFood(name: "Chicken Breast", confidence: 0.95, category: "Protein", isFresh: true),
                DetectedFood(name: "Spinach", confidence: 0.92, category: "Vegetables", isFresh: true),
                DetectedFood(name: "Greek Yogurt", confidence: 0.89, category: "Dairy", isFresh: true),
                DetectedFood(name: "Quinoa", confidence: 0.87, category: "Grains", isFresh: true),
                DetectedFood(name: "Tomatoes", confidence: 0.91, category: "Vegetables", isFresh: true),
                DetectedFood(name: "Eggs", confidence: 0.94, category: "Protein", isFresh: true)
            ]
            
            // Generate meal suggestions based on detected foods
            mealSuggestions = [
                MealSuggestion(
                    name: "Grilled Chicken Quinoa Bowl",
                    description: "High-protein bowl with grilled chicken, quinoa, and fresh vegetables. Perfect for maintaining stable blood sugar levels.",
                    cookingTime: "25 min",
                    difficulty: "Easy",
                    glycemicIndex: "Low",
                    calories: "420",
                    protein: "35g",
                    carbs: "28g",
                    fiber: "8g",
                    ingredients: ["Chicken Breast", "Quinoa", "Spinach", "Tomatoes"],
                    instructions: [
                        "Season chicken breast with herbs and grill for 6-8 minutes per side",
                        "Cook quinoa according to package instructions",
                        "Sauté spinach and tomatoes in olive oil",
                        "Combine all ingredients in a bowl and serve"
                    ],
                    nutritionBenefits: "High protein content helps regulate blood sugar, while quinoa provides complex carbohydrates with low glycemic impact."
                ),
                MealSuggestion(
                    name: "Protein-Packed Spinach Salad",
                    description: "Fresh spinach salad with hard-boiled eggs and Greek yogurt dressing. Low-carb option rich in nutrients.",
                    cookingTime: "15 min",
                    difficulty: "Easy",
                    glycemicIndex: "Very Low",
                    calories: "280",
                    protein: "22g",
                    carbs: "12g",
                    fiber: "6g",
                    ingredients: ["Spinach", "Eggs", "Greek Yogurt", "Tomatoes"],
                    instructions: [
                        "Hard-boil eggs for 10 minutes, then slice",
                        "Wash and prepare fresh spinach",
                        "Mix Greek yogurt with herbs for dressing",
                        "Assemble salad and drizzle with dressing"
                    ],
                    nutritionBenefits: "Spinach is rich in fiber and antioxidants, while eggs provide high-quality protein for blood sugar stability."
                ),
                MealSuggestion(
                    name: "Greek Yogurt Parfait",
                    description: "Layered Greek yogurt with fresh berries and nuts. High-protein breakfast that won't spike blood sugar.",
                    cookingTime: "5 min",
                    difficulty: "Easy",
                    glycemicIndex: "Low",
                    calories: "320",
                    protein: "28g",
                    carbs: "18g",
                    fiber: "4g",
                    ingredients: ["Greek Yogurt", "Berries", "Nuts", "Honey (optional)"],
                    instructions: [
                        "Layer Greek yogurt in a glass or bowl",
                        "Add fresh berries and a drizzle of honey if desired",
                        "Top with crushed nuts for added protein and healthy fats",
                        "Serve immediately for best texture"
                    ],
                    nutritionBenefits: "Greek yogurt is high in protein and probiotics, helping maintain stable blood sugar and gut health."
                ),
                MealSuggestion(
                    name: "Vegetable Frittata",
                    description: "Fluffy egg frittata loaded with fresh vegetables. Perfect for any meal with excellent protein balance.",
                    cookingTime: "20 min",
                    difficulty: "Medium",
                    glycemicIndex: "Very Low",
                    calories: "380",
                    protein: "26g",
                    carbs: "14g",
                    fiber: "5g",
                    ingredients: ["Eggs", "Spinach", "Tomatoes", "Cheese"],
                    instructions: [
                        "Whisk eggs with salt and pepper",
                        "Sauté vegetables in an oven-safe pan",
                        "Pour egg mixture over vegetables",
                        "Cook on stovetop, then finish under broiler"
                    ],
                    nutritionBenefits: "Eggs provide complete protein while vegetables add fiber and nutrients, creating a balanced meal for diabetes management."
                )
            ]
            
            // Add to scan history
            let newScan = FridgeScan(
                timestamp: Date(),
                detectedFoods: detectedFoods,
                generatedMeals: mealSuggestions.count
            )
            scanHistory.insert(newScan, at: 0)
            if scanHistory.count > 5 {
                scanHistory = Array(scanHistory.prefix(5))
            }
            
            isScanning = false
        }
    }
}

// MARK: - Supporting Views
struct DetectedFoodRow: View {
    let food: DetectedFood
    
    var body: some View {
        HStack {
            Image(systemName: getCategoryIcon())
                .foregroundColor(getCategoryColor())
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(food.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Text(food.isFresh ? "Fresh" : "Not Fresh")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(food.isFresh ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        .foregroundColor(food.isFresh ? .green : .red)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Text("\(Int(food.confidence * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func getCategoryIcon() -> String {
        switch food.category {
        case "Protein": return "fish.fill"
        case "Vegetables": return "leaf.fill"
        case "Fruits": return "apple.fill"
        case "Dairy": return "cup.and.saucer.fill"
        case "Grains": return "wheat.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    private func getCategoryColor() -> Color {
        switch food.category {
        case "Protein": return .red
        case "Vegetables": return .green
        case "Fruits": return .orange
        case "Dairy": return .blue
        case "Grains": return .yellow
        default: return .gray
        }
    }
}

struct FridgeScanHistoryRow: View {
    let scan: FridgeScan
    
    var body: some View {
        HStack {
            Image(systemName: "refrigerator.fill")
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(scan.timestamp, style: .date)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(scan.detectedFoods.count) foods detected, \(scan.generatedMeals) recipes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(scan.timestamp, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
