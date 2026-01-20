import SpriteKit

// MARK: - Steampunk Color Palette
enum SteampunkColors {
    static let brass = SKColor(red: 0.71, green: 0.60, blue: 0.35, alpha: 1.0)
    static let brassLight = SKColor(red: 0.85, green: 0.75, blue: 0.50, alpha: 1.0)
    static let brassDark = SKColor(red: 0.55, green: 0.45, blue: 0.25, alpha: 1.0)
    
    static let copper = SKColor(red: 0.72, green: 0.45, blue: 0.32, alpha: 1.0)
    static let copperLight = SKColor(red: 0.85, green: 0.55, blue: 0.40, alpha: 1.0)
    static let copperDark = SKColor(red: 0.55, green: 0.35, blue: 0.22, alpha: 1.0)
    
    static let iron = SKColor(red: 0.35, green: 0.35, blue: 0.38, alpha: 1.0)
    static let ironLight = SKColor(red: 0.50, green: 0.50, blue: 0.55, alpha: 1.0)
    static let ironDark = SKColor(red: 0.22, green: 0.22, blue: 0.25, alpha: 1.0)
    
    static let wood = SKColor(red: 0.55, green: 0.35, blue: 0.20, alpha: 1.0)
    static let woodLight = SKColor(red: 0.70, green: 0.50, blue: 0.30, alpha: 1.0)
    static let woodDark = SKColor(red: 0.40, green: 0.25, blue: 0.12, alpha: 1.0)
    
    static let steam = SKColor(red: 0.90, green: 0.92, blue: 0.95, alpha: 0.6)
    static let fire = SKColor(red: 1.0, green: 0.55, blue: 0.15, alpha: 1.0)
    static let fireGlow = SKColor(red: 1.0, green: 0.35, blue: 0.10, alpha: 0.8)
    static let electricity = SKColor(red: 0.40, green: 0.70, blue: 1.0, alpha: 1.0)
    static let electricityBright = SKColor(red: 0.80, green: 0.95, blue: 1.0, alpha: 1.0)
    
    static let background = SKColor(red: 0.12, green: 0.10, blue: 0.15, alpha: 1.0)
    static let backgroundLight = SKColor(red: 0.18, green: 0.15, blue: 0.22, alpha: 1.0)
    static let grid = SKColor(red: 0.25, green: 0.22, blue: 0.30, alpha: 0.5)
    
    static let danger = SKColor(red: 0.85, green: 0.25, blue: 0.20, alpha: 1.0)
    static let success = SKColor(red: 0.30, green: 0.75, blue: 0.40, alpha: 1.0)
}

// MARK: - Color Extensions
extension SKColor {
    func lighter(by percentage: CGFloat) -> SKColor {
        return adjust(by: abs(percentage))
    }
    
    func darker(by percentage: CGFloat) -> SKColor {
        return adjust(by: -abs(percentage))
    }
    
    private func adjust(by percentage: CGFloat) -> SKColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return SKColor(
            red: min(max(red + percentage, 0), 1),
            green: min(max(green + percentage, 0), 1),
            blue: min(max(blue + percentage, 0), 1),
            alpha: alpha
        )
    }
}

// MARK: - Part Renderer
class PartRenderer {
    static let shared = PartRenderer()
    private let gridSize = GameConstants.gridSize
    
    // MARK: - Main Render Method
    func createNode(for part: GamePart) -> SKNode {
        let container = SKNode()
        container.name = "part_\(part.id.uuidString)"
        
        let visual = createVisual(for: part.type)
        container.addChild(visual)
        
        let body = createPhysicsBody(for: part.type)
        container.physicsBody = body
        
        container.position = part.worldPosition
        container.zRotation = CGFloat(part.rotation) * .pi / 180
        
        if part.isFlipped {
            container.xScale = -1
        }
        
        part.node = container
        return container
    }
    
    // MARK: - Visual Creation
    private func createVisual(for type: PartType) -> SKNode {
        switch type {
        case .brassFrame: return createFrame(color: SteampunkColors.brass, accent: SteampunkColors.brassLight)
        case .ironFrame: return createFrame(color: SteampunkColors.iron, accent: SteampunkColors.ironLight)
        case .woodenFrame: return createWoodenFrame()
        case .copperPlate: return createFrame(color: SteampunkColors.copper, accent: SteampunkColors.copperLight)
        case .reinforcedFrame: return createReinforcedFrame()
        case .cogWheel: return createCogWheel(size: gridSize * 0.8, teeth: 8, color: SteampunkColors.iron)
        case .spikedWheel: return createSpikedWheel()
        case .tankTread: return createTankTread()
        case .propellerBlade: return createPropeller()
        case .ornithopterWing: return createOrnithopterWing()
        case .springLeg: return createSpringLeg()
        case .steamBoiler: return createSteamBoiler()
        case .coalFurnace: return createCoalFurnace()
        case .clockworkMotor: return createClockworkMotor()
        case .teslaCoil: return createTeslaCoil()
        case .windupSpring: return createWindupSpring()
        case .pressureTank: return createPressureTank()
        case .smallGear: return createCogWheel(size: gridSize * 0.5, teeth: 6, color: SteampunkColors.brass)
        case .largeGear: return createCogWheel(size: gridSize * 0.9, teeth: 12, color: SteampunkColors.brass)
        case .gearBox: return createGearBox()
        case .piston: return createPiston()
        case .crankshaft: return createCrankshaft()
        case .flywheel: return createFlywheel()
        case .beltDrive: return createBeltDrive()
        case .copperWire: return createCopperWire()
        case .capacitor: return createCapacitor()
        case .sparkGap: return createSparkGap()
        case .electromagneticCoil: return createElectromagneticCoil()
        case .lightningRod: return createLightningRod()
        case .arcLamp: return createArcLamp()
        case .pressurePlate: return createPressurePlate()
        case .tripwire: return createTripwire()
        case .timerSwitch: return createTimerSwitch()
        case .steamValve: return createSteamValve()
        case .pneumaticTube: return createPneumaticTube()
        case .bellows: return createBellows()
        case .cannon: return createCannon()
        case .dynamite: return createDynamite()
        case .hotAirBalloon: return createHotAirBalloon()
        case .parachute: return createParachute()
        case .grappleHook: return createGrappleHook()
        case .magneticAttractor: return createMagneticAttractor()
        case .gyroscope: return createGyroscope()
        case .kameraMan: return createKameraMan()
        }
    }
    
    // MARK: - Structural Parts
    private func createFrame(color: SKColor, accent: SKColor) -> SKNode {
        let node = SKNode()
        let size = gridSize - 4
        
        let frame = SKShapeNode(rectOf: CGSize(width: size, height: size), cornerRadius: 4)
        frame.fillColor = color
        frame.strokeColor = accent
        frame.lineWidth = 2
        node.addChild(frame)
        
        // Corner rivets
        for (dx, dy) in [(-1, -1), (1, -1), (-1, 1), (1, 1)] {
            let rivet = SKShapeNode(circleOfRadius: 3)
            rivet.fillColor = accent
            rivet.strokeColor = color.darker(by: 0.2)
            rivet.lineWidth = 1
            rivet.position = CGPoint(x: CGFloat(dx) * (size/2 - 6), y: CGFloat(dy) * (size/2 - 6))
            node.addChild(rivet)
        }
        
        return node
    }
    
    private func createWoodenFrame() -> SKNode {
        let node = SKNode()
        let size = gridSize - 4
        
        let frame = SKShapeNode(rectOf: CGSize(width: size, height: size), cornerRadius: 2)
        frame.fillColor = SteampunkColors.wood
        frame.strokeColor = SteampunkColors.woodDark
        frame.lineWidth = 2
        node.addChild(frame)
        
        // Wood grain
        for i in stride(from: -size/2 + 10, to: size/2 - 5, by: 12) {
            let grain = SKShapeNode(rectOf: CGSize(width: 1.5, height: size - 8))
            grain.fillColor = SteampunkColors.woodDark.withAlphaComponent(0.4)
            grain.strokeColor = .clear
            grain.position = CGPoint(x: i, y: 0)
            node.addChild(grain)
        }
        
        return node
    }
    
    private func createReinforcedFrame() -> SKNode {
        let node = createFrame(color: SteampunkColors.iron, accent: SteampunkColors.ironLight)
        let size = gridSize - 12
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -size/2, y: -size/2))
        path.addLine(to: CGPoint(x: size/2, y: size/2))
        path.move(to: CGPoint(x: size/2, y: -size/2))
        path.addLine(to: CGPoint(x: -size/2, y: size/2))
        
        let cross = SKShapeNode(path: path)
        cross.strokeColor = SteampunkColors.ironLight
        cross.lineWidth = 3
        node.addChild(cross)
        
        return node
    }
    
    // MARK: - Gears and Wheels
    private func createCogWheel(size: CGFloat, teeth: Int, color: SKColor) -> SKNode {
        let node = SKNode()
        
        let path = CGMutablePath()
        let innerRadius = size * 0.35
        let outerRadius = size * 0.5
        let toothAngle = CGFloat.pi * 2 / CGFloat(teeth)
        
        for i in 0..<teeth {
            let angle = CGFloat(i) * toothAngle
            let a1 = angle + toothAngle * 0.1
            let a2 = angle + toothAngle * 0.4
            let a3 = angle + toothAngle * 0.6
            let a4 = angle + toothAngle * 0.9
            
            if i == 0 {
                path.move(to: CGPoint(x: cos(a1) * innerRadius, y: sin(a1) * innerRadius))
            }
            path.addLine(to: CGPoint(x: cos(a1) * innerRadius, y: sin(a1) * innerRadius))
            path.addLine(to: CGPoint(x: cos(a2) * outerRadius, y: sin(a2) * outerRadius))
            path.addLine(to: CGPoint(x: cos(a3) * outerRadius, y: sin(a3) * outerRadius))
            path.addLine(to: CGPoint(x: cos(a4) * innerRadius, y: sin(a4) * innerRadius))
        }
        path.closeSubpath()
        
        let gear = SKShapeNode(path: path)
        gear.fillColor = color
        gear.strokeColor = color.lighter(by: 0.15)
        gear.lineWidth = 2
        node.addChild(gear)
        
        let hub = SKShapeNode(circleOfRadius: size * 0.18)
        hub.fillColor = color.darker(by: 0.15)
        hub.strokeColor = color
        hub.lineWidth = 2
        node.addChild(hub)
        
        let hole = SKShapeNode(circleOfRadius: size * 0.06)
        hole.fillColor = SteampunkColors.background
        hole.strokeColor = color.darker(by: 0.25)
        node.addChild(hole)
        
        return node
    }
    
    private func createSpikedWheel() -> SKNode {
        let node = SKNode()
        let radius = gridSize * 0.35
        
        let wheel = SKShapeNode(circleOfRadius: radius)
        wheel.fillColor = SteampunkColors.iron
        wheel.strokeColor = SteampunkColors.ironLight
        wheel.lineWidth = 2
        node.addChild(wheel)
        
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            let spike = SKShapeNode(rectOf: CGSize(width: 6, height: 14))
            spike.fillColor = SteampunkColors.ironLight
            spike.strokeColor = SteampunkColors.ironDark
            spike.position = CGPoint(x: cos(angle) * (radius + 5), y: sin(angle) * (radius + 5))
            spike.zRotation = angle
            node.addChild(spike)
        }
        
        let hub = SKShapeNode(circleOfRadius: radius * 0.35)
        hub.fillColor = SteampunkColors.brass
        hub.strokeColor = SteampunkColors.brassLight
        node.addChild(hub)
        
        return node
    }
    
    private func createTankTread() -> SKNode {
        let node = SKNode()
        let width = gridSize * 1.6
        let height = gridSize * 0.5
        
        let tread = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: height/2)
        tread.fillColor = SteampunkColors.ironDark
        tread.strokeColor = SteampunkColors.iron
        tread.lineWidth = 2
        node.addChild(tread)
        
        // Tread segments
        for x in stride(from: -width/2 + 8, through: width/2 - 8, by: 12) {
            let segment = SKShapeNode(rectOf: CGSize(width: 4, height: height - 6))
            segment.fillColor = SteampunkColors.iron
            segment.strokeColor = .clear
            segment.position = CGPoint(x: x, y: 0)
            node.addChild(segment)
        }
        
        // Wheels inside
        for dx in [-width/4, width/4] {
            let wheel = SKShapeNode(circleOfRadius: height * 0.3)
            wheel.fillColor = SteampunkColors.brass
            wheel.strokeColor = SteampunkColors.brassDark
            wheel.position = CGPoint(x: dx, y: 0)
            node.addChild(wheel)
        }
        
        return node
    }
    
    private func createPropeller() -> SKNode {
        let node = SKNode()
        
        // Hub
        let hub = SKShapeNode(circleOfRadius: 8)
        hub.fillColor = SteampunkColors.brass
        hub.strokeColor = SteampunkColors.brassLight
        node.addChild(hub)
        
        // Blades
        for i in 0..<3 {
            let angle = CGFloat(i) * .pi * 2 / 3
            let blade = SKShapeNode(ellipseOf: CGSize(width: 12, height: gridSize * 0.7))
            blade.fillColor = SteampunkColors.copper
            blade.strokeColor = SteampunkColors.copperLight
            blade.lineWidth = 1
            blade.position = CGPoint(x: cos(angle) * gridSize * 0.25, y: sin(angle) * gridSize * 0.25)
            blade.zRotation = angle + .pi / 2
            node.addChild(blade)
        }
        
        return node
    }
    
    private func createOrnithopterWing() -> SKNode {
        let node = SKNode()
        let width = gridSize * 1.8
        let height = gridSize * 0.6
        
        // Wing membrane
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addQuadCurve(to: CGPoint(x: width/2, y: 0), control: CGPoint(x: width/4, y: height/2))
        path.addLine(to: CGPoint(x: width/2, y: -height * 0.3))
        path.addQuadCurve(to: CGPoint(x: 0, y: 0), control: CGPoint(x: width/4, y: -height * 0.2))
        
        let wing = SKShapeNode(path: path)
        wing.fillColor = SteampunkColors.wood.withAlphaComponent(0.7)
        wing.strokeColor = SteampunkColors.woodDark
        wing.lineWidth = 2
        node.addChild(wing)
        
        // Ribs
        for i in 1...3 {
            let ribPath = CGMutablePath()
            let x = CGFloat(i) * width / 8
            ribPath.move(to: CGPoint(x: x, y: -height * 0.1))
            ribPath.addLine(to: CGPoint(x: x + width/8, y: height * 0.3))
            
            let rib = SKShapeNode(path: ribPath)
            rib.strokeColor = SteampunkColors.brass
            rib.lineWidth = 2
            node.addChild(rib)
        }
        
        return node
    }
    
    private func createSpringLeg() -> SKNode {
        let node = SKNode()
        let height = gridSize * 0.8
        
        // Spring coil
        let springPath = CGMutablePath()
        let coils = 5
        let coilHeight = height / CGFloat(coils)
        
        for i in 0..<coils {
            let y = -height/2 + CGFloat(i) * coilHeight
            springPath.move(to: CGPoint(x: -10, y: y))
            springPath.addQuadCurve(to: CGPoint(x: 10, y: y + coilHeight/2), control: CGPoint(x: 15, y: y + coilHeight/4))
            springPath.addQuadCurve(to: CGPoint(x: -10, y: y + coilHeight), control: CGPoint(x: -15, y: y + coilHeight * 0.75))
        }
        
        let spring = SKShapeNode(path: springPath)
        spring.strokeColor = SteampunkColors.brass
        spring.lineWidth = 3
        spring.lineCap = .round
        node.addChild(spring)
        
        // Foot
        let foot = SKShapeNode(rectOf: CGSize(width: 20, height: 8), cornerRadius: 2)
        foot.fillColor = SteampunkColors.iron
        foot.strokeColor = SteampunkColors.ironLight
        foot.position = CGPoint(x: 0, y: -height/2 - 4)
        node.addChild(foot)
        
        return node
    }
    
    // MARK: - Power Sources
    private func createSteamBoiler() -> SKNode {
        let node = SKNode()
        let width = gridSize - 8
        let height = gridSize * 1.8
        
        // Main tank
        let tank = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 8)
        tank.fillColor = SteampunkColors.copper
        tank.strokeColor = SteampunkColors.copperLight
        tank.lineWidth = 3
        node.addChild(tank)
        
        // Rivets
        for y in stride(from: -height/2 + 12, through: height/2 - 12, by: 16) {
            for dx in [-1, 1] {
                let rivet = SKShapeNode(circleOfRadius: 3)
                rivet.fillColor = SteampunkColors.copperLight
                rivet.strokeColor = SteampunkColors.copperDark
                rivet.position = CGPoint(x: CGFloat(dx) * (width/2 - 6), y: y)
                node.addChild(rivet)
            }
        }
        
        // Pressure gauge
        let gauge = SKShapeNode(circleOfRadius: 10)
        gauge.fillColor = SteampunkColors.brass
        gauge.strokeColor = SteampunkColors.brassLight
        gauge.position = CGPoint(x: 0, y: height/4)
        node.addChild(gauge)
        
        let gaugeFace = SKShapeNode(circleOfRadius: 7)
        gaugeFace.fillColor = .white.withAlphaComponent(0.9)
        gaugeFace.position = CGPoint(x: 0, y: height/4)
        node.addChild(gaugeFace)
        
        // Steam pipe on top
        let pipe = SKShapeNode(rectOf: CGSize(width: 12, height: 16))
        pipe.fillColor = SteampunkColors.brass
        pipe.strokeColor = SteampunkColors.brassLight
        pipe.position = CGPoint(x: 0, y: height/2 + 8)
        node.addChild(pipe)
        
        return node
    }
    
    private func createCoalFurnace() -> SKNode {
        let node = SKNode()
        let width = gridSize - 8
        let height = gridSize * 1.8
        
        // Main body
        let body = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 4)
        body.fillColor = SteampunkColors.ironDark
        body.strokeColor = SteampunkColors.iron
        body.lineWidth = 3
        node.addChild(body)
        
        // Fire door
        let door = SKShapeNode(rectOf: CGSize(width: width - 12, height: 24), cornerRadius: 2)
        door.fillColor = SteampunkColors.iron
        door.strokeColor = SteampunkColors.ironLight
        door.position = CGPoint(x: 0, y: -height/4)
        node.addChild(door)
        
        // Fire glow (visible through grate)
        let glow = SKShapeNode(rectOf: CGSize(width: width - 20, height: 16))
        glow.fillColor = SteampunkColors.fire
        glow.strokeColor = .clear
        glow.position = CGPoint(x: 0, y: -height/4)
        glow.name = "fireGlow"
        node.addChild(glow)
        
        // Chimney
        let chimney = SKShapeNode(rectOf: CGSize(width: 14, height: 20))
        chimney.fillColor = SteampunkColors.ironDark
        chimney.strokeColor = SteampunkColors.iron
        chimney.position = CGPoint(x: 0, y: height/2 + 10)
        node.addChild(chimney)
        
        return node
    }
    
    private func createClockworkMotor() -> SKNode {
        let node = SKNode()
        let size = gridSize - 8
        
        // Housing
        let housing = SKShapeNode(circleOfRadius: size/2)
        housing.fillColor = SteampunkColors.brass
        housing.strokeColor = SteampunkColors.brassLight
        housing.lineWidth = 3
        node.addChild(housing)
        
        // Visible gears inside
        let innerGear = createCogWheel(size: size * 0.5, teeth: 6, color: SteampunkColors.copper)
        innerGear.alpha = 0.8
        node.addChild(innerGear)
        
        // Winding key
        let keyBase = SKShapeNode(rectOf: CGSize(width: 8, height: 20))
        keyBase.fillColor = SteampunkColors.iron
        keyBase.strokeColor = SteampunkColors.ironLight
        keyBase.position = CGPoint(x: 0, y: size/2 + 10)
        node.addChild(keyBase)
        
        let keyHandle = SKShapeNode(rectOf: CGSize(width: 20, height: 6))
        keyHandle.fillColor = SteampunkColors.iron
        keyHandle.strokeColor = SteampunkColors.ironLight
        keyHandle.position = CGPoint(x: 0, y: size/2 + 22)
        node.addChild(keyHandle)
        
        return node
    }
    
    private func createTeslaCoil() -> SKNode {
        let node = SKNode()
        let height = gridSize * 0.9
        
        // Base
        let base = SKShapeNode(rectOf: CGSize(width: gridSize - 12, height: 16), cornerRadius: 2)
        base.fillColor = SteampunkColors.wood
        base.strokeColor = SteampunkColors.woodDark
        base.position = CGPoint(x: 0, y: -height/2 + 8)
        node.addChild(base)
        
        // Coil
        let coilPath = CGMutablePath()
        let coils = 8
        for i in 0..<coils {
            let y = -height/2 + 20 + CGFloat(i) * (height - 30) / CGFloat(coils)
            let radius = 12 - CGFloat(i) * 0.8
            coilPath.addEllipse(in: CGRect(x: -radius, y: y - 2, width: radius * 2, height: 4))
        }
        
        let coil = SKShapeNode(path: coilPath)
        coil.strokeColor = SteampunkColors.copper
        coil.lineWidth = 2
        node.addChild(coil)
        
        // Top sphere
        let sphere = SKShapeNode(circleOfRadius: 10)
        sphere.fillColor = SteampunkColors.brass
        sphere.strokeColor = SteampunkColors.brassLight
        sphere.position = CGPoint(x: 0, y: height/2 - 8)
        node.addChild(sphere)
        
        // Electricity glow (animated separately)
        let glow = SKShapeNode(circleOfRadius: 14)
        glow.fillColor = SteampunkColors.electricity.withAlphaComponent(0.3)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: 0, y: height/2 - 8)
        glow.name = "electricGlow"
        glow.alpha = 0
        node.addChild(glow)
        
        return node
    }
    
    private func createWindupSpring() -> SKNode {
        let node = SKNode()
        let size = gridSize - 12
        
        // Housing
        let housing = SKShapeNode(circleOfRadius: size/2)
        housing.fillColor = SteampunkColors.brass
        housing.strokeColor = SteampunkColors.brassLight
        housing.lineWidth = 2
        node.addChild(housing)
        
        // Spiral spring
        let spiralPath = CGMutablePath()
        let turns = 4
        for i in 0..<(turns * 20) {
            let t = CGFloat(i) / 20
            let radius = 5 + t * (size/2 - 10) / CGFloat(turns)
            let angle = t * .pi * 2
            let point = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            if i == 0 {
                spiralPath.move(to: point)
            } else {
                spiralPath.addLine(to: point)
            }
        }
        
        let spiral = SKShapeNode(path: spiralPath)
        spiral.strokeColor = SteampunkColors.iron
        spiral.lineWidth = 2
        node.addChild(spiral)
        
        return node
    }
    
    private func createPressureTank() -> SKNode {
        let node = SKNode()
        let width = gridSize - 8
        let height = gridSize * 0.7
        
        // Tank (horizontal cylinder)
        let tank = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: height/2)
        tank.fillColor = SteampunkColors.brass
        tank.strokeColor = SteampunkColors.brassLight
        tank.lineWidth = 2
        node.addChild(tank)
        
        // Bands
        for x in [-width/3, 0, width/3] {
            let band = SKShapeNode(rectOf: CGSize(width: 4, height: height + 4))
            band.fillColor = SteampunkColors.iron
            band.strokeColor = SteampunkColors.ironLight
            band.position = CGPoint(x: x, y: 0)
            node.addChild(band)
        }
        
        // Valve on top
        let valve = SKShapeNode(circleOfRadius: 6)
        valve.fillColor = SteampunkColors.copper
        valve.strokeColor = SteampunkColors.copperLight
        valve.position = CGPoint(x: 0, y: height/2 + 4)
        node.addChild(valve)
        
        return node
    }
    
    // MARK: - Mechanical Parts
    private func createGearBox() -> SKNode {
        let node = SKNode()
        let size = gridSize - 8
        
        let box = SKShapeNode(rectOf: CGSize(width: size, height: size), cornerRadius: 4)
        box.fillColor = SteampunkColors.iron
        box.strokeColor = SteampunkColors.ironLight
        box.lineWidth = 2
        node.addChild(box)
        
        // Gears visible through window
        let window = SKShapeNode(circleOfRadius: size * 0.3)
        window.fillColor = SteampunkColors.background
        window.strokeColor = SteampunkColors.brass
        window.lineWidth = 2
        node.addChild(window)
        
        let miniGear = createCogWheel(size: size * 0.4, teeth: 6, color: SteampunkColors.brass)
        miniGear.setScale(0.6)
        node.addChild(miniGear)
        
        return node
    }
    
    private func createPiston() -> SKNode {
        let node = SKNode()
        let width = gridSize * 0.5
        let height = gridSize - 8
        
        // Cylinder
        let cylinder = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 4)
        cylinder.fillColor = SteampunkColors.brass
        cylinder.strokeColor = SteampunkColors.brassLight
        cylinder.lineWidth = 2
        node.addChild(cylinder)
        
        // Piston rod
        let rod = SKShapeNode(rectOf: CGSize(width: width * 0.4, height: height * 0.6))
        rod.fillColor = SteampunkColors.iron
        rod.strokeColor = SteampunkColors.ironLight
        rod.position = CGPoint(x: 0, y: 5)
        rod.name = "pistonRod"
        node.addChild(rod)
        
        return node
    }
    
    private func createCrankshaft() -> SKNode {
        let node = SKNode()
        let width = gridSize - 8
        
        // Main shaft
        let shaft = SKShapeNode(rectOf: CGSize(width: width, height: 8))
        shaft.fillColor = SteampunkColors.iron
        shaft.strokeColor = SteampunkColors.ironLight
        shaft.lineWidth = 2
        node.addChild(shaft)
        
        // Crank arm
        let crank = SKShapeNode(rectOf: CGSize(width: 8, height: 20))
        crank.fillColor = SteampunkColors.iron
        crank.strokeColor = SteampunkColors.ironLight
        crank.position = CGPoint(x: 0, y: 10)
        node.addChild(crank)
        
        // End bearings
        for x in [-width/2, width/2] {
            let bearing = SKShapeNode(circleOfRadius: 8)
            bearing.fillColor = SteampunkColors.brass
            bearing.strokeColor = SteampunkColors.brassLight
            bearing.position = CGPoint(x: x, y: 0)
            node.addChild(bearing)
        }
        
        return node
    }
    
    private func createFlywheel() -> SKNode {
        let node = SKNode()
        let radius = gridSize * 0.4
        
        // Heavy wheel
        let wheel = SKShapeNode(circleOfRadius: radius)
        wheel.fillColor = SteampunkColors.iron
        wheel.strokeColor = SteampunkColors.ironLight
        wheel.lineWidth = 4
        node.addChild(wheel)
        
        // Spokes
        for i in 0..<4 {
            let angle = CGFloat(i) * .pi / 2
            let spoke = SKShapeNode(rectOf: CGSize(width: 4, height: radius * 1.6))
            spoke.fillColor = SteampunkColors.ironLight
            spoke.strokeColor = .clear
            spoke.zRotation = angle
            node.addChild(spoke)
        }
        
        // Hub
        let hub = SKShapeNode(circleOfRadius: radius * 0.25)
        hub.fillColor = SteampunkColors.brass
        hub.strokeColor = SteampunkColors.brassLight
        node.addChild(hub)
        
        return node
    }
    
    private func createBeltDrive() -> SKNode {
        let node = SKNode()
        let width = gridSize - 8
        
        // Belt
        let belt = SKShapeNode(rectOf: CGSize(width: width, height: 8), cornerRadius: 4)
        belt.fillColor = SteampunkColors.woodDark
        belt.strokeColor = SteampunkColors.wood
        belt.lineWidth = 1
        node.addChild(belt)
        
        // Pulleys at ends
        for x in [-width/2 + 8, width/2 - 8] {
            let pulley = SKShapeNode(circleOfRadius: 10)
            pulley.fillColor = SteampunkColors.brass
            pulley.strokeColor = SteampunkColors.brassLight
            pulley.position = CGPoint(x: x, y: 0)
            node.addChild(pulley)
        }
        
        return node
    }
    
    // MARK: - Electrical Parts
    private func createCopperWire() -> SKNode {
        let node = SKNode()
        let width = gridSize - 8
        
        // Wire
        let wire = SKShapeNode(rectOf: CGSize(width: width, height: 4))
        wire.fillColor = SteampunkColors.copper
        wire.strokeColor = SteampunkColors.copperLight
        node.addChild(wire)
        
        // Connectors
        for x in [-width/2, width/2] {
            let connector = SKShapeNode(circleOfRadius: 5)
            connector.fillColor = SteampunkColors.copperLight
            connector.strokeColor = SteampunkColors.copper
            connector.position = CGPoint(x: x, y: 0)
            node.addChild(connector)
        }
        
        return node
    }
    
    private func createCapacitor() -> SKNode {
        let node = SKNode()
        let width = gridSize * 0.6
        let height = gridSize - 12
        
        // Glass jar
        let jar = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 4)
        jar.fillColor = SKColor(white: 0.9, alpha: 0.3)
        jar.strokeColor = SteampunkColors.brass
        jar.lineWidth = 2
        node.addChild(jar)
        
        // Metal plates inside
        let plate1 = SKShapeNode(rectOf: CGSize(width: width - 12, height: height - 16))
        plate1.fillColor = SteampunkColors.copper.withAlphaComponent(0.7)
        plate1.strokeColor = .clear
        plate1.position = CGPoint(x: -3, y: 0)
        node.addChild(plate1)
        
        let plate2 = SKShapeNode(rectOf: CGSize(width: width - 12, height: height - 16))
        plate2.fillColor = SteampunkColors.copper.withAlphaComponent(0.7)
        plate2.strokeColor = .clear
        plate2.position = CGPoint(x: 3, y: 0)
        node.addChild(plate2)
        
        // Terminals
        for x in [-width/4, width/4] {
            let terminal = SKShapeNode(circleOfRadius: 4)
            terminal.fillColor = SteampunkColors.brass
            terminal.strokeColor = SteampunkColors.brassLight
            terminal.position = CGPoint(x: x, y: height/2 + 2)
            node.addChild(terminal)
        }
        
        return node
    }
    
    private func createSparkGap() -> SKNode {
        let node = SKNode()
        let width = gridSize - 12
        
        // Base
        let base = SKShapeNode(rectOf: CGSize(width: width, height: 12))
        base.fillColor = SteampunkColors.wood
        base.strokeColor = SteampunkColors.woodDark
        base.position = CGPoint(x: 0, y: -10)
        node.addChild(base)
        
        // Electrodes
        for x in [-12, 12] {
            let electrode = SKShapeNode(rectOf: CGSize(width: 6, height: 30))
            electrode.fillColor = SteampunkColors.brass
            electrode.strokeColor = SteampunkColors.brassLight
            electrode.position = CGPoint(x: CGFloat(x), y: 5)
            node.addChild(electrode)
            
            let tip = SKShapeNode(circleOfRadius: 4)
            tip.fillColor = SteampunkColors.copper
            tip.strokeColor = SteampunkColors.copperLight
            tip.position = CGPoint(x: CGFloat(x), y: 22)
            node.addChild(tip)
        }
        
        return node
    }
    
    private func createElectromagneticCoil() -> SKNode {
        let node = SKNode()
        let width = gridSize * 0.5
        let height = gridSize - 12
        
        // Iron core
        let core = SKShapeNode(rectOf: CGSize(width: width * 0.4, height: height))
        core.fillColor = SteampunkColors.iron
        core.strokeColor = SteampunkColors.ironLight
        node.addChild(core)
        
        // Copper windings
        for y in stride(from: -height/2 + 6, through: height/2 - 6, by: 6) {
            let winding = SKShapeNode(rectOf: CGSize(width: width, height: 4))
            winding.fillColor = SteampunkColors.copper
            winding.strokeColor = SteampunkColors.copperLight
            winding.lineWidth = 1
            winding.position = CGPoint(x: 0, y: y)
            node.addChild(winding)
        }
        
        return node
    }
    
    private func createLightningRod() -> SKNode {
        let node = SKNode()
        let height = gridSize - 8
        
        // Rod
        let rod = SKShapeNode(rectOf: CGSize(width: 6, height: height))
        rod.fillColor = SteampunkColors.copper
        rod.strokeColor = SteampunkColors.copperLight
        rod.lineWidth = 2
        node.addChild(rod)
        
        // Pointed tip
        let tipPath = CGMutablePath()
        tipPath.move(to: CGPoint(x: -6, y: height/2))
        tipPath.addLine(to: CGPoint(x: 0, y: height/2 + 12))
        tipPath.addLine(to: CGPoint(x: 6, y: height/2))
        tipPath.closeSubpath()
        
        let tip = SKShapeNode(path: tipPath)
        tip.fillColor = SteampunkColors.copperLight
        tip.strokeColor = SteampunkColors.copper
        node.addChild(tip)
        
        return node
    }
    
    private func createArcLamp() -> SKNode {
        let node = SKNode()
        
        // Housing
        let housing = SKShapeNode(circleOfRadius: gridSize * 0.35)
        housing.fillColor = SteampunkColors.brass
        housing.strokeColor = SteampunkColors.brassLight
        housing.lineWidth = 2
        node.addChild(housing)
        
        // Glass dome
        let glass = SKShapeNode(circleOfRadius: gridSize * 0.25)
        glass.fillColor = SKColor(white: 1, alpha: 0.3)
        glass.strokeColor = SteampunkColors.brassLight.withAlphaComponent(0.5)
        node.addChild(glass)
        
        // Filament
        let filament = SKShapeNode(circleOfRadius: 6)
        filament.fillColor = SteampunkColors.fire
        filament.strokeColor = .clear
        filament.name = "lampGlow"
        filament.alpha = 0.3
        node.addChild(filament)
        
        return node
    }
    
    // MARK: - Triggers
    private func createPressurePlate() -> SKNode {
        let node = SKNode()
        let width = gridSize - 8
        
        // Base
        let base = SKShapeNode(rectOf: CGSize(width: width, height: 8))
        base.fillColor = SteampunkColors.iron
        base.strokeColor = SteampunkColors.ironLight
        base.position = CGPoint(x: 0, y: -8)
        node.addChild(base)
        
        // Plate
        let plate = SKShapeNode(rectOf: CGSize(width: width - 4, height: 6))
        plate.fillColor = SteampunkColors.brass
        plate.strokeColor = SteampunkColors.brassLight
        plate.name = "pressurePlate"
        node.addChild(plate)
        
        return node
    }
    
    private func createTripwire() -> SKNode {
        let node = SKNode()
        let width = gridSize - 8
        
        // Posts
        for x in [-width/2, width/2] {
            let post = SKShapeNode(rectOf: CGSize(width: 6, height: 20))
            post.fillColor = SteampunkColors.wood
            post.strokeColor = SteampunkColors.woodDark
            post.position = CGPoint(x: x, y: 0)
            node.addChild(post)
        }
        
        // Wire
        let wire = SKShapeNode(rectOf: CGSize(width: width - 8, height: 2))
        wire.fillColor = SteampunkColors.copper
        wire.strokeColor = .clear
        wire.name = "tripwire"
        node.addChild(wire)
        
        return node
    }
    
    private func createTimerSwitch() -> SKNode {
        let node = SKNode()
        let size = gridSize - 12
        
        // Clock face
        let face = SKShapeNode(circleOfRadius: size/2)
        face.fillColor = SteampunkColors.brass
        face.strokeColor = SteampunkColors.brassLight
        face.lineWidth = 3
        node.addChild(face)
        
        let innerFace = SKShapeNode(circleOfRadius: size/2 - 4)
        innerFace.fillColor = .white.withAlphaComponent(0.9)
        innerFace.strokeColor = .clear
        node.addChild(innerFace)
        
        // Clock hand
        let hand = SKShapeNode(rectOf: CGSize(width: 3, height: size/2 - 8))
        hand.fillColor = SteampunkColors.ironDark
        hand.strokeColor = .clear
        hand.position = CGPoint(x: 0, y: (size/2 - 8) / 2)
        hand.name = "timerHand"
        node.addChild(hand)
        
        return node
    }
    
    private func createSteamValve() -> SKNode {
        let node = SKNode()
        
        // Pipe section
        let pipe = SKShapeNode(rectOf: CGSize(width: gridSize - 12, height: 20))
        pipe.fillColor = SteampunkColors.brass
        pipe.strokeColor = SteampunkColors.brassLight
        pipe.lineWidth = 2
        node.addChild(pipe)
        
        // Valve wheel
        let wheel = createCogWheel(size: 28, teeth: 8, color: SteampunkColors.iron)
        wheel.position = CGPoint(x: 0, y: 20)
        node.addChild(wheel)
        
        return node
    }
    
    private func createPneumaticTube() -> SKNode {
        let node = SKNode()
        let width = gridSize - 8
        
        // Tube
        let tube = SKShapeNode(rectOf: CGSize(width: width, height: 16), cornerRadius: 8)
        tube.fillColor = SteampunkColors.brass.withAlphaComponent(0.7)
        tube.strokeColor = SteampunkColors.brass
        tube.lineWidth = 2
        node.addChild(tube)
        
        // Glass section
        let glass = SKShapeNode(rectOf: CGSize(width: width * 0.6, height: 12), cornerRadius: 6)
        glass.fillColor = SKColor(white: 0.95, alpha: 0.5)
        glass.strokeColor = .clear
        node.addChild(glass)
        
        return node
    }
    
    private func createBellows() -> SKNode {
        let node = SKNode()
        let width = gridSize - 12
        let height = gridSize * 0.6
        
        // Accordion folds
        let path = CGMutablePath()
        let folds = 4
        for i in 0...folds {
            let y = -height/2 + CGFloat(i) * height / CGFloat(folds)
            let inset: CGFloat = (i % 2 == 0) ? 0 : 8
            
            if i == 0 {
                path.move(to: CGPoint(x: -width/2 + inset, y: y))
            }
            path.addLine(to: CGPoint(x: -width/2 + inset, y: y))
            path.addLine(to: CGPoint(x: width/2 - inset, y: y))
        }
        for i in (0...folds).reversed() {
            let y = -height/2 + CGFloat(i) * height / CGFloat(folds)
            let inset: CGFloat = (i % 2 == 0) ? 0 : 8
            path.addLine(to: CGPoint(x: width/2 - inset, y: y))
        }
        path.closeSubpath()
        
        let bellows = SKShapeNode(path: path)
        bellows.fillColor = SteampunkColors.wood
        bellows.strokeColor = SteampunkColors.woodDark
        bellows.lineWidth = 2
        node.addChild(bellows)
        
        // Nozzle
        let nozzle = SKShapeNode(rectOf: CGSize(width: 12, height: 8))
        nozzle.fillColor = SteampunkColors.brass
        nozzle.strokeColor = SteampunkColors.brassLight
        nozzle.position = CGPoint(x: width/2 + 6, y: 0)
        node.addChild(nozzle)
        
        return node
    }
    
    private func createCannon() -> SKNode {
        let node = SKNode()
        let length = gridSize - 8
        
        // Barrel
        let barrel = SKShapeNode(rectOf: CGSize(width: length, height: 18), cornerRadius: 4)
        barrel.fillColor = SteampunkColors.iron
        barrel.strokeColor = SteampunkColors.ironLight
        barrel.lineWidth = 2
        node.addChild(barrel)
        
        // Muzzle
        let muzzle = SKShapeNode(circleOfRadius: 12)
        muzzle.fillColor = SteampunkColors.ironDark
        muzzle.strokeColor = SteampunkColors.iron
        muzzle.position = CGPoint(x: length/2, y: 0)
        node.addChild(muzzle)
        
        // Rear
        let rear = SKShapeNode(rectOf: CGSize(width: 16, height: 24), cornerRadius: 4)
        rear.fillColor = SteampunkColors.iron
        rear.strokeColor = SteampunkColors.ironLight
        rear.position = CGPoint(x: -length/2, y: 0)
        node.addChild(rear)
        
        return node
    }
    
    private func createDynamite() -> SKNode {
        let node = SKNode()
        
        // Sticks
        for dx in [-8, 0, 8] {
            let stick = SKShapeNode(rectOf: CGSize(width: 10, height: gridSize * 0.7), cornerRadius: 2)
            stick.fillColor = SteampunkColors.danger
            stick.strokeColor = SteampunkColors.danger.darker(by: 0.2)
            stick.position = CGPoint(x: CGFloat(dx), y: 0)
            node.addChild(stick)
        }
        
        // Fuse
        let fusePath = CGMutablePath()
        fusePath.move(to: CGPoint(x: 0, y: gridSize * 0.35))
        fusePath.addQuadCurve(to: CGPoint(x: 8, y: gridSize * 0.5), control: CGPoint(x: 10, y: gridSize * 0.4))
        
        let fuse = SKShapeNode(path: fusePath)
        fuse.strokeColor = SteampunkColors.woodDark
        fuse.lineWidth = 2
        node.addChild(fuse)
        
        // Spark
        let spark = SKShapeNode(circleOfRadius: 3)
        spark.fillColor = SteampunkColors.fire
        spark.strokeColor = .clear
        spark.position = CGPoint(x: 8, y: gridSize * 0.5)
        spark.name = "fuseSpark"
        node.addChild(spark)
        
        return node
    }
    
    // MARK: - Special Parts
    private func createHotAirBalloon() -> SKNode {
        let node = SKNode()
        let size = gridSize * 1.6
        
        // Balloon envelope
        let balloon = SKShapeNode(ellipseOf: CGSize(width: size, height: size * 1.2))
        balloon.fillColor = SteampunkColors.copper
        balloon.strokeColor = SteampunkColors.copperLight
        balloon.lineWidth = 2
        balloon.position = CGPoint(x: 0, y: size * 0.3)
        node.addChild(balloon)
        
        // Stripes
        for i in stride(from: -3, through: 3, by: 2) {
            let stripe = SKShapeNode(rectOf: CGSize(width: size * 0.15, height: size * 1.1))
            stripe.fillColor = SteampunkColors.brass.withAlphaComponent(0.5)
            stripe.strokeColor = .clear
            stripe.position = CGPoint(x: CGFloat(i) * size * 0.12, y: size * 0.3)
            node.addChild(stripe)
        }
        
        // Ropes
        for dx in [-1, 1] {
            let rope = SKShapeNode(rectOf: CGSize(width: 2, height: size * 0.4))
            rope.fillColor = SteampunkColors.woodDark
            rope.strokeColor = .clear
            rope.position = CGPoint(x: CGFloat(dx) * size * 0.3, y: -size * 0.15)
            node.addChild(rope)
        }
        
        // Basket
        let basket = SKShapeNode(rectOf: CGSize(width: size * 0.5, height: size * 0.25), cornerRadius: 4)
        basket.fillColor = SteampunkColors.wood
        basket.strokeColor = SteampunkColors.woodDark
        basket.position = CGPoint(x: 0, y: -size * 0.35)
        node.addChild(basket)
        
        return node
    }
    
    private func createParachute() -> SKNode {
        let node = SKNode()
        let size = gridSize * 0.8
        
        // Canopy
        let canopyPath = CGMutablePath()
        canopyPath.move(to: CGPoint(x: -size/2, y: 0))
        canopyPath.addQuadCurve(to: CGPoint(x: size/2, y: 0), control: CGPoint(x: 0, y: size * 0.6))
        canopyPath.addLine(to: CGPoint(x: size/2 - 4, y: -4))
        canopyPath.addQuadCurve(to: CGPoint(x: -size/2 + 4, y: -4), control: CGPoint(x: 0, y: size * 0.5))
        canopyPath.closeSubpath()
        
        let canopy = SKShapeNode(path: canopyPath)
        canopy.fillColor = SteampunkColors.copper
        canopy.strokeColor = SteampunkColors.copperLight
        canopy.position = CGPoint(x: 0, y: size * 0.2)
        node.addChild(canopy)
        
        // Strings
        for dx in [-size/3, 0, size/3] {
            let string = SKShapeNode(rectOf: CGSize(width: 1, height: size * 0.5))
            string.fillColor = SteampunkColors.woodDark
            string.strokeColor = .clear
            string.position = CGPoint(x: dx, y: -size * 0.1)
            node.addChild(string)
        }
        
        return node
    }
    
    private func createGrappleHook() -> SKNode {
        let node = SKNode()
        
        // Hook
        let hookPath = CGMutablePath()
        hookPath.move(to: CGPoint(x: 0, y: 0))
        hookPath.addLine(to: CGPoint(x: 0, y: -20))
        hookPath.addQuadCurve(to: CGPoint(x: 15, y: -10), control: CGPoint(x: 15, y: -25))
        
        let hook = SKShapeNode(path: hookPath)
        hook.strokeColor = SteampunkColors.iron
        hook.lineWidth = 4
        hook.lineCap = .round
        node.addChild(hook)
        
        // Second prong
        let hook2Path = CGMutablePath()
        hook2Path.move(to: CGPoint(x: 0, y: -20))
        hook2Path.addQuadCurve(to: CGPoint(x: -15, y: -10), control: CGPoint(x: -15, y: -25))
        
        let hook2 = SKShapeNode(path: hook2Path)
        hook2.strokeColor = SteampunkColors.iron
        hook2.lineWidth = 4
        hook2.lineCap = .round
        node.addChild(hook2)
        
        // Ring
        let ring = SKShapeNode(circleOfRadius: 6)
        ring.fillColor = .clear
        ring.strokeColor = SteampunkColors.brass
        ring.lineWidth = 3
        ring.position = CGPoint(x: 0, y: 8)
        node.addChild(ring)
        
        return node
    }
    
    private func createMagneticAttractor() -> SKNode {
        let node = SKNode()
        let size = gridSize * 0.7
        
        // Horseshoe magnet shape
        let magnetPath = CGMutablePath()
        magnetPath.addArc(center: CGPoint(x: 0, y: 0), radius: size/2, startAngle: 0, endAngle: .pi, clockwise: false)
        magnetPath.addLine(to: CGPoint(x: -size/2, y: -size/3))
        magnetPath.addLine(to: CGPoint(x: -size/2 + 10, y: -size/3))
        magnetPath.addLine(to: CGPoint(x: -size/2 + 10, y: 0))
        magnetPath.addArc(center: CGPoint(x: 0, y: 0), radius: size/2 - 10, startAngle: .pi, endAngle: 0, clockwise: true)
        magnetPath.addLine(to: CGPoint(x: size/2 - 10, y: -size/3))
        magnetPath.addLine(to: CGPoint(x: size/2, y: -size/3))
        magnetPath.closeSubpath()
        
        let magnet = SKShapeNode(path: magnetPath)
        magnet.fillColor = SteampunkColors.danger
        magnet.strokeColor = SteampunkColors.danger.darker(by: 0.2)
        magnet.lineWidth = 2
        node.addChild(magnet)
        
        // Poles
        let northPole = SKShapeNode(rectOf: CGSize(width: 10, height: 8))
        northPole.fillColor = SteampunkColors.iron
        northPole.position = CGPoint(x: -size/2 + 5, y: -size/3 - 4)
        node.addChild(northPole)
        
        let southPole = SKShapeNode(rectOf: CGSize(width: 10, height: 8))
        southPole.fillColor = SteampunkColors.ironLight
        southPole.position = CGPoint(x: size/2 - 5, y: -size/3 - 4)
        node.addChild(southPole)
        
        return node
    }
    
    private func createGyroscope() -> SKNode {
        let node = SKNode()
        let size = gridSize * 0.7
        
        // Outer ring
        let outer = SKShapeNode(circleOfRadius: size/2)
        outer.fillColor = .clear
        outer.strokeColor = SteampunkColors.brass
        outer.lineWidth = 4
        node.addChild(outer)
        
        // Middle ring (tilted)
        let middle = SKShapeNode(ellipseOf: CGSize(width: size * 0.7, height: size * 0.5))
        middle.fillColor = .clear
        middle.strokeColor = SteampunkColors.copper
        middle.lineWidth = 3
        middle.zRotation = .pi / 6
        node.addChild(middle)
        
        // Inner ring
        let inner = SKShapeNode(circleOfRadius: size * 0.25)
        inner.fillColor = SteampunkColors.iron
        inner.strokeColor = SteampunkColors.ironLight
        inner.lineWidth = 2
        node.addChild(inner)
        
        return node
    }
    
    // MARK: - Main Character: KAMERA-MAN! 📷
    // Inspired by the iconic sketch logo - spiky hair, camera to eye, photographer extraordinaire!
    private func createKameraMan() -> SKNode {
        let node = SKNode()
        
        // === THE ICONIC SPIKY HAIR! ===
        // Multiple spikes going up and to the right like in the logo
        let hairColors = [SteampunkColors.ironDark, SteampunkColors.iron, SteampunkColors.ironDark]
        let spikeConfigs: [(x: CGFloat, y: CGFloat, height: CGFloat, angle: CGFloat)] = [
            (-8, 48, 22, -0.3),    // Left spike
            (-2, 52, 28, -0.1),    // Left-center spike (tallest!)
            (5, 50, 24, 0.15),     // Right-center spike
            (12, 46, 18, 0.35),    // Right spike
            (16, 42, 14, 0.5),     // Far right small spike
            (-12, 44, 16, -0.45),  // Far left small spike
        ]
        
        for (i, config) in spikeConfigs.enumerated() {
            let spikePath = CGMutablePath()
            let baseWidth: CGFloat = 8
            spikePath.move(to: CGPoint(x: -baseWidth/2, y: 0))
            spikePath.addLine(to: CGPoint(x: 0, y: config.height))
            spikePath.addLine(to: CGPoint(x: baseWidth/2, y: 0))
            spikePath.closeSubpath()
            
            let spike = SKShapeNode(path: spikePath)
            spike.fillColor = hairColors[i % hairColors.count]
            spike.strokeColor = SteampunkColors.ironLight
            spike.lineWidth = 1
            spike.position = CGPoint(x: config.x, y: config.y)
            spike.zRotation = config.angle
            spike.zPosition = -1
            node.addChild(spike)
        }
        
        // === HEAD (Behind camera) ===
        let head = SKShapeNode(circleOfRadius: 18)
        head.fillColor = SteampunkColors.brassLight  // Warm skin-tone brass
        head.strokeColor = SteampunkColors.brass
        head.lineWidth = 2
        head.position = CGPoint(x: 0, y: 32)
        head.zPosition = -2
        node.addChild(head)
        
        // Visible ear on the side
        let ear = SKShapeNode(ellipseOf: CGSize(width: 8, height: 12))
        ear.fillColor = SteampunkColors.brassLight
        ear.strokeColor = SteampunkColors.brass
        ear.position = CGPoint(x: -20, y: 32)
        ear.zPosition = -3
        node.addChild(ear)
        
        // === THE CAMERA (The iconic element!) ===
        // Camera body - held up to face
        let cameraBody = SKShapeNode(rectOf: CGSize(width: 36, height: 28), cornerRadius: 4)
        cameraBody.fillColor = SteampunkColors.ironDark
        cameraBody.strokeColor = SteampunkColors.iron
        cameraBody.lineWidth = 2
        cameraBody.position = CGPoint(x: 2, y: 28)
        node.addChild(cameraBody)
        
        // Camera top (viewfinder hump)
        let cameraTop = SKShapeNode(rectOf: CGSize(width: 20, height: 10), cornerRadius: 3)
        cameraTop.fillColor = SteampunkColors.iron
        cameraTop.strokeColor = SteampunkColors.ironLight
        cameraTop.position = CGPoint(x: -2, y: 44)
        node.addChild(cameraTop)
        
        // Hot shoe / flash mount
        let hotShoe = SKShapeNode(rectOf: CGSize(width: 10, height: 4))
        hotShoe.fillColor = SteampunkColors.brass
        hotShoe.strokeColor = SteampunkColors.brassLight
        hotShoe.position = CGPoint(x: -2, y: 51)
        node.addChild(hotShoe)
        
        // Shutter button (red!)
        let shutterButton = SKShapeNode(circleOfRadius: 4)
        shutterButton.fillColor = SteampunkColors.danger
        shutterButton.strokeColor = SteampunkColors.danger.darker(by: 0.2)
        shutterButton.lineWidth = 1
        shutterButton.position = CGPoint(x: 12, y: 44)
        node.addChild(shutterButton)
        
        // === THE LENS (Camera's Eye = Kamera-Man's Eye!) ===
        // Lens barrel - copper rings like in the logo sketch
        let lensOuter = SKShapeNode(circleOfRadius: 16)
        lensOuter.fillColor = SteampunkColors.copper
        lensOuter.strokeColor = SteampunkColors.copperLight
        lensOuter.lineWidth = 2
        lensOuter.position = CGPoint(x: 2, y: 26)
        node.addChild(lensOuter)
        
        // Inner lens ring
        let lensMid = SKShapeNode(circleOfRadius: 12)
        lensMid.fillColor = SteampunkColors.copperDark
        lensMid.strokeColor = SteampunkColors.copper
        lensMid.lineWidth = 2
        lensMid.position = CGPoint(x: 2, y: 26)
        node.addChild(lensMid)
        
        // Lens barrel detail rings
        for radius in [14, 10] {
            let ring = SKShapeNode(circleOfRadius: CGFloat(radius))
            ring.fillColor = .clear
            ring.strokeColor = SteampunkColors.iron
            ring.lineWidth = 1
            ring.position = CGPoint(x: 2, y: 26)
            node.addChild(ring)
        }
        
        // The EYE - glowing lens glass (Studio 360° blue!)
        let lensGlass = SKShapeNode(circleOfRadius: 8)
        lensGlass.fillColor = SKColor(red: 0.15, green: 0.5, blue: 0.85, alpha: 1.0)
        lensGlass.strokeColor = SKColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0)
        lensGlass.lineWidth = 2
        lensGlass.glowWidth = 5
        lensGlass.position = CGPoint(x: 2, y: 26)
        lensGlass.name = "kameraManEye"
        node.addChild(lensGlass)
        
        // Lens highlight reflection
        let highlight = SKShapeNode(circleOfRadius: 2.5)
        highlight.fillColor = .white.withAlphaComponent(0.8)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -1, y: 29)
        node.addChild(highlight)
        
        // Aperture blade hints inside lens
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let blade = SKShapeNode(rectOf: CGSize(width: 1.5, height: 4))
            blade.fillColor = SteampunkColors.ironDark
            blade.strokeColor = .clear
            blade.position = CGPoint(x: 2 + cos(angle) * 5, y: 26 + sin(angle) * 5)
            blade.zRotation = angle
            node.addChild(blade)
        }
        
        // === HANDS HOLDING CAMERA (like in the logo!) ===
        // Right hand (gripping camera)
        let rightHandPath = CGMutablePath()
        rightHandPath.move(to: CGPoint(x: 18, y: 18))
        rightHandPath.addQuadCurve(to: CGPoint(x: 24, y: 28), control: CGPoint(x: 26, y: 22))
        rightHandPath.addQuadCurve(to: CGPoint(x: 20, y: 38), control: CGPoint(x: 28, y: 34))
        rightHandPath.addLine(to: CGPoint(x: 18, y: 34))
        rightHandPath.addLine(to: CGPoint(x: 20, y: 28))
        rightHandPath.closeSubpath()
        
        let rightHand = SKShapeNode(path: rightHandPath)
        rightHand.fillColor = SteampunkColors.brassLight
        rightHand.strokeColor = SteampunkColors.brass
        rightHand.lineWidth = 1.5
        rightHand.zPosition = 1
        node.addChild(rightHand)
        
        // Right hand fingers (wrapped around camera)
        for i in 0..<3 {
            let finger = SKShapeNode(ellipseOf: CGSize(width: 5, height: 8))
            finger.fillColor = SteampunkColors.brassLight
            finger.strokeColor = SteampunkColors.brass
            finger.lineWidth = 1
            finger.position = CGPoint(x: 22, y: 20 + CGFloat(i) * 6)
            finger.zPosition = 2
            node.addChild(finger)
        }
        
        // Left hand (supporting lens)
        let leftHandPath = CGMutablePath()
        leftHandPath.move(to: CGPoint(x: -14, y: 12))
        leftHandPath.addQuadCurve(to: CGPoint(x: -20, y: 22), control: CGPoint(x: -22, y: 16))
        leftHandPath.addQuadCurve(to: CGPoint(x: -16, y: 32), control: CGPoint(x: -24, y: 28))
        leftHandPath.addLine(to: CGPoint(x: -12, y: 28))
        leftHandPath.addLine(to: CGPoint(x: -14, y: 20))
        leftHandPath.closeSubpath()
        
        let leftHand = SKShapeNode(path: leftHandPath)
        leftHand.fillColor = SteampunkColors.brassLight
        leftHand.strokeColor = SteampunkColors.brass
        leftHand.lineWidth = 1.5
        leftHand.zPosition = 1
        node.addChild(leftHand)
        
        // Left fingers curled under lens
        for i in 0..<3 {
            let finger = SKShapeNode(ellipseOf: CGSize(width: 5, height: 7))
            finger.fillColor = SteampunkColors.brassLight
            finger.strokeColor = SteampunkColors.brass
            finger.lineWidth = 1
            finger.position = CGPoint(x: -16 - CGFloat(i) * 2, y: 16 + CGFloat(i) * 5)
            finger.zPosition = 2
            node.addChild(finger)
        }
        
        // === BODY (Torso below camera) ===
        let torso = SKShapeNode(rectOf: CGSize(width: 32, height: 24), cornerRadius: 4)
        torso.fillColor = SteampunkColors.copper  // Nice vest/shirt color
        torso.strokeColor = SteampunkColors.copperLight
        torso.lineWidth = 2
        torso.position = CGPoint(x: 0, y: 0)
        node.addChild(torso)
        
        // Vest details / buttons
        for y in [-4, 4] {
            let button = SKShapeNode(circleOfRadius: 2.5)
            button.fillColor = SteampunkColors.brass
            button.strokeColor = SteampunkColors.brassLight
            button.position = CGPoint(x: 0, y: CGFloat(y))
            node.addChild(button)
        }
        
        // Collar
        let collarLeft = SKShapeNode(rectOf: CGSize(width: 8, height: 6))
        collarLeft.fillColor = SteampunkColors.brassLight
        collarLeft.strokeColor = SteampunkColors.brass
        collarLeft.position = CGPoint(x: -8, y: 14)
        collarLeft.zRotation = 0.3
        node.addChild(collarLeft)
        
        let collarRight = SKShapeNode(rectOf: CGSize(width: 8, height: 6))
        collarRight.fillColor = SteampunkColors.brassLight
        collarRight.strokeColor = SteampunkColors.brass
        collarRight.position = CGPoint(x: 8, y: 14)
        collarRight.zRotation = -0.3
        node.addChild(collarRight)
        
        // === CAMERA STRAP ===
        let strapPath = CGMutablePath()
        strapPath.move(to: CGPoint(x: -18, y: 32))
        strapPath.addQuadCurve(to: CGPoint(x: -14, y: -5), control: CGPoint(x: -28, y: 15))
        
        let strap = SKShapeNode(path: strapPath)
        strap.strokeColor = SteampunkColors.woodDark
        strap.lineWidth = 4
        strap.lineCap = .round
        strap.zPosition = -1
        node.addChild(strap)
        
        // Strap connector ring
        let strapRing = SKShapeNode(circleOfRadius: 3)
        strapRing.fillColor = .clear
        strapRing.strokeColor = SteampunkColors.brass
        strapRing.lineWidth = 2
        strapRing.position = CGPoint(x: -18, y: 32)
        node.addChild(strapRing)
        
        // === WHEEL BASE (for movement in game) ===
        let wheelMount = SKShapeNode(rectOf: CGSize(width: 24, height: 6), cornerRadius: 2)
        wheelMount.fillColor = SteampunkColors.iron
        wheelMount.strokeColor = SteampunkColors.ironLight
        wheelMount.position = CGPoint(x: 0, y: -16)
        node.addChild(wheelMount)
        
        let wheel = SKShapeNode(circleOfRadius: 10)
        wheel.fillColor = SteampunkColors.ironDark
        wheel.strokeColor = SteampunkColors.iron
        wheel.lineWidth = 2
        wheel.position = CGPoint(x: 0, y: -26)
        node.addChild(wheel)
        
        // Wheel hub
        let wheelHub = SKShapeNode(circleOfRadius: 4)
        wheelHub.fillColor = SteampunkColors.brass
        wheelHub.strokeColor = SteampunkColors.brassLight
        wheelHub.position = CGPoint(x: 0, y: -26)
        node.addChild(wheelHub)
        
        // Wheel spokes
        for i in 0..<4 {
            let spoke = SKShapeNode(rectOf: CGSize(width: 1.5, height: 16))
            spoke.fillColor = SteampunkColors.iron
            spoke.strokeColor = .clear
            spoke.position = CGPoint(x: 0, y: -26)
            spoke.zRotation = CGFloat(i) * .pi / 4
            node.addChild(spoke)
        }
        
        // === "360°" BADGE (Studio 360° tribute!) ===
        let badge = SKShapeNode(rectOf: CGSize(width: 20, height: 8), cornerRadius: 2)
        badge.fillColor = SteampunkColors.brass
        badge.strokeColor = SteampunkColors.brassLight
        badge.position = CGPoint(x: 0, y: -6)
        node.addChild(badge)
        
        let badgeText = SKLabelNode(text: "360°")
        badgeText.fontName = "Menlo-Bold"
        badgeText.fontSize = 6
        badgeText.fontColor = SteampunkColors.ironDark
        badgeText.verticalAlignmentMode = .center
        badgeText.position = CGPoint(x: 0, y: -6)
        node.addChild(badgeText)
        
        // === FLASH INDICATOR (animated glow) ===
        let flashGlow = SKShapeNode(circleOfRadius: 6)
        flashGlow.fillColor = SteampunkColors.fire
        flashGlow.strokeColor = .clear
        flashGlow.position = CGPoint(x: -2, y: 51)
        flashGlow.alpha = 0
        flashGlow.name = "flashGlow"
        node.addChild(flashGlow)
        
        return node
    }
    
    // MARK: - Physics Bodies
    private func createPhysicsBody(for type: PartType) -> SKPhysicsBody {
        let size = type.gridSize
        let width = CGFloat(size.width) * gridSize - 4
        let height = CGFloat(size.height) * gridSize - 4
        
        let body: SKPhysicsBody
        
        switch type {
        case .cogWheel, .spikedWheel, .smallGear, .largeGear, .flywheel, .clockworkMotor, .windupSpring, .gyroscope:
            body = SKPhysicsBody(circleOfRadius: min(width, height) / 2 * 0.9)
        case .propellerBlade, .ornithopterWing, .hotAirBalloon, .parachute:
            body = SKPhysicsBody(rectangleOf: CGSize(width: width, height: height))
            body.linearDamping = 2.0  // Air resistance
            body.angularDamping = 2.0
        case .tankTread:
            body = SKPhysicsBody(rectangleOf: CGSize(width: width, height: height))
            body.friction = 1.0
        default:
            body = SKPhysicsBody(rectangleOf: CGSize(width: width, height: height))
        }
        
        body.mass = type.mass
        body.friction = 0.5
        body.restitution = 0.2
        body.linearDamping = 0.1
        body.angularDamping = 0.1
        body.categoryBitMask = PhysicsCategory.contraption
        body.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.trigger | PhysicsCategory.goal
        body.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.contraption
        
        return body
    }
}

// MARK: - Physics Categories
enum PhysicsCategory {
    static let none: UInt32 = 0
    static let contraption: UInt32 = 0b1
    static let ground: UInt32 = 0b10
    static let trigger: UInt32 = 0b100
    static let goal: UInt32 = 0b1000
    static let projectile: UInt32 = 0b10000
    static let hazard: UInt32 = 0b100000
}
