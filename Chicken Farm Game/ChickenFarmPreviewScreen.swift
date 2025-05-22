import SwiftUI
import Foundation

struct ChickenFarmEntryScreen: View {
    @StateObject private var loader: ChickenFarmWebLoader

    init(loader: ChickenFarmWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            ChickenFarmWebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
            switch loader.state {
            case .progressing(let percent):
                ChickenFarmProgressIndicator(value: percent)
            case .failure(let err):
                ChickenFarmErrorIndicator(err: err) // err теперь String
            case .noConnection:
                ChickenFarmOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct ChickenFarmProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            ChickenFarmLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct ChickenFarmErrorIndicator: View {
    let err: String // было Error, стало String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct ChickenFarmOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}
