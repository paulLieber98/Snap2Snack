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
        guard let imageData = image.jpegData(compressionQuality: Config.imageCompressionQuality),
              let base64Image = imageData.base64EncodedString() else {
            completion(.failure(APIError.imageProcessingFailed))
            return
        }
        
        // Create the request
        let request = createOpenAIRequest(imageBase64: base64Image)
        
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
                let scanResult = self.parseOpenAIResponse(response)
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
    
    private func createOpenAIRequest(imageBase64: String) -> URLRequest {
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
                    content: [
                        OpenAIContent(
                            type: "text",
                            text: "Analyze this food image for diabetes management. Provide: 1) Food name, 2) Is it diabetes-friendly (true/false), 3) Confidence score (0-1), 4) Recommendation, 5) Nutrition data (calories, carbs, protein, fiber, sugar, glycemic index). Respond in JSON format."
                        ),
                        OpenAIContent(
                            type: "image_url",
                            imageURL: OpenAIImageURL(url: "data:image/jpeg;base64,\(imageBase64)")
                        )
                    ]
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
    
    private func parseOpenAIResponse(_ response: OpenAIResponse) -> ScanResult {
        // Parse the AI response and create a ScanResult
        // This is a simplified version - you'd want more robust parsing
        let content = response.choices.first?.message.content ?? ""
        
        // For now, return a mock result based on the content
        // In a real implementation, you'd parse the JSON response
        return ScanResult(
            foodName: "AI Analyzed Food",
            isDiabetesFriendly: content.contains("diabetes-friendly") || content.contains("good choice"),
            confidence: 0.85,
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
    let content: [OpenAIContent]
}

struct OpenAIContent: Codable {
    let type: String
    let text: String?
    let imageURL: OpenAIImageURL?
    
    enum CodingKeys: String, CodingKey {
        case type, text
        case imageURL = "image_url"
    }
}

struct OpenAIImageURL: Codable {
    let url: String
}

struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
}

struct OpenAIChoice: Codable {
    let message: OpenAIMessage
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
