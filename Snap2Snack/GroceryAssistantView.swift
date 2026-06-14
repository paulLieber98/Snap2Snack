//
//  GroceryAssistantView.swift
//  Snap2Snack
//
//  Created by Assistant on 5/13/26.
//

import SwiftUI

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
                                
                                if nutritionData != nil {
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
            CameraView(image: $selectedImage, showingCamera: $showingCamera)
        }
        .sheet(isPresented: $showingNutritionDetails) {
            if let nutrition = nutritionData {
                NutritionDetailView(nutrition: nutrition)
            }
        }
        .onChange(of: selectedImage) {
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
