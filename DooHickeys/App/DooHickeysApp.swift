import SwiftUI
import SpriteKit

// MARK: - App Entry Point
@main
struct DooHickeysApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .ignoresSafeArea()
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @State private var showingGame = false
    @State private var selectedMode: GameMode = .sandbox
    
    var body: some View {
        if showingGame {
            GameContainerView(mode: selectedMode, onExit: {
                showingGame = false
            })
            .ignoresSafeArea()
        } else {
            MainMenuView(onPlay: { mode in
                selectedMode = mode
                showingGame = true
            })
        }
    }
}

// MARK: - Game Modes
enum GameMode {
    case sandbox
    case campaign
    case challenge
}

// MARK: - Main Menu
struct MainMenuView: View {
    let onPlay: (GameMode) -> Void

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            ZStack {
                // Background
                Color(red: 0.12, green: 0.10, blue: 0.15)
                    .ignoresSafeArea()

                if isLandscape {
                    // LANDSCAPE: Side by side layout
                    HStack(spacing: 30) {
                        // Left: Title and mascot
                        VStack(spacing: 8) {
                            Text("⚙️ DOOHICKEYS ⚙️")
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.85, green: 0.75, blue: 0.50),
                                            Color(red: 0.71, green: 0.60, blue: 0.35)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .minimumScaleFactor(0.6)

                            Text("Build Crazy Contraptions!")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(red: 0.72, green: 0.45, blue: 0.32))

                            KameraManView()
                                .scaleEffect(0.65)
                                .frame(height: 100)

                            Text("A Steampunk Puzzle Builder")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)

                        // Right: Menu buttons
                        VStack(spacing: 10) {
                            MenuButton(title: "🔧 SANDBOX", subtitle: "Build freely!") {
                                onPlay(.sandbox)
                            }

                            MenuButton(title: "🎯 CAMPAIGN", subtitle: "50+ Puzzles") {
                                onPlay(.campaign)
                            }

                            MenuButton(title: "⏱️ CHALLENGE", subtitle: "Daily puzzles") {
                                onPlay(.challenge)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, max(geometry.safeAreaInsets.leading, 20) + 10)
                    .padding(.vertical, 15)

                } else {
                    // PORTRAIT: Stacked layout
                    VStack(spacing: 20) {
                        Text("⚙️ DOOHICKEYS ⚙️")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.85, green: 0.75, blue: 0.50),
                                        Color(red: 0.71, green: 0.60, blue: 0.35)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        Text("Build Crazy Contraptions!")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.72, green: 0.45, blue: 0.32))

                        KameraManView()
                            .frame(height: 120)

                        VStack(spacing: 12) {
                            MenuButton(title: "🔧 SANDBOX", subtitle: "Build freely!") {
                                onPlay(.sandbox)
                            }

                            MenuButton(title: "🎯 CAMPAIGN", subtitle: "50+ Puzzles") {
                                onPlay(.campaign)
                            }

                            MenuButton(title: "⏱️ CHALLENGE", subtitle: "Daily puzzles") {
                                onPlay(.challenge)
                            }
                        }
                        .padding(.horizontal, 30)

                        Text("A Steampunk Puzzle Builder")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, geometry.safeAreaInsets.top + 20)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Menu Button
struct MenuButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.72, green: 0.45, blue: 0.32))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(Color(red: 0.85, green: 0.75, blue: 0.50))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.35, green: 0.35, blue: 0.38))
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.71, green: 0.60, blue: 0.35),
                                Color(red: 0.55, green: 0.45, blue: 0.25)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Gear Shape
struct GearShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let teeth = 12
        let innerRadius = min(rect.width, rect.height) * 0.35
        let outerRadius = min(rect.width, rect.height) * 0.5
        
        for i in 0..<teeth {
            let angle = CGFloat(i) * .pi * 2 / CGFloat(teeth)
            let toothAngle = .pi * 2 / CGFloat(teeth * 2)
            
            let innerPoint1 = CGPoint(
                x: center.x + cos(angle) * innerRadius,
                y: center.y + sin(angle) * innerRadius
            )
            let outerPoint1 = CGPoint(
                x: center.x + cos(angle + toothAngle * 0.3) * outerRadius,
                y: center.y + sin(angle + toothAngle * 0.3) * outerRadius
            )
            let outerPoint2 = CGPoint(
                x: center.x + cos(angle + toothAngle * 0.7) * outerRadius,
                y: center.y + sin(angle + toothAngle * 0.7) * outerRadius
            )
            let innerPoint2 = CGPoint(
                x: center.x + cos(angle + toothAngle * 2) * innerRadius,
                y: center.y + sin(angle + toothAngle * 2) * innerRadius
            )
            
            if i == 0 {
                path.move(to: innerPoint1)
            }
            path.addLine(to: outerPoint1)
            path.addLine(to: outerPoint2)
            path.addLine(to: innerPoint2)
        }
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Kamera-Man Mascot View (Based on the iconic logo!)
struct KameraManView: View {
    @State private var bobbing = false
    @State private var lensGlow = false
    @State private var flashPulse = false
    
    var body: some View {
        ZStack {
            // === SPIKY HAIR ===
            ForEach(0..<6, id: \.self) { i in
                SpikyHair(index: i)
            }
            .offset(y: -50)
            
            // === HEAD (behind camera) ===
            Circle()
                .fill(Color(red: 0.85, green: 0.75, blue: 0.50))
                .frame(width: 36, height: 36)
                .offset(x: 0, y: -25)
            
            // Ear
            Ellipse()
                .fill(Color(red: 0.85, green: 0.75, blue: 0.50))
                .frame(width: 10, height: 14)
                .offset(x: -24, y: -25)
            
            // === CAMERA BODY ===
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.22, green: 0.22, blue: 0.25))
                .frame(width: 50, height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(red: 0.35, green: 0.35, blue: 0.38), lineWidth: 2)
                )
                .offset(y: -20)
            
            // Camera top hump
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.35, green: 0.35, blue: 0.38))
                .frame(width: 26, height: 12)
                .offset(x: -4, y: -42)
            
            // Hot shoe / flash mount
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(red: 0.71, green: 0.60, blue: 0.35))
                .frame(width: 14, height: 5)
                .offset(x: -4, y: -52)
            
            // Flash glow
            Circle()
                .fill(Color(red: 1.0, green: 0.55, blue: 0.15).opacity(flashPulse ? 0.8 : 0.2))
                .frame(width: 12, height: 12)
                .offset(x: -4, y: -52)
            
            // Shutter button (RED!)
            Circle()
                .fill(Color(red: 0.85, green: 0.25, blue: 0.20))
                .frame(width: 10, height: 10)
                .overlay(
                    Circle()
                        .stroke(Color(red: 0.65, green: 0.15, blue: 0.10), lineWidth: 1)
                )
                .offset(x: 18, y: -42)
            
            // === THE LENS (Camera's Eye!) ===
            // Outer copper ring
            Circle()
                .fill(Color(red: 0.72, green: 0.45, blue: 0.32))
                .frame(width: 36, height: 36)
                .offset(y: -18)
            
            // Middle ring
            Circle()
                .fill(Color(red: 0.55, green: 0.35, blue: 0.22))
                .frame(width: 28, height: 28)
                .offset(y: -18)
            
            // Inner dark ring
            Circle()
                .fill(Color(red: 0.22, green: 0.22, blue: 0.25))
                .frame(width: 20, height: 20)
                .offset(y: -18)
            
            // THE EYE - Glowing blue lens! (Studio 360° blue)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.3, green: 0.7, blue: 1.0),
                            Color(red: 0.15, green: 0.5, blue: 0.85)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 8
                    )
                )
                .frame(width: 16, height: 16)
                .shadow(color: Color(red: 0.3, green: 0.7, blue: 1.0).opacity(lensGlow ? 0.9 : 0.5), radius: lensGlow ? 8 : 4)
                .offset(y: -18)
            
            // Lens highlight
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: 5, height: 5)
                .offset(x: -4, y: -22)
            
            // === HANDS ===
            // Right hand
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.85, green: 0.75, blue: 0.50))
                .frame(width: 14, height: 24)
                .offset(x: 28, y: -14)
            
            // Right fingers
            ForEach(0..<3, id: \.self) { i in
                Ellipse()
                    .fill(Color(red: 0.85, green: 0.75, blue: 0.50))
                    .frame(width: 6, height: 10)
                    .offset(x: 30, y: CGFloat(-24 + i * 8))
            }
            
            // Left hand
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.85, green: 0.75, blue: 0.50))
                .frame(width: 12, height: 22)
                .offset(x: -28, y: -10)
            
            // === BODY / TORSO ===
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(red: 0.72, green: 0.45, blue: 0.32))
                .frame(width: 44, height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(red: 0.85, green: 0.55, blue: 0.40), lineWidth: 2)
                )
                .offset(y: 12)
            
            // Buttons
            VStack(spacing: 8) {
                Circle()
                    .fill(Color(red: 0.71, green: 0.60, blue: 0.35))
                    .frame(width: 6, height: 6)
                Circle()
                    .fill(Color(red: 0.71, green: 0.60, blue: 0.35))
                    .frame(width: 6, height: 6)
            }
            .offset(y: 12)
            
            // Camera strap
            Path { path in
                path.move(to: CGPoint(x: -26, y: -20))
                path.addQuadCurve(
                    to: CGPoint(x: -20, y: 28),
                    control: CGPoint(x: -40, y: 5)
                )
            }
            .stroke(Color(red: 0.40, green: 0.25, blue: 0.12), lineWidth: 5)
            
            // "360°" Badge
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(red: 0.71, green: 0.60, blue: 0.35))
                    .frame(width: 28, height: 12)
                Text("360°")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.25))
            }
            .offset(y: 5)
            
            // === WHEEL ===
            Circle()
                .fill(Color(red: 0.22, green: 0.22, blue: 0.25))
                .frame(width: 22, height: 22)
                .overlay(
                    Circle()
                        .stroke(Color(red: 0.35, green: 0.35, blue: 0.38), lineWidth: 2)
                )
                .offset(y: 38)
            
            // Wheel hub
            Circle()
                .fill(Color(red: 0.71, green: 0.60, blue: 0.35))
                .frame(width: 10, height: 10)
                .offset(y: 38)
        }
        .offset(y: bobbing ? -5 : 5)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                bobbing = true
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                lensGlow = true
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                flashPulse = true
            }
        }
    }
}

// Spiky hair component
struct SpikyHair: View {
    let index: Int
    
    private let configs: [(x: CGFloat, height: CGFloat, angle: Double)] = [
        (-10, 28, -15),   // Left spike
        (-3, 35, -5),     // Left-center (tallest!)
        (5, 30, 8),       // Right-center
        (14, 22, 20),     // Right spike
        (20, 16, 30),     // Far right small
        (-16, 20, -25),   // Far left small
    ]
    
    var body: some View {
        if index < configs.count {
            let config = configs[index]
            Triangle()
                .fill(Color(red: 0.35, green: 0.35, blue: 0.38))
                .frame(width: 12, height: config.height)
                .rotationEffect(.degrees(config.angle))
                .offset(x: config.x, y: -config.height / 2)
        }
    }
}

// Triangle shape for hair spikes
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Game Container View
struct GameContainerView: View {
    let mode: GameMode
    let onExit: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                SpriteView(scene: createScene(safeArea: geometry.safeAreaInsets))
                    .ignoresSafeArea()

                // Exit button overlay - positioned in safe area
                VStack {
                    HStack {
                        Button(action: onExit) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(Color(red: 0.71, green: 0.60, blue: 0.35))
                        }
                        .padding(.leading, max(geometry.safeAreaInsets.leading, 10) + 10)
                        .padding(.top, max(geometry.safeAreaInsets.top, 10) + 5)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
    }

    func createScene(safeArea: EdgeInsets) -> GameScene {
        let scene = GameScene()
        scene.size = UIScreen.main.bounds.size
        scene.scaleMode = .aspectFill
        scene.safeAreaInsets = UIEdgeInsets(
            top: safeArea.top,
            left: safeArea.leading,
            bottom: safeArea.bottom,
            right: safeArea.trailing
        )
        return scene
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
