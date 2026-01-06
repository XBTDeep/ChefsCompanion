import SwiftUI
import WebKit

/// A WebView wrapper for embedding YouTube videos
struct YouTubePlayerView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

/// Container view with proper aspect ratio for YouTube player
struct YouTubePlayerContainerView: View {
    let url: URL
    
    var body: some View {
        YouTubePlayerView(url: url)
            .aspectRatio(16/9, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview
#Preview {
    if let url = URL(string: "https://www.youtube.com/embed/dQw4w9WgXcQ") {
        YouTubePlayerContainerView(url: url)
            .padding()
    }
}
