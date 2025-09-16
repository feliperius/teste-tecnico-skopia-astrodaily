import SwiftUI

struct SplashView: View {
    @State private var starsOpacity: Double = 0
    @State private var planetScale: CGFloat = 0.1
    @State private var planetRotation: Double = 0
    @State private var orbitRotation: Double = 0
    @State private var ringsScale: CGFloat = 0.5
    @State private var ringsOpacity: Double = 0
    @State private var textOffset: CGFloat = 50
    @State private var textOpacity: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var showSecondaryText = false
    @State private var showCreatorText = false
    @State private var gradientRotation: Double = 0
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            AngularGradient(
                colors: [.black, .indigo, .purple, .blue, .black],
                center: .center,
                angle: .degrees(gradientRotation)
            )
            .ignoresSafeArea()
            .animation(.linear(duration: 10).repeatForever(autoreverses: false), value: gradientRotation)
            
            StarField()
                .opacity(starsOpacity)
            
            VStack(spacing: 40) {
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.cyan.opacity(0.3), .blue.opacity(0.6), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(ringsScale)
                        .opacity(ringsOpacity)
                        .rotationEffect(.degrees(orbitRotation))
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.orange.opacity(0.4), .yellow.opacity(0.6), .orange.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(ringsScale * 0.8)
                        .opacity(ringsOpacity)
                        .rotationEffect(.degrees(-orbitRotation * 1.5))
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.cyan.opacity(0.8), .blue.opacity(0.4), .clear],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 40
                                )
                            )
                            .frame(width: 80, height: 80)
                            .scaleEffect(pulseScale)
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.cyan, .blue, .indigo],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [.white.opacity(0.2), .clear],
                                            center: .topLeading,
                                            startRadius: 5,
                                            endRadius: 25
                                        )
                                    )
                            )
                            .rotationEffect(.degrees(planetRotation))
                    }
                    .scaleEffect(planetScale)
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.white, .cyan],
                                    startPoint: .center,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 4, height: 4)
                            .offset(x: CGFloat(30 + index * 15))
                            .rotationEffect(.degrees(orbitRotation + Double(index * 120)))
                            .opacity(ringsOpacity)
                    }
                }
                VStack(spacing: 12) {
                    Text(Strings.splashAppName)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .cyan, .blue, .white],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(textOpacity)
                        .offset(y: textOffset)
                        .scaleEffect(pulseScale * 0.95)
                    
                    if showSecondaryText {
                        Text(Strings.splashSubtitle)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.gray, .white, .gray],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(textOpacity * 0.8)
                            .offset(y: textOffset * 0.5)
                    }
                    
                    if showCreatorText {
                        VStack(spacing: 4) {
                            Text("Criado por")
                                .font(.system(size: 12, weight: .light, design: .rounded))
                                .foregroundColor(.gray.opacity(0.8))
                            
                            Text("Felipe Perius")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.cyan.opacity(0.8), .blue.opacity(0.9), .cyan.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        .opacity(textOpacity * 0.9)
                        .offset(y: textOffset * 0.3)
                    }
                }
            }
        }
        .onAppear {
            startAdvancedAnimation()
        }
    }
    
    private func startAdvancedAnimation() {
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            gradientRotation = 360
        }
        
        withAnimation(.easeIn(duration: 1.0)) {
            starsOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
            planetScale = 1.0
        }

        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false).delay(0.5)) {
            planetRotation = 360
        }
    
        withAnimation(.easeOut(duration: 1.0).delay(0.8)) {
            ringsScale = 1.0
            ringsOpacity = 1.0
        }
        
        withAnimation(.linear(duration: 12).repeatForever(autoreverses: false).delay(1.0)) {
            orbitRotation = 360
        }

        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(1.2)) {
            pulseScale = 1.1
        }

        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(1.5)) {
            textOffset = 0
            textOpacity = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeIn(duration: 0.8)) {
                showSecondaryText = true
            }
        }
        
        // Show creator text
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeIn(duration: 0.6)) {
                showCreatorText = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            withAnimation(.easeInOut(duration: 1.0)) {
                starsOpacity = 0
                planetScale = 0.1
                ringsOpacity = 0
                textOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onComplete()
            }
        }
    }
}

struct StarField: View {
    @State private var animateStars = false
    
    var body: some View {
        ZStack {
            ForEach(0..<80, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...1.0)))
                    .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .scaleEffect(animateStars ? CGFloat.random(in: 0.5...1.5) : 1.0)
                    .animation(
                        .easeInOut(duration: Double.random(in: 2...4))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...2)),
                        value: animateStars
                    )
            }
        }
        .onAppear {
            animateStars = true
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView {
            print("Splash completed")
        }
    }
}