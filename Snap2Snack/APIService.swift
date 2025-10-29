import Foundation
import UIKit

class APIService: ObservableObject {
    static let shared = APIService()
    
    private init() {}
    
    // MARK: - Image Processing Helper
    private func resizeImageIfNeeded(_ image: UIImage) -> UIImage {
        let maxSize = Config.maxImageSize
        
        // Check if image needs resizing
        if image.size.width <= maxSize && image.size.height <= maxSize {
            return image
        }
        
        // Calculate new size maintaining aspect ratio
        let aspectRatio = image.size.width / image.size.height
        var newSize: CGSize
        
        if image.size.width > image.size.height {
            newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
        } else {
            newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
        }
        
        // Resize the image with high quality scaling
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
    
    // MARK: - Additional Image Optimization
    private func optimizeImageForAPI(_ image: UIImage) -> UIImage {
        // First resize if needed
        let resizedImage = resizeImageIfNeeded(image)
        
        // Try multiple compression levels to find the best balance
        let compressionLevels: [CGFloat] = [0.3, 0.2, 0.1]
        
        for compression in compressionLevels {
            if let imageData = resizedImage.jpegData(compressionQuality: compression) {
                // Check if the resulting data is small enough (under 500KB)
                if imageData.count < 500_000 {
                    print("✅ Optimized image: \(imageData.count) bytes at compression \(compression)")
                    return UIImage(data: imageData) ?? resizedImage
                }
            }
        }
        
        // If still too large, try even more aggressive resizing
        let ultraSmallSize: CGFloat = 256
        let aspectRatio = resizedImage.size.width / resizedImage.size.height
        var ultraSmallNewSize: CGSize
        
        if resizedImage.size.width > resizedImage.size.height {
            ultraSmallNewSize = CGSize(width: ultraSmallSize, height: ultraSmallSize / aspectRatio)
        } else {
            ultraSmallNewSize = CGSize(width: ultraSmallSize * aspectRatio, height: ultraSmallSize)
        }
        
        UIGraphicsBeginImageContextWithOptions(ultraSmallNewSize, false, 0.0)
        resizedImage.draw(in: CGRect(origin: .zero, size: ultraSmallNewSize))
        let ultraSmallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        print("⚠️ Using ultra-small image: \(ultraSmallNewSize)")
        return ultraSmallImage ?? resizedImage
    }
    
    func analyzeFoodImage(_ image: UIImage, completion: @escaping (Result<ScanResult, Error>) -> Void) {
        guard Config.isAPIKeyConfigured else {
            completion(.failure(APIError.missingAPIKey))
            return
        }
        
        // Optimize image for API (resize and compress)
        let processedImage = optimizeImageForAPI(image)
        print("✅ Original image size: \(image.size), Processed size: \(processedImage.size)")
        
        // Convert image to base64 with better error handling
        guard let imageData = processedImage.jpegData(compressionQuality: Config.imageCompressionQuality) else {
            print("❌ Failed to convert image to JPEG data")
            completion(.failure(APIError.imageProcessingFailed))
            return
        }
        
        // Check if image data is valid
        guard imageData.count > 0 else {
            print("❌ Image data is empty")
            completion(.failure(APIError.imageProcessingFailed))
            return
        }
        
        print("✅ Image data size: \(imageData.count) bytes")
        
        // Check if image is still too large (over 1MB is risky)
        if imageData.count > 1_000_000 {
            print("⚠️ Warning: Image is still large (\(imageData.count) bytes), may cause API issues")
        }
        
        let base64Image = imageData.base64EncodedString()
        
        // Check if base64 encoding worked
        guard !base64Image.isEmpty else {
            print("❌ Base64 encoding failed")
            completion(.failure(APIError.imageProcessingFailed))
            return
        }
        
        print("✅ Base64 string length: \(base64Image.count) characters")
        
        // Create the request for grocery analysis
        let request = createGroceryAnalysisRequest(imageBase64: base64Image)
        
        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                DispatchQueue.main.async {
                    completion(.failure(APIError.invalidResponse))
                }
                return
            }
            
            guard let data = data else {
                print("❌ No data received from server")
                DispatchQueue.main.async {
                    completion(.failure(APIError.noDataReceived))
                }
                return
            }
            
            print("✅ Received \(data.count) bytes from API")
            
            // Handle non-2xx responses by surfacing server error message
            if !(200...299).contains(httpResponse.statusCode) {
                if let serverMessage = Self.extractServerErrorMessage(from: data) {
                    print("❌ Server error (\(httpResponse.statusCode)): \(serverMessage)")
                    DispatchQueue.main.async {
                        completion(.failure(APIError.server(serverMessage)))
                    }
                } else {
                    print("❌ Server error (\(httpResponse.statusCode)) with undecodable body")
                    DispatchQueue.main.async {
                        completion(.failure(APIError.invalidResponse))
                    }
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
                print("❌ JSON parsing error: \(error)")
                print("Raw response: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
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
        
        // Optimize image for API (resize and compress)
        let processedImage = optimizeImageForAPI(image)
        print("✅ Original fridge image size: \(image.size), Processed size: \(processedImage.size)")
        
        // Convert image to base64 with better error handling
        guard let imageData = processedImage.jpegData(compressionQuality: Config.imageCompressionQuality) else {
            print("❌ Failed to convert fridge image to JPEG data")
            completion(.failure(APIError.imageProcessingFailed))
            return
        }
        
        // Check if image data is valid
        guard imageData.count > 0 else {
            print("❌ Fridge image data is empty")
            completion(.failure(APIError.imageProcessingFailed))
            return
        }
        
        print("✅ Fridge image data size: \(imageData.count) bytes")
        
        // Check if image is still too large (over 1MB is risky)
        if imageData.count > 1_000_000 {
            print("⚠️ Warning: Fridge image is still large (\(imageData.count) bytes), may cause API issues")
        }
        
        let base64Image = imageData.base64EncodedString()
        
        // Check if base64 encoding worked
        guard !base64Image.isEmpty else {
            print("❌ Fridge base64 encoding failed")
            completion(.failure(APIError.imageProcessingFailed))
            return
        }
        
        print("✅ Fridge base64 string length: \(base64Image.count) characters")
        
        // Create the request for fridge analysis
        let request = createFridgeAnalysisRequest(imageBase64: base64Image)
        
        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Fridge network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response (fridge)")
                DispatchQueue.main.async {
                    completion(.failure(APIError.invalidResponse))
                }
                return
            }
            
            guard let data = data else {
                print("❌ No fridge data received from server")
                DispatchQueue.main.async {
                    completion(.failure(APIError.noDataReceived))
                }
                return
            }
            
            print("✅ Received \(data.count) bytes from fridge API")
            
            // Handle non-2xx responses by surfacing server error message
            if !(200...299).contains(httpResponse.statusCode) {
                if let serverMessage = Self.extractServerErrorMessage(from: data) {
                    print("❌ Fridge server error (\(httpResponse.statusCode)): \(serverMessage)")
                    DispatchQueue.main.async {
                        completion(.failure(APIError.server(serverMessage)))
                    }
                } else {
                    print("❌ Fridge server error (\(httpResponse.statusCode)) with undecodable body")
                    DispatchQueue.main.async {
                        completion(.failure(APIError.invalidResponse))
                    }
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
                print("❌ Fridge JSON parsing error: \(error)")
                print("Raw fridge response: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
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
        
        let requestBody = OAIChatRequest(
            model: "gpt-4o-mini",
            messages: [
                OAIChatMessage(
                    role: "user",
                    content: [
                        .text("""
                        Analyze this food image for diabetes management. You are a diabetes nutrition expert.
                        Respond ONLY in this exact JSON format with no extra text:
                        {
                            \"foodName\": \"exact food name\",
                            \"isDiabetesFriendly\": true/false,
                            \"confidence\": 0.0-1.0,
                            \"recommendation\": \"detailed recommendation with emojis\",
                            \"nutritionData\": {
                                \"calories\": number,
                                \"carbs\": number,
                                \"protein\": number,
                                \"fiber\": number,
                                \"sugar\": number,
                                \"glycemicIndex\": \"Very Low/Low/Medium/High\"
                            }
                        }
                        Consider: glycemic index, fiber and sugar content, portion size, and overall nutritional value for diabetes management.
                        """),
                        .imageURL("data:image/jpeg;base64,\(imageBase64)")
                    ]
                )
            ],
            max_tokens: min(800, Config.maxTokens),
            temperature: Config.temperature
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            print("✅ Grocery request body encoded successfully, size: \(request.httpBody?.count ?? 0) bytes")
        } catch {
            print("❌ Error encoding grocery request: \(error)")
            return request
        }
        
        return request
    }
    
    private func createFridgeAnalysisRequest(imageBase64: String) -> URLRequest {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Config.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = OAIChatRequest(
            model: "gpt-4o-mini",
            messages: [
                OAIChatMessage(
                    role: "user",
                    content: [
                        .text("""
                        Analyze this fridge image and create diabetes-friendly meal suggestions. You are a diabetes nutrition expert.
                        Respond ONLY in this exact JSON format and no extra text:
                        {
                            \"detectedFoods\": [
                                {\"name\": \"food name\", \"confidence\": 0.0-1.0, \"category\": \"category\", \"isFresh\": true/false}
                            ],
                            \"mealSuggestions\": [
                                {
                                    \"name\": \"meal name\",
                                    \"description\": \"detailed description\",
                                    \"cookingTime\": \"time\",
                                    \"difficulty\": \"Easy/Medium/Hard\",
                                    \"glycemicIndex\": \"Low/Medium/High\",
                                    \"calories\": \"number\",
                                    \"protein\": \"number\",
                                    \"carbs\": \"number\",
                                    \"fiber\": \"number\",
                                    \"ingredients\": [\"ingredient1\", \"ingredient2\"],
                                    \"instructions\": [\"step1\", \"step2\"],
                                    \"nutritionBenefits\": \"benefits for diabetes\"
                                }
                            ]
                        }
                        Focus on low-glycemic, high-fiber, balanced meals that help manage blood sugar.
                        """),
                        .imageURL("data:image/jpeg;base64,\(imageBase64)")
                    ]
                )
            ],
            max_tokens: min(1200, Config.maxTokens),
            temperature: Config.temperature
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            print("✅ Fridge request body encoded successfully, size: \(request.httpBody?.count ?? 0) bytes")
        } catch {
            print("❌ Error encoding fridge request: \(error)")
            return request
        }
        
        return request
    }
    
    private func parseGroceryAnalysisResponse(_ response: OpenAIResponse) -> ScanResult {
        let content = response.choices.first?.message.content ?? ""
        
        do {
            // Try to parse JSON response
            if let jsonData = extractJSONData(from: content) ?? content.data(using: .utf8) {
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
            if let jsonData = extractJSONData(from: content) ?? content.data(using: .utf8) {
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

// MARK: - JSON Extraction Helper
private extension APIService {
    func extractJSONData(from text: String) -> Data? {
        // Strip code fences if present
        var cleaned = text
        if cleaned.contains("```") {
            cleaned = cleaned.replacingOccurrences(of: "```json", with: "")
            cleaned = cleaned.replacingOccurrences(of: "```", with: "")
        }
        // Trim whitespace/newlines
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        // Try to find the first JSON object substring
        if let startIndex = cleaned.firstIndex(of: "{"), let endIndex = cleaned.lastIndex(of: "}") , startIndex < endIndex {
            let jsonSubstring = cleaned[startIndex...endIndex]
            if let data = String(jsonSubstring).data(using: .utf8) {
                return data
            }
        }
        return nil
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
    case server(String)
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "🔑 OpenAI API key is not configured. Please set the OPENAI_API_KEY environment variable in Xcode (Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables). See API_KEY_SETUP.md for detailed instructions."
        case .imageProcessingFailed:
            return "Failed to process the image. Please try again."
        case .noDataReceived:
            return "No data received from the server. Please check your connection."
        case .invalidResponse:
            return "Invalid response from the server. Please try again."
        case .server(let message):
            return message
        }
    }
}

// MARK: - OpenAI Vision Chat Request Types (Encodable only)
private struct OAIChatRequest: Encodable {
    let model: String
    let messages: [OAIChatMessage]
    let max_tokens: Int
    let temperature: Double
}

private struct OAIChatMessage: Encodable {
    let role: String
    let content: [OAIContent]
}

private enum OAIContent: Encodable {
    case text(String)
    case imageURL(String)
    
    enum CodingKeys: String, CodingKey { case type, text, image_url }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let value):
            try container.encode("text", forKey: .type)
            try container.encode(value, forKey: .text)
        case .imageURL(let url):
            try container.encode("image_url", forKey: .type)
            try container.encode(["url": url], forKey: .image_url)
        }
    }
}

// MARK: - Server error decoding helper
private struct OpenAIErrorEnvelope: Codable { let error: OpenAIAPIError }
private struct OpenAIAPIError: Codable { let message: String }

extension APIService {
    fileprivate static func extractServerErrorMessage(from data: Data) -> String? {
        if let envelope = try? JSONDecoder().decode(OpenAIErrorEnvelope.self, from: data) {
            return envelope.error.message
        }
        return nil
    }
}
