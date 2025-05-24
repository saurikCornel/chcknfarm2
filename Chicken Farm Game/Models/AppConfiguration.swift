import Foundation

/// Configuration model for the farm management game
struct AppConfiguration {
    /// The base URL for the game's web resources
    let gameResourceURL: URL
    
    /// Optional custom configuration parameters
    let customParameters: [String: Any]?
    
    /// Initialize configuration with a game URL
    /// - Parameters:
    ///   - urlString: The base URL for game resources
    ///   - parameters: Optional custom configuration parameters
    init?(urlString: String, parameters: [String: Any]? = nil) {
        guard let url = URL(string: urlString) else { return nil }
        self.gameResourceURL = url
        self.customParameters = parameters
    }
    
    /// Default configuration
    static let `default` = AppConfiguration(
        urlString: "https://chickenpotato.top/play/",
        parameters: [
            "version": "1.0.0",
            "environment": "production"
        ]
    )!
}

/// Extension to provide additional configuration methods
extension AppConfiguration {
    /// Validate the configuration
    func validate() -> Bool {
        // Add any specific validation logic
        return gameResourceURL.absoluteString.contains("chickenpotato.top")
    }
    
    /// Get a specific custom parameter
    /// - Parameter key: The key of the parameter
    /// - Returns: The value of the parameter, if it exists
    func getParameter<T>(for key: String) -> T? {
        return customParameters?[key] as? T
    }
} 
