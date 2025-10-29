import Foundation

struct Config {
    // MARK: - API Configuration
    // Try to get API key from environment variable first, then fallback to placeholder
    static let openAIAPIKey: String = {
        // First try to get from environment variable (for development)
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        
        // Fallback to placeholder for public repo
        return "***REMOVED***"
    }()
    
    // MARK: - App Configuration
    static let maxScanHistory = 10
    static let maxFridgeHistory = 5
    static let imageCompressionQuality: CGFloat = 0.3  // Much lower compression for smaller files
    static let maxImageSize: CGFloat = 512  // Much smaller max size for API compatibility
    static let maxTokens = 2000
    static let temperature: Double = 0.3
    
    // MARK: - Validation
    static var isAPIKeyConfigured: Bool {
        return !openAIAPIKey.isEmpty && 
               openAIAPIKey != "***REMOVED***" &&
               openAIAPIKey.hasPrefix("sk-") &&
               openAIAPIKey.count > 20
    }
    
    // MARK: - Debug Information
    static var apiKeyStatus: String {
        if openAIAPIKey.isEmpty {
            return "❌ No API key found"
        } else if openAIAPIKey == "***REMOVED***" {
            return "⚠️ Using placeholder API key"
        } else if !openAIAPIKey.hasPrefix("sk-") {
            return "⚠️ API key doesn't start with 'sk-'"
        } else if openAIAPIKey.count <= 20 {
            return "⚠️ API key seems too short"
        } else {
            return "✅ API key appears valid"
        }
    }
}
