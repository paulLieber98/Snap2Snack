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
            
            // Reminders
            RemindersView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Reminders")
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
    @State private var showingNutritionDetails = false
    @State private var nutritionData: NutritionData?
    @State private var scanHistory: [ScanResult] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "camera.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Grocery Store Assistant")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                        
                        Text("Take a photo of food items to check if they're diabetes-friendly")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Camera Controls
                    HStack(spacing: 20) {
                        Button(action: {
                            showingCamera = true
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.title)
                                Text("Camera")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.green)
                                    .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                        }
                        
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.fill")
                                    .font(.title)
                                Text("Gallery")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.blue)
                                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Selected Image Display
                    if let image = selectedImage {
                        VStack(spacing: 12) {
                            Text("Selected Food Item")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(16)
                                .shadow(radius: 8)
                            
                            if isAnalyzing {
                                VStack(spacing: 8) {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                    Text("Analyzing with AI...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Analysis Results
                    if !analysisResult.isEmpty {
                        VStack(spacing: 16) {
                            Text("AI Analysis Result")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: getResultIcon())
                                        .font(.title)
                                        .foregroundColor(getResultColor())
                                    
                                    Text(analysisResult)
                                        .font(.body)
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.primary)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(getResultColor().opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(getResultColor().opacity(0.3), lineWidth: 1)
                                        )
                                )
                                
                                if let nutrition = nutritionData {
                                    Button("View Nutrition Details") {
                                        showingNutritionDetails = true
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.green)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Scan History
                    if !scanHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Scans")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            LazyVStack(spacing: 8) {
                                ForEach(scanHistory.prefix(5)) { result in
                                    ScanHistoryRow(result: result)
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
        .sheet(isPresented: $showingCamera) {
            CameraView(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingNutritionDetails) {
            if let nutrition = nutritionData {
                NutritionDetailView(nutrition: nutrition)
            }
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
        nutritionData = nil
        
        // Enhanced AI simulation with realistic delays and varied responses
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1.5...3.0)) {
            let results = [
                ScanResult(
                    foodName: "Fresh Spinach",
                    isDiabetesFriendly: true,
                    confidence: 0.94,
                    recommendation: "✅ Excellent choice! Spinach is very diabetes-friendly with low glycemic index and high fiber content.",
                    nutritionData: NutritionData(
                        calories: 23,
                        carbs: 3.6,
                        protein: 2.9,
                        fiber: 2.2,
                        sugar: 0.4,
                        glycemicIndex: "Very Low"
                    )
                ),
                ScanResult(
                    foodName: "Whole Grain Bread",
                    isDiabetesFriendly: true,
                    confidence: 0.87,
                    recommendation: "✅ Good choice! Whole grain bread has moderate carbs but high fiber content helps regulate blood sugar.",
                    nutritionData: NutritionData(
                        calories: 69,
                        carbs: 12.5,
                        protein: 3.6,
                        fiber: 1.8,
                        sugar: 1.1,
                        glycemicIndex: "Low"
                    )
                ),
                ScanResult(
                    foodName: "Greek Yogurt",
                    isDiabetesFriendly: true,
                    confidence: 0.91,
                    recommendation: "✅ Great choice! Greek yogurt is high in protein and low in carbs, perfect for diabetes management.",
                    nutritionData: NutritionData(
                        calories: 59,
                        carbs: 3.6,
                        protein: 10.0,
                        fiber: 0.0,
                        sugar: 3.2,
                        glycemicIndex: "Low"
                    )
                ),
                ScanResult(
                    foodName: "Soda",
                    isDiabetesFriendly: false,
                    confidence: 0.96,
                    recommendation: "❌ Avoid! High sugar content will cause rapid blood sugar spikes. Choose water or unsweetened beverages instead.",
                    nutritionData: NutritionData(
                        calories: 150,
                        carbs: 39.0,
                        protein: 0.0,
                        fiber: 0.0,
                        sugar: 39.0,
                        glycemicIndex: "Very High"
                    )
                ),
                ScanResult(
                    foodName: "White Rice",
                    isDiabetesFriendly: false,
                    confidence: 0.89,
                    recommendation: "⚠️ Limit intake! White rice has high glycemic index. Choose brown rice or quinoa for better blood sugar control.",
                    nutritionData: NutritionData(
                        calories: 130,
                        carbs: 28.0,
                        protein: 2.7,
                        fiber: 0.4,
                        sugar: 0.1,
                        glycemicIndex: "High"
                    )
                )
            ]
            
            let selectedResult = results.randomElement()!
            analysisResult = selectedResult.recommendation
            nutritionData = selectedResult.nutritionData
            
            // Add to scan history
            scanHistory.insert(selectedResult, at: 0)
            if scanHistory.count > 10 {
                scanHistory = Array(scanHistory.prefix(10))
            }
            
            isAnalyzing = false
        }
    }
    
    private func getResultIcon() -> String {
        if analysisResult.contains("✅") {
            return "checkmark.circle.fill"
        } else if analysisResult.contains("⚠️") {
            return "exclamationmark.triangle.fill"
        } else if analysisResult.contains("❌") {
            return "xmark.circle.fill"
        }
        return "questionmark.circle.fill"
    }
    
    private func getResultColor() -> Color {
        if analysisResult.contains("✅") {
            return .green
        } else if analysisResult.contains("⚠️") {
            return .orange
        } else if analysisResult.contains("❌") {
            return .red
        }
        return .gray
    }
}

// MARK: - Enhanced Data Models
struct ScanResult: Identifiable {
    let id = UUID()
    let foodName: String
    let isDiabetesFriendly: Bool
    let confidence: Double
    let recommendation: String
    let nutritionData: NutritionData
    let timestamp = Date()
}

struct NutritionData {
    let calories: Int
    let carbs: Double
    let protein: Double
    let fiber: Double
    let sugar: Double
    let glycemicIndex: String
}

// MARK: - Supporting Views
struct ScanHistoryRow: View {
    let result: ScanResult
    
    var body: some View {
        HStack {
            Image(systemName: result.isDiabetesFriendly ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(result.isDiabetesFriendly ? .green : .red)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.foodName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(result.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(Int(result.confidence * 100))%")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct NutritionDetailView: View {
    let nutrition: NutritionData
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        
                        Text("Nutritional Information")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    // Nutrition Facts
                    VStack(spacing: 16) {
                        Text("Nutrition Facts")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            NutritionRow(label: "Calories", value: "\(nutrition.calories)", unit: "kcal")
                            NutritionRow(label: "Carbohydrates", value: String(format: "%.1f", nutrition.carbs), unit: "g")
                            NutritionRow(label: "Protein", value: String(format: "%.1f", nutrition.protein), unit: "g")
                            NutritionRow(label: "Fiber", value: String(format: "%.1f", nutrition.fiber), unit: "g")
                            NutritionRow(label: "Sugar", value: String(format: "%.1f", nutrition.sugar), unit: "g")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Glycemic Index
                    VStack(spacing: 12) {
                        Text("Glycemic Index")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text(nutrition.glycemicIndex)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(getGlycemicColor())
                            
                            Spacer()
                            
                            Image(systemName: getGlycemicIcon())
                                .font(.title)
                                .foregroundColor(getGlycemicColor())
                        }
                        .padding()
                        .background(getGlycemicColor().opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Diabetes Impact
                    VStack(spacing: 12) {
                        Text("Diabetes Impact")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(getDiabetesImpact())
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Nutrition Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func getGlycemicColor() -> Color {
        switch nutrition.glycemicIndex {
        case "Very Low": return .green
        case "Low": return .blue
        case "Medium": return .orange
        case "High": return .red
        case "Very High": return .red
        default: return .gray
        }
    }
    
    private func getGlycemicIcon() -> String {
        switch nutrition.glycemicIndex {
        case "Very Low": return "arrow.down.circle.fill"
        case "Low": return "arrow.down.circle"
        case "Medium": return "minus.circle"
        case "High": return "arrow.up.circle"
        case "Very High": return "arrow.up.circle.fill"
        default: return "questionmark.circle"
        }
    }
    
    private func getDiabetesImpact() -> String {
        if nutrition.glycemicIndex == "Very Low" || nutrition.glycemicIndex == "Low" {
            return "This food is excellent for diabetes management. It will help maintain stable blood sugar levels."
        } else if nutrition.glycemicIndex == "Medium" {
            return "This food can be consumed in moderation. Monitor your blood sugar and consider portion control."
        } else {
            return "This food may cause rapid blood sugar spikes. Consider alternatives or consume in very small portions."
        }
    }
}

struct NutritionRow: View {
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text(value)
                    .fontWeight(.semibold)
                Text(unit)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Fridge Scan View
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
        .onChange(of: selectedImage) { _ in
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

// MARK: - Enhanced Data Models
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
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(food.confidence * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                HStack(spacing: 4) {
                    Image(systemName: food.isFresh ? "leaf.fill" : "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundColor(food.isFresh ? .green : .orange)
                    
                    Text(food.isFresh ? "Fresh" : "Check")
                        .font(.caption2)
                        .foregroundColor(food.isFresh ? .green : .orange)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func getCategoryIcon() -> String {
        switch food.category {
        case "Protein": return "flame.fill"
        case "Vegetables": return "leaf.fill"
        case "Dairy": return "drop.fill"
        case "Grains": return "circle.fill"
        case "Fruits": return "applelogo"
        default: return "questionmark.circle"
        }
    }
    
    private func getCategoryColor() -> Color {
        switch food.category {
        case "Protein": return .red
        case "Vegetables": return .green
        case "Dairy": return .blue
        case "Grains": return .orange
        case "Fruits": return .pink
        default: return .gray
        }
    }
}

struct FridgeScanHistoryRow: View {
    let scan: FridgeScan
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Fridge Scan")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(scan.detectedFoods.count) foods • \(scan.generatedMeals) meals")
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

// MARK: - Reminders View
struct RemindersView: View {
    @State private var showingAddReminder = false
    @State private var reminders: [Reminder] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "bell.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Reminders")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                        
                        Text("Set and manage your health reminders")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Reminders Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Reminders")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button("Add") {
                                showingAddReminder = true
                            }
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                        }
                        .padding(.horizontal)
                        
                        if reminders.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "bell.slash")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                
                                Text("No reminders set")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("Tap 'Add' to set your first reminder")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(reminders) { reminder in
                                    ReminderCard(reminder: reminder)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView(reminders: $reminders)
        }
        .onAppear {
            loadSampleReminders()
        }

    }
    

    

    
    private func loadSampleReminders() {
        let calendar = Calendar.current
        let now = Date()
        
        reminders = [
            Reminder(title: "Morning Glucose Check", time: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now) ?? now, type: .glucose),
            Reminder(title: "Take Medication", time: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: now) ?? now, type: .medication),
            Reminder(title: "Evening Glucose Check", time: calendar.date(bySettingHour: 20, minute: 0, second: 0, of: now) ?? now, type: .glucose)
        ]
    }
}

// MARK: - Enhanced Data Models
struct GlucoseEntry: Identifiable {
    let id = UUID()
    let level: Int
    let timestamp: Date
    let notes: String
}

// MARK: - Supporting Views
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
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.timestamp, style: .time)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text(entry.timestamp, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func getGlucoseColor(_ level: Int) -> Color {
        switch level {
        case 0..<70: return .red
        case 70..<140: return .green
        case 140..<200: return .orange
        default: return .red
        }
    }
}



// MARK: - Activity View
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
                            ScrollView(.horizontal, showsIndicators: false) {
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
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    FilterChip(
                                        title: "All Levels",
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
                    
                    // Activity List
                    if activities.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "figure.walk")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("No activities available")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Complete your biometric profile to get personalized recommendations")
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
            BiometricInputView(biometrics: $userBiometrics)
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
        .onChange(of: userBiometrics) { _ in
            userBiometrics.save()
            loadPersonalizedActivities()
        }
        .onChange(of: selectedCategory) { _ in
            filterActivities()
        }
        .onChange(of: selectedDifficulty) { _ in
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
                suitableFor: [.diabetes, .arthritis, .mobilityIssues, .wheelchair],
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
        if biometrics.fitnessLevel == .intermediate || biometrics.fitnessLevel == .advanced {
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
            // Check if user has any contraindications for this activity
            let hasContraindication = !Set(activity.contraindications).isDisjoint(with: Set(biometrics.healthConditions))
            if hasContraindication { return false }
            
            // Check if activity is suitable for user's conditions
            let hasSuitableCondition = Set(activity.suitableFor).isSuperset(of: Set(biometrics.healthConditions)) ||
                                     activity.suitableFor.contains(.diabetes) ||
                                     biometrics.healthConditions.isEmpty
            
            return hasSuitableCondition
        }
    }
}

// MARK: - Resources View
struct ResourcesView: View {
    @State private var resources: [Resource] = []
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "map.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Local Resources")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                        
                        Text("Find diabetes clinics, dietitians, and support groups near you")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Placeholder for resource search", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    
                    // Resources List
                    if resources.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "building.2")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("No resources found")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Placeholder for local diabetes resources")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(resources) { resource in
                                ResourceCard(resource: resource)
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
        .onAppear {
            loadSampleResources()
        }
    }
    
    private func loadSampleResources() {
        resources = [
            Resource(
                name: "Diabetes Care Center",
                type: "Clinic",
                address: "Placeholder for clinic address",
                phone: "Placeholder for phone number",
                acceptsInsurance: true,
                cost: "Placeholder for cost information"
            ),
            Resource(
                name: "Nutrition Specialist",
                type: "Dietitian",
                address: "Placeholder for dietitian address",
                phone: "Placeholder for phone number",
                acceptsInsurance: false,
                cost: "Placeholder for cost information"
            ),
            Resource(
                name: "Diabetes Support Group",
                type: "Support Group",
                address: "Placeholder for support group location",
                phone: "Placeholder for phone number",
                acceptsInsurance: true,
                cost: "Free"
            )
        ]
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

// MARK: - Data Models
struct Activity: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let duration: String
    let intensity: String
    let benefits: String
    let isSafe: Bool
    let difficulty: ActivityDifficulty
    let durationMinutes: Int
    let category: ActivityCategory
    let equipment: [String]
    let instructions: [String]
    let safetyTips: [String]
    let caloriesBurned: Int
    let heartRateZone: String
    let suitableFor: [HealthCondition]
    let contraindications: [HealthCondition]
}

enum ActivityDifficulty: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "leaf.fill"
        case .medium: return "flame.fill"
        case .high: return "bolt.fill"
        }
    }
}

enum ActivityCategory: String, CaseIterable {
    case cardio = "Cardio"
    case strength = "Strength"
    case flexibility = "Flexibility"
    case balance = "Balance"
    case lowImpact = "Low Impact"
    case diabetesSpecific = "Diabetes Specific"
}

enum HealthCondition: String, CaseIterable {
    case diabetes = "Diabetes"
    case hypertension = "Hypertension"
    case heartDisease = "Heart Disease"
    case arthritis = "Arthritis"
    case obesity = "Obesity"
    case mobilityIssues = "Mobility Issues"
    case visionProblems = "Vision Problems"
    case neuropathy = "Neuropathy"
    case kidneyDisease = "Kidney Disease"
    case none = "None"
}

struct UserBiometrics: Codable {
    var age: Int = 0
    var weight: Double = 0.0 // in kg
    var height: Double = 0.0 // in cm
    var fitnessLevel: FitnessLevel = .beginner
    var healthConditions: [HealthCondition] = []
    var disabilities: [Disability] = []
    var activityPreferences: [ActivityCategory] = []
    var maxHeartRate: Int = 0
    var bmi: Double = 0.0
    var isComplete: Bool = false
    
    mutating func calculateDerivedValues() {
        bmi = weight / ((height / 100) * (height / 100))
        maxHeartRate = 220 - age
        isComplete = age > 0 && weight > 0 && height > 0
    }
    
    // UserDefaults persistence
    static func load() -> UserBiometrics {
        if let data = UserDefaults.standard.data(forKey: "UserBiometrics"),
           let biometrics = try? JSONDecoder().decode(UserBiometrics.self, from: data) {
            return biometrics
        }
        return UserBiometrics()
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "UserBiometrics")
        }
    }
}

enum FitnessLevel: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var description: String {
        switch self {
        case .beginner: return "New to exercise or returning after a long break"
        case .intermediate: return "Regular exercise 2-3 times per week"
        case .advanced: return "Regular exercise 4+ times per week"
        }
    }
}

enum Disability: String, CaseIterable {
    case wheelchair = "Wheelchair User"
    case limitedMobility = "Limited Mobility"
    case visualImpairment = "Visual Impairment"
    case hearingImpairment = "Hearing Impairment"
    case cognitiveImpairment = "Cognitive Impairment"
    case none = "None"
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

// MARK: - Supporting View Components
struct MealSuggestionCard: View {
    let meal: MealSuggestion
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(meal.name)
                    .font(.headline)
                    .foregroundColor(.green)
                
                Text(meal.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Label(meal.cookingTime, systemImage: "clock")
                    Spacer()
                    Label(meal.difficulty, systemImage: "star")
                    Spacer()
                    Label(meal.glycemicIndex, systemImage: "heart")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                if let protein = meal.protein, let carbs = meal.carbs {
                    HStack {
                        Text("Protein: \(protein)")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Spacer()
                        Text("Carbs: \(carbs)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MealDetailView: View {
    let meal: MealSuggestion
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text(meal.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(meal.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Quick Info
                    HStack(spacing: 20) {
                        InfoCard(title: "Time", value: meal.cookingTime, icon: "clock.fill", color: .blue)
                        InfoCard(title: "Difficulty", value: meal.difficulty, icon: "star.fill", color: .orange)
                        InfoCard(title: "Glycemic", value: meal.glycemicIndex, icon: "heart.fill", color: .green)
                    }
                    
                    // Nutrition Facts
                    if let protein = meal.protein, let carbs = meal.carbs, let fiber = meal.fiber {
                        VStack(spacing: 16) {
                            Text("Nutrition Facts")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 12) {
                                NutritionRow(label: "Calories", value: meal.calories, unit: "kcal")
                                NutritionRow(label: "Protein", value: protein, unit: "g")
                                NutritionRow(label: "Carbohydrates", value: carbs, unit: "g")
                                NutritionRow(label: "Fiber", value: fiber, unit: "g")
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Ingredients
                    if let ingredients = meal.ingredients {
                        VStack(spacing: 16) {
                            Text("Ingredients")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 8) {
                                ForEach(ingredients, id: \.self) { ingredient in
                                    HStack {
                                        Image(systemName: "circle.fill")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                        Text(ingredient)
                                            .font(.body)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Instructions
                    if let instructions = meal.instructions {
                        VStack(spacing: 16) {
                            Text("Cooking Instructions")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 12) {
                                ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                                    HStack(alignment: .top, spacing: 12) {
                                        Text("\(index + 1)")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .frame(width: 30, height: 30)
                                            .background(Color.green)
                                            .cornerRadius(15)
                                        
                                        Text(instruction)
                                            .font(.body)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Nutrition Benefits
                    if let benefits = meal.nutritionBenefits {
                        VStack(spacing: 12) {
                            Text("Diabetes Benefits")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(benefits)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    
                    // Action Button
                    Button("Start Cooking") {
                        // Here you would start a cooking timer or add to meal plan
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .cornerRadius(12)
                    .font(.headline)
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Recipe Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
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

struct ReminderCard: View {
    let reminder: Reminder
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(reminder.time, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: reminder.type == .glucose ? "heart.fill" : "pills.fill")
                .foregroundColor(.green)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ActivityCard: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(activity.name)
                    .font(.headline)
                    .foregroundColor(.green)
                
                Spacer()
                
                Text(activity.duration)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Text(activity.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label(activity.intensity, systemImage: "flame")
                Spacer()
                if activity.isSafe {
                    Label("Safe", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct EnhancedActivityCard: View {
    let activity: Activity
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with name and difficulty
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(activity.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(activity.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(6)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: activity.difficulty.icon)
                                .font(.caption)
                            Text(activity.difficulty.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(activity.difficulty.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(activity.difficulty.color.opacity(0.2))
                        .cornerRadius(8)
                        
                        Text(activity.duration)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                // Description
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Stats row
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("\(activity.caloriesBurned) cal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text(activity.heartRateZone)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if activity.isSafe {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("Safe")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                // Equipment needed
                if !activity.equipment.isEmpty {
                    HStack {
                        Image(systemName: "bag.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("Equipment: \(activity.equipment.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BiometricStatusCard: View {
    let biometrics: UserBiometrics
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Profile")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if biometrics.isComplete {
                        Text("Profile Complete")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("Complete your profile for personalized recommendations")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                Button("Edit") {
                    onEdit()
                }
                .foregroundColor(.green)
                .fontWeight(.semibold)
            }
            
            if biometrics.isComplete {
                HStack(spacing: 20) {
                    BiometricStat(
                        title: "Age",
                        value: "\(biometrics.age)",
                        unit: "years",
                        color: .blue
                    )
                    
                    BiometricStat(
                        title: "BMI",
                        value: String(format: "%.1f", biometrics.bmi),
                        unit: "",
                        color: getBMIColor(biometrics.bmi)
                    )
                    
                    BiometricStat(
                        title: "Fitness",
                        value: biometrics.fitnessLevel.rawValue,
                        unit: "",
                        color: .green
                    )
                }
                
                if !biometrics.healthConditions.isEmpty {
                    HStack {
                        Text("Health Conditions:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(biometrics.healthConditions.map { $0.rawValue }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                }
            } else {
                HStack {
                    Image(systemName: "person.circle")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Add your biometric information to get personalized activity recommendations")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(biometrics.isComplete ? Color.green.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func getBMIColor(_ bmi: Double) -> Color {
        switch bmi {
        case 0..<18.5: return .blue
        case 18.5..<25: return .green
        case 25..<30: return .orange
        default: return .red
        }
    }
}

struct BiometricStat: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
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
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .green)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.green : Color.green.opacity(0.2))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ResourceCard: View {
    let resource: Resource
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(resource.name)
                    .font(.headline)
                    .foregroundColor(.green)
                
                Spacer()
                
                Text(resource.type)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Text(resource.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label(resource.phone, systemImage: "phone")
                Spacer()
                Label(resource.cost, systemImage: "dollarsign.circle")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            HStack {
                if resource.acceptsInsurance {
                    Label("Accepts Insurance", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Label("No Insurance", systemImage: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            .font(.caption)
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
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "figure.walk.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                Text(activity.name)
                            .font(.title)
                    .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                
                Text(activity.description)
                    .font(.body)
                            .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    }
                    
                    // Quick Info Cards
                    HStack(spacing: 16) {
                        InfoCard(
                            title: "Duration",
                            value: activity.duration,
                            icon: "clock.fill",
                            color: .blue
                        )
                        
                        InfoCard(
                            title: "Difficulty",
                            value: activity.difficulty.rawValue,
                            icon: activity.difficulty.icon,
                            color: activity.difficulty.color
                        )
                        
                        InfoCard(
                            title: "Calories",
                            value: "\(activity.caloriesBurned)",
                            icon: "flame.fill",
                            color: .orange
                        )
                    }
                    
                    // Category and Heart Rate
                    HStack(spacing: 16) {
                        InfoCard(
                            title: "Category",
                            value: activity.category.rawValue,
                            icon: "tag.fill",
                            color: .green
                        )
                        
                        InfoCard(
                            title: "Heart Rate",
                            value: activity.heartRateZone,
                            icon: "heart.fill",
                            color: .red
                        )
                    }
                    
                    // Equipment Needed
                    if !activity.equipment.isEmpty {
                        VStack(spacing: 12) {
                            Text("Equipment Needed")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                ForEach(activity.equipment, id: \.self) { item in
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text(item)
                                            .font(.subheadline)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Instructions
                VStack(spacing: 16) {
                        Text("Instructions")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            ForEach(Array(activity.instructions.enumerated()), id: \.offset) { index, instruction in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 30, height: 30)
                                        .background(Color.green)
                                        .cornerRadius(15)
                                    
                                    Text(instruction)
                                        .font(.body)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Safety Tips
                    VStack(spacing: 16) {
                        Text("Safety Tips")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            ForEach(activity.safetyTips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    
                                    Text(tip)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Benefits
                    VStack(spacing: 12) {
                        Text("Benefits")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(activity.benefits)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    // Action Button
                Button("Start Activity") {
                    // Here you would start the activity tracking
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                .background(Color.green)
                .cornerRadius(12)
                    .font(.headline)
                
                    Spacer(minLength: 50)
            }
            .padding()
            }
            .navigationTitle("Activity Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct BiometricInputView: View {
    @Binding var biometrics: UserBiometrics
    @Environment(\.presentationMode) var presentationMode
    @State private var tempBiometrics: UserBiometrics
    
    init(biometrics: Binding<UserBiometrics>) {
        self._biometrics = biometrics
        self._tempBiometrics = State(initialValue: biometrics.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Your Health Profile")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Help us personalize your activity recommendations")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Basic Information
                    VStack(spacing: 16) {
                        Text("Basic Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Age")
                                    .frame(width: 80, alignment: .leading)
                                TextField("Enter your age", value: $tempBiometrics.age, format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                            
                            HStack {
                                Text("Weight (kg)")
                                    .frame(width: 80, alignment: .leading)
                                TextField("Enter your weight", value: $tempBiometrics.weight, format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                            }
                            
                            HStack {
                                Text("Height (cm)")
                                    .frame(width: 80, alignment: .leading)
                                TextField("Enter your height", value: $tempBiometrics.height, format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Fitness Level
                    VStack(spacing: 16) {
                        Text("Fitness Level")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            ForEach(FitnessLevel.allCases, id: \.self) { level in
                                Button(action: {
                                    tempBiometrics.fitnessLevel = level
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(level.rawValue)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                            
                                            Text(level.description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        if tempBiometrics.fitnessLevel == level {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(tempBiometrics.fitnessLevel == level ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Health Conditions
                    VStack(spacing: 16) {
                        Text("Health Conditions")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Select any conditions that apply to you")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(HealthCondition.allCases, id: \.self) { condition in
                                if condition != .none {
                                    Button(action: {
                                        if tempBiometrics.healthConditions.contains(condition) {
                                            tempBiometrics.healthConditions.removeAll { $0 == condition }
                                        } else {
                                            tempBiometrics.healthConditions.append(condition)
                                        }
                                    }) {
                                        HStack {
                                            Text(condition.rawValue)
                                                .font(.caption)
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            if tempBiometrics.healthConditions.contains(condition) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                            } else {
                                                Image(systemName: "circle")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(tempBiometrics.healthConditions.contains(condition) ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    
                    // Disabilities
                    VStack(spacing: 16) {
                        Text("Disabilities or Limitations")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Select any limitations that apply to you")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(Disability.allCases, id: \.self) { disability in
                                if disability != .none {
                                    Button(action: {
                                        if tempBiometrics.disabilities.contains(disability) {
                                            tempBiometrics.disabilities.removeAll { $0 == disability }
                                        } else {
                                            tempBiometrics.disabilities.append(disability)
                                        }
                                    }) {
                                        HStack {
                                            Text(disability.rawValue)
                                                .font(.caption)
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            if tempBiometrics.disabilities.contains(disability) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                            } else {
                                                Image(systemName: "circle")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(tempBiometrics.disabilities.contains(disability) ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Health Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    tempBiometrics.calculateDerivedValues()
                    biometrics = tempBiometrics
                    biometrics.save()
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(!tempBiometrics.isComplete)
            )
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

