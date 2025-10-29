import Foundation
import UIKit

class APIService: ObservableObject {
    static let shared = APIService()
    
    private init() {}
    
    func analyzeFoodImage(_ image: UIImage, completion: @escaping (Result<ScanResult, Error>) -> Void) {
        guard Config.isAPIKeyConfigured else {
            completion(.failure(APIError.missingAPIKey))
            return
        }
        
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: Config.imageCompressionQuality) else {
            completion(.failure(APIError.imageProcessingFailed))
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        
        // Create the request for grocery analysis
        let request = createGroceryAnalysisRequest(imageBase64: base64Image)
        
        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(APIError.noDataReceived))
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                let scanResult = self.parseGroceryAnalysisResponse(response)
                DispatchQueue.main.async {
                    completion(.success(scanResult))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func analyzeFridgeImage(_ image: UIImage, completion: @escaping (Result<FridgeAnalysisResult, Error>) -> Void) {
        guard Config.isAPIKeyConfigured else {
            completion(.failure(APIError.missingAPIKey))
            return
        }
        
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: Config.imageCompressionQuality) else {
            completion(.failure(APIError.imageProcessingFailed))
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        
        // Create the request for fridge analysis
        let request = createFridgeAnalysisRequest(imageBase64: base64Image)
        
        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(APIError.noDataReceived))
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                let fridgeResult = self.parseFridgeAnalysisResponse(response)
                DispatchQueue.main.async {
                    completion(.success(fridgeResult))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    private func createGroceryAnalysisRequest(imageBase64: String) -> URLRequest {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Config.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = OpenAIRequest(
            model: "gpt-4o-mini",
            messages: [
                OpenAIMessage(
                    role: "user",
                    content: """
                    Analyze this food image for diabetes management. You are a diabetes nutrition expert. 
                    Provide a detailed analysis in this exact JSON format:
                    {
                        "foodName": "exact food name",
                        "isDiabetesFriendly": true/false,
                        "confidence": 0.0-1.0,
                        "recommendation": "detailed recommendation with emojis",
                        "nutritionData": {
                            "calories": number,
                            "carbs": number,
                            "protein": number,
                            "fiber": number,
                            "sugar": number,
                            "glycemicIndex": "Very Low/Low/Medium/High"
                        }
                    }
                    
                    Consider: glycemic index, fiber content, sugar content, portion size, and overall nutritional value for diabetes management.
                    [Image: data:image/jpeg;base64,\(imageBase64)]
                    """
                )
            ],
            maxTokens: Config.maxTokens,
            temperature: Config.temperature
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            print("Error encoding request: \(error)")
        }
        
        return request
    }
    
    private func createFridgeAnalysisRequest(imageBase64: String) -> URLRequest {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Config.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = OpenAIRequest(
            model: "gpt-4o-mini",
            messages: [
                OpenAIMessage(
                    role: "user",
                    content: """
                    Analyze this fridge image and create diabetes-friendly meal suggestions. You are a diabetes nutrition expert.
                    Identify all visible foods and create 3 meal suggestions in this exact JSON format:
                    {
                        "detectedFoods": [
                            {"name": "food name", "confidence": 0.0-1.0, "category": "category", "isFresh": true/false}
                        ],
                        "mealSuggestions": [
                            {
                                "name": "meal name",
                                "description": "detailed description",
                                "cookingTime": "time",
                                "difficulty": "Easy/Medium/Hard",
                                "glycemicIndex": "Low/Medium/High",
                                "calories": "number",
                                "protein": "number",
                                "carbs": "number",
                                "fiber": "number",
                                "ingredients": ["ingredient1", "ingredient2"],
                                "instructions": ["step1", "step2"],
                                "nutritionBenefits": "benefits for diabetes"
                            }
                        ]
                    }
                    
                    Focus on low-glycemic, high-fiber, balanced meals that help manage blood sugar.
                    [Image: data:image/jpeg;base64,\(imageBase64)]
                    """
                )
            ],
            maxTokens: Config.maxTokens,
            temperature: Config.temperature
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            print("Error encoding request: \(error)")
        }
        
        return request
    }
    
    private func parseGroceryAnalysisResponse(_ response: OpenAIResponse) -> ScanResult {
        let content = response.choices.first?.message.content ?? ""
        
        do {
            // Try to parse JSON response
            if let jsonData = content.data(using: .utf8) {
                let jsonResponse = try JSONDecoder().decode(GroceryAnalysisResponse.self, from: jsonData)
                return ScanResult(
                    foodName: jsonResponse.foodName,
                    isDiabetesFriendly: jsonResponse.isDiabetesFriendly,
                    confidence: jsonResponse.confidence,
                    recommendation: jsonResponse.recommendation,
                    nutritionData: jsonResponse.nutritionData
                )
            }
        } catch {
            print("Error parsing grocery analysis JSON: \(error)")
        }
        
        // Fallback to text parsing if JSON fails
        return ScanResult(
            foodName: "Analyzed Food",
            isDiabetesFriendly: content.contains("diabetes-friendly") || content.contains("good choice"),
            confidence: 0.75,
            recommendation: content,
            nutritionData: NutritionData(
                calories: 100,
                carbs: 15.0,
                protein: 5.0,
                fiber: 2.0,
                sugar: 3.0,
                glycemicIndex: "Medium"
            )
        )
    }
    
    private func parseFridgeAnalysisResponse(_ response: OpenAIResponse) -> FridgeAnalysisResult {
        let content = response.choices.first?.message.content ?? ""
        
        do {
            // Try to parse JSON response
            if let jsonData = content.data(using: .utf8) {
                let jsonResponse = try JSONDecoder().decode(FridgeAnalysisResponseCodable.self, from: jsonData)
                
                // Convert Codable structs to non-Codable structs
                let detectedFoods = jsonResponse.detectedFoods.map { codableFood in
                    DetectedFood(
                        name: codableFood.name,
                        confidence: codableFood.confidence,
                        category: codableFood.category,
                        isFresh: codableFood.isFresh
                    )
                }
                
                let mealSuggestions = jsonResponse.mealSuggestions.map { codableMeal in
                    MealSuggestion(
                        name: codableMeal.name,
                        description: codableMeal.description,
                        cookingTime: codableMeal.cookingTime,
                        difficulty: codableMeal.difficulty,
                        glycemicIndex: codableMeal.glycemicIndex,
                        calories: codableMeal.calories,
                        protein: codableMeal.protein ?? "",
                        carbs: codableMeal.carbs ?? "",
                        fiber: codableMeal.fiber ?? "",
                        ingredients: codableMeal.ingredients ?? [],
                        instructions: codableMeal.instructions ?? [],
                        nutritionBenefits: codableMeal.nutritionBenefits ?? ""
                    )
                }
                
                return FridgeAnalysisResult(
                    detectedFoods: detectedFoods,
                    mealSuggestions: mealSuggestions
                )
            }
        } catch {
            print("Error parsing fridge analysis JSON: \(error)")
        }
        
        // Fallback to default values if JSON parsing fails
        return FridgeAnalysisResult(
            detectedFoods: [
                DetectedFood(name: "Various Foods", confidence: 0.7, category: "Mixed", isFresh: true)
            ],
            mealSuggestions: [
                MealSuggestion(
                    name: "Healthy Meal",
                    description: "A balanced meal suggestion based on available ingredients.",
                    cookingTime: "20 min",
                    difficulty: "Easy",
                    glycemicIndex: "Low",
                    calories: "350",
                    protein: "25g",
                    carbs: "30g",
                    fiber: "8g",
                    ingredients: ["Available ingredients"],
                    instructions: ["Prepare ingredients", "Cook as desired"],
                    nutritionBenefits: "Balanced nutrition for diabetes management"
                )
            ]
        )
    }
}

// MARK: - API Models
struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let maxTokens: Int
    let temperature: Double
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
}

struct OpenAIChoice: Codable {
    let message: OpenAIMessage
}

// MARK: - Analysis Response Models
struct GroceryAnalysisResponse: Codable {
    let foodName: String
    let isDiabetesFriendly: Bool
    let confidence: Double
    let recommendation: String
    let nutritionData: NutritionData
}

// Codable version for JSON parsing
struct FridgeAnalysisResponseCodable: Codable {
    let detectedFoods: [DetectedFoodCodable]
    let mealSuggestions: [MealSuggestionCodable]
}

struct DetectedFoodCodable: Codable {
    let name: String
    let confidence: Double
    let category: String
    let isFresh: Bool
}

struct MealSuggestionCodable: Codable {
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
}

struct FridgeAnalysisResponse {
    let detectedFoods: [DetectedFood]
    let mealSuggestions: [MealSuggestion]
}

struct FridgeAnalysisResult {
    let detectedFoods: [DetectedFood]
    let mealSuggestions: [MealSuggestion]
}

// MARK: - Error Types
enum APIError: Error, LocalizedError {
    case missingAPIKey
    case imageProcessingFailed
    case noDataReceived
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key is not configured. Please add your API key to Config.swift"
        case .imageProcessingFailed:
            return "Failed to process the image. Please try again."
        case .noDataReceived:
            return "No data received from the server. Please check your connection."
        case .invalidResponse:
            return "Invalid response from the server. Please try again."
        }
    }
}
