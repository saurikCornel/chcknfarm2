import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol ProgressDisplayable {
    var progressPercentage: Int { get }
}

protocol BackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Расширенная структура загрузки

struct ChickenFarmLoadingOverlay<Background: View>: View, ProgressDisplayable {
    let progress: Double
    let backgroundView: Background
    
    var progressPercentage: Int { Int(progress * 100) }
    
    init(progress: Double, @ViewBuilder background: () -> Background) {
        self.progress = progress
        self.backgroundView = background()
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundView
                content(in: geo)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
    
    private func content(in geometry: GeometryProxy) -> some View {
        let isLandscape = geometry.size.width > geometry.size.height
        
        return Group {
            if isLandscape {
                horizontalLayout(in: geometry)
            } else {
                verticalLayout(in: geometry)
            }
        }
    }
    
    private func verticalLayout(in geometry: GeometryProxy) -> some View {
        VStack {
            Spacer()
            Image("chck")
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width * 0.7)
            
            progressSection(width: geometry.size.width * 0.7)
            
            Image("title")
                .resizable()
                .scaledToFit()
                .padding()
                .frame(width: geometry.size.width * 0.8)
                .padding(.top, 40)
            
            Spacer()
        }
    }
    
    private func horizontalLayout(in geometry: GeometryProxy) -> some View {
        HStack {
            Spacer()
            
            VStack {
                Image("chck")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.3)
                
                progressSection(width: geometry.size.width * 0.3)
            }
            
            VStack {
                Image("title")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(width: geometry.size.width * 0.4)
            }
            
            Spacer()
        }
    }
    
    private func progressSection(width: CGFloat) -> some View {
        VStack(spacing: 14) {
            Text("Loading \(progressPercentage)%")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .shadow(radius: 1)
            
            ChickenFarmProgressBar(value: progress)
                .frame(width: width, height: 10)
        }
        .padding(14)
        .background(Color.black.opacity(0.22))
        .cornerRadius(14)
        .padding(.bottom, 20)
    }
}

// MARK: - Фоновые представления

extension ChickenFarmLoadingOverlay where Background == ChickenFarmBackground {
    init(progress: Double) {
        self.init(progress: progress) { ChickenFarmBackground() }
    }
}

struct ChickenFarmBackground: View, BackgroundProviding {
    func makeBackground() -> some View {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
    
    var body: some View {
        makeBackground()
    }
}

// MARK: - Индикатор прогресса с анимацией

struct ChickenFarmProgressBar: View {
    let value: Double
    
    var body: some View {
        GeometryReader { geometry in
            progressContainer(in: geometry)
        }
    }
    
    private func progressContainer(in geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            backgroundTrack(height: geometry.size.height)
            progressTrack(in: geometry)
        }
    }
    
    private func backgroundTrack(height: CGFloat) -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.15))
            .frame(height: height)
    }
    
    private func progressTrack(in geometry: GeometryProxy) -> some View {
        Rectangle()
            .fill(Color(hex: "#F3D614"))
            .frame(width: CGFloat(value) * geometry.size.width, height: geometry.size.height)
            .animation(.linear(duration: 0.2), value: value)
    }
}

// MARK: - Превью

#Preview("Vertical") {
    ChickenFarmLoadingOverlay(progress: 0.2)
}

#Preview("Horizontal") {
    ChickenFarmLoadingOverlay(progress: 0.2)
        .previewInterfaceOrientation(.landscapeRight)
}

