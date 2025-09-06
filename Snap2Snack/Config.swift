import Foundation

struct Config {
    // MARK: - API Configuration
    static let openAIAPIKey = "***REMOVED***"
    
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
