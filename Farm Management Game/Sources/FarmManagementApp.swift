import SwiftUI

@main
struct FarmManagementApp: App {
    /// Application configuration
    private let configuration: AppConfiguration
    
    /// Initialize the app with default configuration
    init() {
        self.configuration = .default
    }
    
    /// App's main scene
    var body: some Scene {
        WindowGroup {
            EntryScreen(loader: WebLoader(resourceURL: configuration.gameResourceURL))
        }
    }
}