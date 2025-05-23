import Foundation
import SwiftUI

struct FarmInitialView: View {
    private var gameResourceURL: URL { URL(string: "https://chickenpotato.top/play/")! }
    
    var body: some View {
        ZStack {
            Color(hexValue: "#373c56")
                .ignoresSafeArea()
            EntryScreen(loader: .init(resourceURL: gameResourceURL))
        }
    }
}

#Preview {
    FarmInitialView()
} 
