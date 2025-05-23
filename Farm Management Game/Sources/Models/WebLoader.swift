import Foundation
import WebKit
import Combine

/// Manages web view loading and state
final class WebLoader: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    @Published var state: WebLoadStatus = .standby
    
    // MARK: - Private Properties
    
    private let resource: URL
    private var cancellables = Set<AnyCancellable>()
    private var progressPublisher = PassthroughSubject<Double, Never>()
    private var webViewProvider: (() -> WKWebView)?
    
    // MARK: - Initialization
    
    init(resourceURL: URL) {
        self.resource = resourceURL
        super.init()
        observeProgression()
    }
    
    // MARK: - Public Methods
    
    /// Attach a web view to the loader
    func attachWebView(factory: @escaping () -> WKWebView) {
        webViewProvider = factory
        triggerLoad()
    }
    
    /// Set network connectivity status
    func setConnectivity(_ available: Bool) {
        switch (available, state) {
        case (true, .noConnection):
            triggerLoad()
        case (false, _):
            state = .noConnection
        default:
            break
        }
    }
    
    // MARK: - Private Loading Methods
    
    /// Trigger web view loading
    private func triggerLoad() {
        guard let webView = webViewProvider?() else { return }
        
        let request = URLRequest(url: resource, timeoutInterval: 12)
        state = .progressing(progress: 0)
        
        webView.navigationDelegate = self
        webView.load(request)
        monitor(webView)
    }
    
    // MARK: - Monitoring Methods
    
    /// Observe loading progression
    func observeProgression() {
        progressPublisher
            .removeDuplicates()
            .sink { [weak self] progress in
                guard let self else { return }
                self.state = progress < 1.0 ? .progressing(progress: progress) : .finished
            }
            .store(in: &cancellables)
    }
    
    /// Monitor web view progress
    func monitor(_ webView: WKWebView) {
        webView.publisher(for: \.estimatedProgress)
            .sink { [weak self] progress in
                self?.progressPublisher.send(progress)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Web Navigation Delegate Extension

extension WebLoader: WKNavigationDelegate {
    /// Handle navigation failures
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleNavigationError(error)
    }
    
    /// Handle provisional navigation failures
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleNavigationError(error)
    }
    
    // MARK: - Private Error Handling
    
    /// Generalized navigation error handler
    private func handleNavigationError(_ error: Error) {
        state = .failure(reason: error.localizedDescription)
    }
}

// MARK: - Convenience Initializer Extension

extension WebLoader {
    /// Create a loader with a safe URL
    convenience init?(urlString: String) {
        guard let url = URL(string: urlString) else { return nil }
        self.init(resourceURL: url)
    }
}

// MARK: - Web Load Status Enum

enum WebLoadStatus: Equatable {
    case standby
    case progressing(progress: Double)
    case finished
    case failure(reason: String)
    case noConnection
    
    /// Check if statuses are equivalent
    func isEquivalent(to other: WebLoadStatus) -> Bool {
        switch (self, other) {
        case (.standby, .standby), 
             (.finished, .finished), 
             (.noConnection, .noConnection):
            return true
        case let (.progressing(a), .progressing(b)):
            return abs(a - b) < 0.0001
        case let (.failure(reasonA), .failure(reasonB)):
            return reasonA == reasonB
        default:
            return false
        }
    }
    
    /// Current connection progress
    var progress: Double? {
        guard case let .progressing(value) = self else { return nil }
        return value
    }
    
    /// Indicates successful completion
    var isSuccessful: Bool {
        switch self {
        case .finished: return true
        default: return false
        }
    }
    
    /// Indicates error state
    var hasError: Bool {
        switch self {
        case .failure, .noConnection: return true
        default: return false
        }
    }
} 