import WebKit
import Foundation

/// Coordinates web view navigation and status updates
class WebViewCoordinator: NSObject, WKNavigationDelegate {
    private let statusCallback: (WebLoadStatus) -> Void
    private var didStart = false

    init(onStatus: @escaping (WebLoadStatus) -> Void) {
        self.statusCallback = onStatus
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if !didStart { statusCallback(.progressing(progress: 0.0)) }
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        didStart = false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        statusCallback(.finished)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        statusCallback(.failure(reason: error.localizedDescription))
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        statusCallback(.failure(reason: error.localizedDescription))
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .other && webView.url != nil {
            didStart = true
        }
        decisionHandler(.allow)
    }
} 