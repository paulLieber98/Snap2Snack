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
    static let imageCompressionQuality: CGFloat = 0.8
    static let maxTokens = 2000
    static let temperature: Double = 0.3
    
    // MARK: - Validation
    static var isAPIKeyConfigured: Bool {
        return !openAIAPIKey.isEmpty && openAIAPIKey != "***REMOVED***"
    }
}
