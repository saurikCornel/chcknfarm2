import WebKit
import SwiftUI
import Foundation

/// A container for rendering web content with a gradient background
struct WebViewBox: UIViewRepresentable {
    // MARK: - Properties
    
    @ObservedObject var loader: WebLoader
    
    // MARK: - Coordinator
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator { [weak loader] status in
            DispatchQueue.main.async {
                loader?.state = status
            }
        }
    }
    
    // MARK: - View Creation
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = createWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        setupWebViewAppearance(webView)
        setupContainerView(with: webView)
        clearWebsiteData()
        
        webView.navigationDelegate = context.coordinator
        loader.attachWebView { webView }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    // MARK: - Private Setup Methods
    
    private func createWebViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        return configuration
    }
    
    private func setupWebViewAppearance(_ webView: WKWebView) {
        webView.backgroundColor = .clear
        webView.isOpaque = false
    }
    
    private func setupContainerView(with webView: WKWebView) {
        let containerView = GradientContainerView()
        containerView.addSubview(webView)
        
        webView.frame = containerView.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func clearWebsiteData() {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: .distantPast) { }
    }
}

/// A custom container view with a gradient background
final class GradientContainerView: UIView {
    // MARK: - Private Properties
    
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        layer.insertSublayer(createGradientLayer(), at: 0)
    }
    
    /// Create a gradient layer
    private func createGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(hex: "#293453").cgColor,
            UIColor(hex: "#293453").cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

/// Extension to create UIColor from hex string
extension UIColor {
    /// Initialize color from hex string with improved parsing
    convenience init(hex hexString: String) {
        let sanitizedHex = hexString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .uppercased()
        
        var colorValue: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&colorValue)
        
        let redComponent = CGFloat((colorValue & 0xFF0000) >> 16) / 255.0
        let greenComponent = CGFloat((colorValue & 0x00FF00) >> 8) / 255.0
        let blueComponent = CGFloat(colorValue & 0x0000FF) / 255.0
        
        self.init(red: redComponent, green: greenComponent, blue: blueComponent, alpha: 1.0)
    }
} 
