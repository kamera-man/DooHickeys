import SpriteKit

// MARK: - Particle Effect Manager
class ParticleEffects {
    static let shared = ParticleEffects()
    
    // MARK: - Steam Effects
    
    /// Creates billowing steam puffs
    func createSteamEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Particle settings
        emitter.particleBirthRate = 40
        emitter.particleLifetime = 2.0
        emitter.particleLifetimeRange = 0.5
        
        // Size
        emitter.particleSize = CGSize(width: 20, height: 20)
        emitter.particleScaleRange = 0.5
        emitter.particleScaleSpeed = 0.8
        
        // Color
        emitter.particleColor = SteampunkColors.steam
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlphaSpeed = -0.4
        emitter.particleAlphaRange = 0.3
        
        // Movement
        emitter.particleSpeed = 50
        emitter.particleSpeedRange = 20
        emitter.emissionAngle = .pi / 2  // Upward
        emitter.emissionAngleRange = .pi / 4
        
        // Physics
        emitter.yAcceleration = 30  // Rise up
        emitter.xAcceleration = 0
        
        // Blend mode for soft look
        emitter.particleBlendMode = .add
        
        // Create circular texture
        emitter.particleTexture = createCircleTexture(radius: 10, color: .white)
        
        return emitter
    }
    
    /// Creates a burst of steam when pressure releases
    func createSteamBurst(at position: CGPoint, direction: CGVector, in scene: SKScene) {
        let burstCount = 15
        
        for _ in 0..<burstCount {
            let puff = SKShapeNode(circleOfRadius: CGFloat.random(in: 8...20))
            puff.fillColor = SteampunkColors.steam
            puff.strokeColor = .clear
            puff.alpha = 0.7
            puff.position = position
            puff.zPosition = 100
            scene.addChild(puff)
            
            // Randomize direction slightly
            let angle = atan2(direction.dy, direction.dx) + CGFloat.random(in: -0.5...0.5)
            let speed = CGFloat.random(in: 80...150)
            let destination = CGPoint(
                x: position.x + cos(angle) * speed,
                y: position.y + sin(angle) * speed + 50  // Rise
            )
            
            let move = SKAction.move(to: destination, duration: 0.8)
            move.timingMode = .easeOut
            let scale = SKAction.scale(to: 2.5, duration: 0.8)
            let fade = SKAction.fadeOut(withDuration: 0.8)
            
            puff.run(SKAction.sequence([
                SKAction.group([move, scale, fade]),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    /// Continuous steam leak from pipes
    func createSteamLeak() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        emitter.particleBirthRate = 20
        emitter.particleLifetime = 1.5
        emitter.particleLifetimeRange = 0.3
        
        emitter.particleSize = CGSize(width: 8, height: 8)
        emitter.particleScaleRange = 0.3
        emitter.particleScaleSpeed = 0.5
        
        emitter.particleColor = SteampunkColors.steam
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlphaSpeed = -0.5
        
        emitter.particleSpeed = 80
        emitter.particleSpeedRange = 20
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = 0.2
        
        emitter.yAcceleration = 20
        emitter.particleBlendMode = .add
        emitter.particleTexture = createCircleTexture(radius: 6, color: .white)
        
        return emitter
    }
    
    // MARK: - Electrical Effects
    
    /// Creates sparks for electrical discharge
    func createSparkEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        emitter.particleBirthRate = 100
        emitter.particleLifetime = 0.3
        emitter.particleLifetimeRange = 0.2
        
        emitter.particleSize = CGSize(width: 4, height: 4)
        emitter.particleScaleRange = 0.5
        
        emitter.particleColor = SteampunkColors.electricityBright
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColorSequence = SKKeyframeSequence(
            keyframeValues: [
                SteampunkColors.electricityBright,
                SteampunkColors.electricity,
                SKColor.white
            ],
            times: [0, 0.5, 1.0]
        )
        
        emitter.particleSpeed = 150
        emitter.particleSpeedRange = 100
        emitter.emissionAngleRange = .pi * 2  // All directions
        
        emitter.yAcceleration = -200  // Fall
        emitter.particleBlendMode = .add
        emitter.particleTexture = createSparkTexture()
        
        return emitter
    }
    
    /// Creates an electrical arc between two points
    func createElectricalArc(from start: CGPoint, to end: CGPoint, in scene: SKScene) {
        // Create multiple arc segments for a lightning effect
        for _ in 0..<3 {
            let arc = createLightningPath(from: start, to: end)
            arc.strokeColor = SteampunkColors.electricityBright
            arc.lineWidth = CGFloat.random(in: 2...4)
            arc.glowWidth = CGFloat.random(in: 5...10)
            arc.alpha = CGFloat.random(in: 0.7...1.0)
            arc.zPosition = 150
            scene.addChild(arc)
            
            // Quick flash and fade
            let flash = SKAction.sequence([
                SKAction.fadeAlpha(to: 1.0, duration: 0.05),
                SKAction.fadeAlpha(to: 0.3, duration: 0.05)
            ])
            let fade = SKAction.fadeOut(withDuration: 0.15)
            
            arc.run(SKAction.sequence([
                SKAction.repeat(flash, count: 3),
                fade,
                SKAction.removeFromParent()
            ]))
        }
        
        // Add spark burst at endpoints
        createSparkBurst(at: start, in: scene)
        createSparkBurst(at: end, in: scene)
    }
    
    private func createLightningPath(from start: CGPoint, to end: CGPoint) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: start)
        
        let distance = hypot(end.x - start.x, end.y - start.y)
        let segments = max(5, Int(distance / 30))
        
        for i in 1..<segments {
            let t = CGFloat(i) / CGFloat(segments)
            let baseX = start.x + (end.x - start.x) * t
            let baseY = start.y + (end.y - start.y) * t
            
            // Perpendicular offset for jagged look
            let perpX = -(end.y - start.y) / distance
            let perpY = (end.x - start.x) / distance
            let offset = CGFloat.random(in: -20...20)
            
            path.addLine(to: CGPoint(
                x: baseX + perpX * offset,
                y: baseY + perpY * offset
            ))
        }
        path.addLine(to: end)
        
        return SKShapeNode(path: path)
    }
    
    /// Creates a burst of sparks
    func createSparkBurst(at position: CGPoint, in scene: SKScene) {
        let sparkCount = 20
        
        for _ in 0..<sparkCount {
            let spark = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            spark.fillColor = [SteampunkColors.electricityBright, SteampunkColors.electricity, .white].randomElement()!
            spark.strokeColor = .clear
            spark.glowWidth = 3
            spark.position = position
            spark.zPosition = 150
            scene.addChild(spark)
            
            let angle = CGFloat.random(in: 0...(CGFloat.pi * 2))
            let distance = CGFloat.random(in: 30...80)
            let destination = CGPoint(
                x: position.x + cos(angle) * distance,
                y: position.y + sin(angle) * distance
            )
            
            let move = SKAction.move(to: destination, duration: CGFloat.random(in: 0.2...0.4))
            move.timingMode = .easeOut
            let fade = SKAction.fadeOut(withDuration: 0.3)
            let scale = SKAction.scale(to: 0.1, duration: 0.3)
            
            spark.run(SKAction.sequence([
                SKAction.group([move, fade, scale]),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    /// Tesla coil ambient electricity
    func createTeslaAmbient() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        emitter.particleBirthRate = 30
        emitter.particleLifetime = 0.5
        emitter.particleLifetimeRange = 0.2
        
        emitter.particleSize = CGSize(width: 3, height: 3)
        emitter.particleScaleRange = 0.5
        
        emitter.particleColor = SteampunkColors.electricityBright
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlphaSpeed = -1.5
        
        emitter.particleSpeed = 60
        emitter.particleSpeedRange = 40
        emitter.emissionAngleRange = .pi * 2
        
        emitter.particleBlendMode = .add
        emitter.particleTexture = createCircleTexture(radius: 3, color: .white)
        
        return emitter
    }
    
    // MARK: - Fire Effects
    
    /// Creates a fire emitter for furnaces
    func createFireEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        emitter.particleBirthRate = 60
        emitter.particleLifetime = 0.8
        emitter.particleLifetimeRange = 0.3
        
        emitter.particleSize = CGSize(width: 15, height: 20)
        emitter.particleScaleRange = 0.4
        emitter.particleScaleSpeed = -0.3
        
        emitter.particleColorSequence = SKKeyframeSequence(
            keyframeValues: [
                SKColor.white,
                SteampunkColors.fire,
                SKColor(red: 0.8, green: 0.2, blue: 0.0, alpha: 1.0),
                SKColor(red: 0.3, green: 0.1, blue: 0.0, alpha: 0.5)
            ],
            times: [0, 0.2, 0.6, 1.0]
        )
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlphaSpeed = -0.8
        
        emitter.particleSpeed = 40
        emitter.particleSpeedRange = 20
        emitter.emissionAngle = .pi / 2
        emitter.emissionAngleRange = .pi / 6
        
        emitter.yAcceleration = 50
        emitter.particleBlendMode = .add
        emitter.particleTexture = createFireTexture()
        
        return emitter
    }
    
    /// Creates smoke from fire/explosions
    func createSmokeEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        emitter.particleBirthRate = 20
        emitter.particleLifetime = 3.0
        emitter.particleLifetimeRange = 1.0
        
        emitter.particleSize = CGSize(width: 25, height: 25)
        emitter.particleScaleRange = 0.5
        emitter.particleScaleSpeed = 0.5
        
        emitter.particleColor = SKColor(white: 0.3, alpha: 0.6)
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlphaSpeed = -0.2
        
        emitter.particleSpeed = 20
        emitter.particleSpeedRange = 10
        emitter.emissionAngle = .pi / 2
        emitter.emissionAngleRange = .pi / 4
        
        emitter.yAcceleration = 30
        emitter.xAcceleration = 5  // Slight drift
        emitter.particleBlendMode = .alpha
        emitter.particleTexture = createSmokeTexture()
        
        return emitter
    }
    
    // MARK: - Explosion Effects
    
    /// Creates a dramatic explosion
    func createExplosion(at position: CGPoint, size: ExplosionSize, in scene: SKScene) {
        // Central flash
        let flash = SKShapeNode(circleOfRadius: size.flashRadius)
        flash.fillColor = .white
        flash.strokeColor = .clear
        flash.glowWidth = size.flashRadius
        flash.position = position
        flash.zPosition = 200
        scene.addChild(flash)
        
        let expandFlash = SKAction.scale(to: 3, duration: 0.15)
        let fadeFlash = SKAction.fadeOut(withDuration: 0.15)
        flash.run(SKAction.sequence([
            SKAction.group([expandFlash, fadeFlash]),
            SKAction.removeFromParent()
        ]))
        
        // Fire ring
        let fireRing = SKShapeNode(circleOfRadius: size.fireRadius)
        fireRing.fillColor = SteampunkColors.fire
        fireRing.strokeColor = SteampunkColors.fireGlow
        fireRing.lineWidth = 8
        fireRing.glowWidth = 15
        fireRing.position = position
        fireRing.zPosition = 190
        scene.addChild(fireRing)
        
        let expandFire = SKAction.scale(to: 2.5, duration: 0.3)
        expandFire.timingMode = .easeOut
        let fadeFire = SKAction.fadeOut(withDuration: 0.3)
        fireRing.run(SKAction.sequence([
            SKAction.group([expandFire, fadeFire]),
            SKAction.removeFromParent()
        ]))
        
        // Debris particles
        for _ in 0..<size.debrisCount {
            let debris = createDebrisParticle()
            debris.position = position
            scene.addChild(debris)
            
            let angle = CGFloat.random(in: 0...(CGFloat.pi * 2))
            let distance = CGFloat.random(in: size.debrisMinDistance...size.debrisMaxDistance)
            let destination = CGPoint(
                x: position.x + cos(angle) * distance,
                y: position.y + sin(angle) * distance
            )
            
            let duration = CGFloat.random(in: 0.4...0.8)
            let move = SKAction.move(to: destination, duration: duration)
            move.timingMode = .easeOut
            
            let rotate = SKAction.rotate(byAngle: CGFloat.random(in: -10...10), duration: duration)
            let fade = SKAction.fadeOut(withDuration: duration)
            let gravity = SKAction.moveBy(x: 0, y: -50, duration: duration)
            
            debris.run(SKAction.sequence([
                SKAction.group([move, rotate, fade, gravity]),
                SKAction.removeFromParent()
            ]))
        }
        
        // Smoke aftermath
        let smoke = createSmokeEmitter()
        smoke.position = position
        smoke.zPosition = 100
        scene.addChild(smoke)
        
        smoke.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.run { smoke.particleBirthRate = 0 },
            SKAction.wait(forDuration: 3),
            SKAction.removeFromParent()
        ]))
        
        // Screen shake
        let shakeIntensity = size.shakeIntensity
        let shake = SKAction.sequence([
            SKAction.moveBy(x: shakeIntensity, y: shakeIntensity/2, duration: 0.05),
            SKAction.moveBy(x: -shakeIntensity*2, y: -shakeIntensity, duration: 0.05),
            SKAction.moveBy(x: shakeIntensity*1.5, y: shakeIntensity/2, duration: 0.05),
            SKAction.moveBy(x: -shakeIntensity/2, y: 0, duration: 0.05)
        ])
        scene.run(shake)
    }
    
    private func createDebrisParticle() -> SKNode {
        let shapes: [SKShapeNode] = [
            SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 5...15), height: CGFloat.random(in: 5...15))),
            SKShapeNode(circleOfRadius: CGFloat.random(in: 3...8)),
            {
                let path = CGMutablePath()
                path.move(to: CGPoint(x: 0, y: -5))
                path.addLine(to: CGPoint(x: 5, y: 5))
                path.addLine(to: CGPoint(x: -5, y: 5))
                path.closeSubpath()
                return SKShapeNode(path: path)
            }()
        ]
        
        let debris = shapes.randomElement()!
        debris.fillColor = [SteampunkColors.brass, SteampunkColors.iron, SteampunkColors.copper, SteampunkColors.fire].randomElement()!
        debris.strokeColor = debris.fillColor.darker(by: 0.2)
        debris.zPosition = 180
        return debris
    }
    
    enum ExplosionSize {
        case small
        case medium
        case large
        case massive
        
        var flashRadius: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 40
            case .large: return 60
            case .massive: return 100
            }
        }
        
        var fireRadius: CGFloat {
            switch self {
            case .small: return 30
            case .medium: return 50
            case .large: return 80
            case .massive: return 130
            }
        }
        
        var debrisCount: Int {
            switch self {
            case .small: return 10
            case .medium: return 20
            case .large: return 35
            case .massive: return 60
            }
        }
        
        var debrisMinDistance: CGFloat {
            switch self {
            case .small: return 30
            case .medium: return 50
            case .large: return 80
            case .massive: return 120
            }
        }
        
        var debrisMaxDistance: CGFloat {
            switch self {
            case .small: return 80
            case .medium: return 120
            case .large: return 180
            case .massive: return 280
            }
        }
        
        var shakeIntensity: CGFloat {
            switch self {
            case .small: return 5
            case .medium: return 10
            case .large: return 20
            case .massive: return 35
            }
        }
    }
    
    // MARK: - Gear Effects
    
    /// Creates gear rotation particles (oil drops, dust)
    func createGearDust() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        emitter.particleBirthRate = 5
        emitter.particleLifetime = 1.0
        emitter.particleLifetimeRange = 0.3
        
        emitter.particleSize = CGSize(width: 3, height: 3)
        emitter.particleScaleRange = 0.5
        
        emitter.particleColor = SteampunkColors.brassDark
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlphaSpeed = -0.8
        
        emitter.particleSpeed = 20
        emitter.particleSpeedRange = 10
        emitter.emissionAngleRange = .pi * 2
        
        emitter.yAcceleration = -50
        emitter.particleBlendMode = .alpha
        emitter.particleTexture = createCircleTexture(radius: 2, color: .white)
        
        return emitter
    }
    
    /// Creates metal grinding sparks
    func createGrindingSparks() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        emitter.particleBirthRate = 80
        emitter.particleLifetime = 0.4
        emitter.particleLifetimeRange = 0.2
        
        emitter.particleSize = CGSize(width: 2, height: 6)
        emitter.particleScaleRange = 0.5
        
        emitter.particleColorSequence = SKKeyframeSequence(
            keyframeValues: [
                SKColor.white,
                SteampunkColors.fire,
                SteampunkColors.brassDark
            ],
            times: [0, 0.3, 1.0]
        )
        emitter.particleColorBlendFactor = 1.0
        
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 50
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = .pi / 3
        
        emitter.yAcceleration = -200
        emitter.particleBlendMode = .add
        emitter.particleTexture = createSparkTexture()
        
        return emitter
    }
    
    // MARK: - Victory/UI Effects
    
    /// Creates celebratory confetti
    func createConfetti(in scene: SKScene) {
        let colors: [SKColor] = [
            SteampunkColors.brass,
            SteampunkColors.copper,
            SteampunkColors.electricity,
            SteampunkColors.success,
            .white
        ]
        
        for _ in 0..<100 {
            let confetti = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 5...12), height: CGFloat.random(in: 8...15)))
            confetti.fillColor = colors.randomElement()!
            confetti.strokeColor = .clear
            confetti.position = CGPoint(
                x: CGFloat.random(in: 0...scene.size.width),
                y: scene.size.height + 50
            )
            confetti.zPosition = 300
            scene.addChild(confetti)
            
            let fallDuration = CGFloat.random(in: 2...4)
            let fall = SKAction.moveTo(y: -50, duration: fallDuration)
            let sway = SKAction.repeatForever(SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: 20...40), y: 0, duration: 0.3),
                SKAction.moveBy(x: CGFloat.random(in: -40 ... -20), y: 0, duration: 0.3)
            ]))
            let spin = SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: CGFloat.random(in: 0.5...1.5)))
            
            confetti.run(SKAction.group([fall, sway, spin]))
            confetti.run(SKAction.sequence([
                SKAction.wait(forDuration: fallDuration),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    /// Creates a star burst for achievements
    func createStarBurst(at position: CGPoint, in scene: SKScene) {
        for i in 0..<8 {
            let star = SKLabelNode(text: "⭐")
            star.fontSize = 24
            star.position = position
            star.zPosition = 250
            scene.addChild(star)
            
            let angle = CGFloat(i) * .pi / 4
            let destination = CGPoint(
                x: position.x + cos(angle) * 100,
                y: position.y + sin(angle) * 100
            )
            
            let move = SKAction.move(to: destination, duration: 0.5)
            move.timingMode = .easeOut
            let scale = SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.25),
                SKAction.scale(to: 0, duration: 0.25)
            ])
            let fade = SKAction.fadeOut(withDuration: 0.5)
            
            star.run(SKAction.sequence([
                SKAction.group([move, scale, fade]),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    // MARK: - Texture Generation
    
    private func createCircleTexture(radius: CGFloat, color: SKColor) -> SKTexture {
        let size = CGSize(width: radius * 2, height: radius * 2)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        return SKTexture(image: image)
    }
    
    private func createSparkTexture() -> SKTexture {
        let size = CGSize(width: 4, height: 12)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [UIColor.white.cgColor, UIColor.clear.cgColor] as CFArray,
                locations: [0, 1]
            )!
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: size.width/2, y: 0),
                end: CGPoint(x: size.width/2, y: size.height),
                options: []
            )
        }
        return SKTexture(image: image)
    }
    
    private func createFireTexture() -> SKTexture {
        let size = CGSize(width: 20, height: 30)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let path = UIBezierPath()
            path.move(to: CGPoint(x: size.width/2, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: size.width, y: size.height),
                controlPoint: CGPoint(x: size.width * 0.8, y: size.height * 0.3)
            )
            path.addQuadCurve(
                to: CGPoint(x: 0, y: size.height),
                controlPoint: CGPoint(x: size.width/2, y: size.height * 0.7)
            )
            path.addQuadCurve(
                to: CGPoint(x: size.width/2, y: 0),
                controlPoint: CGPoint(x: size.width * 0.2, y: size.height * 0.3)
            )
            path.close()
            
            UIColor.white.setFill()
            path.fill()
        }
        return SKTexture(image: image)
    }
    
    private func createSmokeTexture() -> SKTexture {
        let size = CGSize(width: 40, height: 40)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor(white: 0.5, alpha: 0.8).cgColor,
                    UIColor(white: 0.5, alpha: 0).cgColor
                ] as CFArray,
                locations: [0, 1]
            )!
            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: size.width/2, y: size.height/2),
                startRadius: 0,
                endCenter: CGPoint(x: size.width/2, y: size.height/2),
                endRadius: size.width/2,
                options: []
            )
        }
        return SKTexture(image: image)
    }
}

// MARK: - Scene Extension for Effects
extension GameScene {
    func addSteamEffect(to node: SKNode) {
        let steam = ParticleEffects.shared.createSteamEmitter()
        steam.position = CGPoint(x: 0, y: 30)
        steam.name = "steamEffect"
        node.addChild(steam)
    }
    
    func addFireEffect(to node: SKNode) {
        let fire = ParticleEffects.shared.createFireEmitter()
        fire.position = CGPoint(x: 0, y: -10)
        fire.name = "fireEffect"
        node.addChild(fire)
    }
    
    func addElectricEffect(to node: SKNode) {
        let sparks = ParticleEffects.shared.createTeslaAmbient()
        sparks.position = .zero
        sparks.name = "electricEffect"
        node.addChild(sparks)
    }
    
    func triggerExplosion(at position: CGPoint, size: ParticleEffects.ExplosionSize = .medium) {
        ParticleEffects.shared.createExplosion(at: position, size: size, in: self)
    }
    
    func triggerVictory() {
        ParticleEffects.shared.createConfetti(in: self)
        ParticleEffects.shared.createStarBurst(at: CGPoint(x: size.width/2, y: size.height/2), in: self)
    }
}
