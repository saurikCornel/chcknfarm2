import SwiftUI
import Foundation

struct EntryScreen: View {
    @StateObject private var loader: WebLoader

    init(loader: WebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            Color(hex: "#293453")
                .ignoresSafeArea()
            WebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
                .cornerRadius(20)
            
            switch loader.state {
            case .progressing(let percent):
                ProgressIndicator(value: percent)
            case .failure(let error):
                ErrorIndicator(message: error)
            case .noConnection:
                OfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct ProgressIndicator: View {
    let value: Double
    
    var body: some View {
        GeometryReader { geo in
            ChickenFarmLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct ErrorIndicator: View {
    let message: String
    
    var body: some View {
        Text("Error: \(message)")
            .foregroundColor(.red)
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(10)
    }
}

private struct OfflineIndicator: View {
    var body: some View {
        Text("No Connection")
            .foregroundColor(.gray)
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(10)
    }
}

#Preview {
    EntryScreen(loader: WebLoader(resourceURL: URL(string: "https://chickenpotato.top/play/")!))
} 
