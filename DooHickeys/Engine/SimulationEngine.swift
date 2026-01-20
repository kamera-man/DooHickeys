import Foundation
import SpriteKit

// MARK: - Simulation Engine
class SimulationEngine {
    weak var scene: SKScene?
    var contraption: Contraption
    var isRunning = false
    var simulationSpeed: CGFloat = 1.0
    
    // Physics tracking
    private var powerNetwork: [UUID: Set<UUID>] = [:]  // Power source -> connected parts
    private var steamNetwork: [UUID: CGFloat] = [:]     // Part -> steam pressure
    private var electricNetwork: [UUID: CGFloat] = [:]  // Part -> charge
    private var rotationNetwork: [UUID: CGFloat] = [:]  // Part -> RPM
    
    // Event callbacks
    var onPartStateChanged: ((GamePart) -> Void)?
    var onExplosion: ((CGPoint) -> Void)?
    var onElectricalArc: ((CGPoint, CGPoint) -> Void)?
    var onSteamRelease: ((CGPoint, CGVector) -> Void)?
    var onKameraManDamaged: ((CGFloat) -> Void)?
    var onKameraManDestroyed: (() -> Void)?
    var onGoalReached: (() -> Void)?
    
    init(contraption: Contraption) {
        self.contraption = contraption
        buildNetworks()
    }
    
    // MARK: - Network Building
    private func buildNetworks() {
        powerNetwork.removeAll()
        
        // Find all power sources
        let powerSources = contraption.parts.filter { $0.type.isPowered }
        
        for source in powerSources {
            var connectedParts = Set<UUID>()
            var visited = Set<UUID>()
            var queue = [source.id]
            
            while !queue.isEmpty {
                let currentID = queue.removeFirst()
                guard !visited.contains(currentID) else { continue }
                visited.insert(currentID)
                
                if let part = contraption.part(withID: currentID), part.type.requiresPower {
                    connectedParts.insert(currentID)
                }
                
                // Find connected parts through appropriate connections
                for connection in contraption.connections where connection.partA == currentID || connection.partB == currentID {
                    let otherID = connection.partA == currentID ? connection.partB : connection.partA
                    
                    // Check if connection type transmits power
                    if canTransmitPower(connection.connectionType, from: source.type) {
                        queue.append(otherID)
                    }
                }
            }
            
            powerNetwork[source.id] = connectedParts
        }
    }
    
    private func canTransmitPower(_ connectionType: ConnectionType, from sourceType: PartType) -> Bool {
        switch sourceType {
        case .steamBoiler, .pressureTank:
            return connectionType == .steam || connectionType == .pneumatic
        case .teslaCoil, .capacitor:
            return connectionType == .electrical
        case .clockworkMotor, .windupSpring:
            return connectionType == .chain || connectionType == .axle
        case .coalFurnace:
            return connectionType == .rigid  // Heat transfer through contact
        default:
            return false
        }
    }
    
    // MARK: - Simulation Step
    func update(deltaTime: TimeInterval) {
        guard isRunning else { return }
        
        let dt = CGFloat(deltaTime) * simulationSpeed
        
        // Update each system
        updateHeatTransfer(dt: dt)
        updateSteamGeneration(dt: dt)
        updateSteamPropagation(dt: dt)
        updateElectricalFlow(dt: dt)
        updateMechanicalRotation(dt: dt)
        updateTriggers(dt: dt)
        checkForExplosions()
        checkForDamage()
    }
    
    // MARK: - Heat System
    private func updateHeatTransfer(dt: CGFloat) {
        // Coal furnaces generate heat
        for part in contraption.parts where part.type == .coalFurnace {
            if part.state.isActive {
                part.state.temperature = min(part.state.temperature + 50 * dt, 400)
            } else {
                // Cool down
                part.state.temperature = max(part.state.temperature - 10 * dt, 20)
            }
            onPartStateChanged?(part)
        }
        
        // Heat propagates to connected parts
        for connection in contraption.connections where connection.connectionType == .rigid {
            guard let partA = contraption.part(withID: connection.partA),
                  let partB = contraption.part(withID: connection.partB) else { continue }
            
            let tempDiff = partA.state.temperature - partB.state.temperature
            let transfer = tempDiff * 0.1 * dt
            
            partA.state.temperature -= transfer
            partB.state.temperature += transfer
        }
    }
    
    // MARK: - Steam System
    private func updateSteamGeneration(dt: CGFloat) {
        for part in contraption.parts where part.type == .steamBoiler {
            // Generate steam based on temperature
            if part.state.temperature > 100 {
                let rate = (part.state.temperature - 100) / 300 * 20 * dt
                part.state.steamPressure = min(part.state.steamPressure + rate, 150)
                onPartStateChanged?(part)
            }
        }
        
        // Pressure tanks store steam
        for part in contraption.parts where part.type == .pressureTank {
            // Slowly lose pressure
            part.state.steamPressure = max(part.state.steamPressure - 0.5 * dt, 0)
        }
    }
    
    private func updateSteamPropagation(dt: CGFloat) {
        // Steam flows through steam connections
        for connection in contraption.connections where connection.connectionType == .steam {
            guard let partA = contraption.part(withID: connection.partA),
                  let partB = contraption.part(withID: connection.partB) else { continue }
            
            let pressureDiff = partA.state.steamPressure - partB.state.steamPressure
            let flow = pressureDiff * 0.3 * dt
            
            partA.state.steamPressure -= flow
            partB.state.steamPressure += flow
            
            // Steam valves can block flow
            if partA.type == .steamValve && !partA.state.isActive {
                partA.state.steamPressure += flow
                partB.state.steamPressure -= flow
            }
            if partB.type == .steamValve && !partB.state.isActive {
                partA.state.steamPressure += flow
                partB.state.steamPressure -= flow
            }
        }
        
        // Pistons convert pressure to motion
        for part in contraption.parts where part.type == .piston {
            if part.state.steamPressure > 20 {
                part.state.mechanicalEnergy = part.state.steamPressure * 0.5
                part.state.steamPressure -= 10 * dt
                onPartStateChanged?(part)
            }
        }
    }
    
    // MARK: - Electrical System
    private func updateElectricalFlow(dt: CGFloat) {
        // Tesla coils generate electricity
        for part in contraption.parts where part.type == .teslaCoil {
            if part.state.isActive {
                part.state.electricCharge = min(part.state.electricCharge + 30 * dt, 100)
                
                // Periodically discharge
                if part.state.electricCharge > 80 {
                    dischargeElectricity(from: part)
                }
            }
            onPartStateChanged?(part)
        }
        
        // Capacitors store charge
        for part in contraption.parts where part.type == .capacitor {
            // Slow discharge
            part.state.electricCharge = max(part.state.electricCharge - 1 * dt, 0)
        }
        
        // Electrical propagation
        for connection in contraption.connections where connection.connectionType == .electrical {
            guard let partA = contraption.part(withID: connection.partA),
                  let partB = contraption.part(withID: connection.partB) else { continue }
            
            let chargeDiff = partA.state.electricCharge - partB.state.electricCharge
            let flow = chargeDiff * 0.5 * dt
            
            partA.state.electricCharge -= flow
            partB.state.electricCharge += flow
        }
        
        // Arc lamps light up
        for part in contraption.parts where part.type == .arcLamp {
            part.state.isActive = part.state.electricCharge > 30
            onPartStateChanged?(part)
        }
        
        // Electromagnetic coils create magnetism
        for part in contraption.parts where part.type == .electromagneticCoil {
            if part.state.electricCharge > 20 {
                part.state.isActive = true
                // Apply magnetic force to nearby metal parts
                applyMagneticForce(from: part)
            } else {
                part.state.isActive = false
            }
        }
    }
    
    private func dischargeElectricity(from part: GamePart) {
        // Find nearest conductive part or lightning rod
        var nearestTarget: GamePart?
        var nearestDistance = Int.max
        
        for other in contraption.parts where other.id != part.id {
            if other.type == .lightningRod || other.type == .copperPlate || other.type == .copperWire {
                let dist = part.gridPosition.distance(to: other.gridPosition)
                if dist < nearestDistance && dist <= 5 {
                    nearestDistance = dist
                    nearestTarget = other
                }
            }
        }
        
        if let target = nearestTarget {
            // Create arc
            let startPos = part.worldPosition
            let endPos = target.worldPosition
            onElectricalArc?(startPos, endPos)
            
            // Transfer charge
            target.state.electricCharge += part.state.electricCharge * 0.8
            part.state.electricCharge *= 0.2
            
            // Trigger if it's a trigger
            if target.type == .tripwire || target.type == .pressurePlate {
                target.state.isTriggered = true
                onPartStateChanged?(target)
            }
        }
    }
    
    private func applyMagneticForce(from coil: GamePart) {
        guard let coilNode = coil.node else { return }
        
        for part in contraption.parts where part.id != coil.id {
            // Metal parts are affected
            if part.type == .ironFrame || part.type == .smallGear || part.type == .largeGear {
                guard let partNode = part.node, let body = partNode.physicsBody else { continue }
                
                let dx = coilNode.position.x - partNode.position.x
                let dy = coilNode.position.y - partNode.position.y
                let distSq = dx * dx + dy * dy
                
                if distSq < 10000 && distSq > 1 {  // Within range
                    let force = coil.state.electricCharge * 10 / distSq
                    let normalizedDx = dx / sqrt(distSq)
                    let normalizedDy = dy / sqrt(distSq)
                    
                    body.applyForce(CGVector(dx: normalizedDx * force, dy: normalizedDy * force))
                }
            }
        }
    }
    
    // MARK: - Mechanical System
    private func updateMechanicalRotation(dt: CGFloat) {
        // Clockwork motors provide rotation
        for part in contraption.parts where part.type == .clockworkMotor {
            if part.state.isActive && part.state.mechanicalEnergy > 0 {
                part.state.rotationSpeed = 100  // Base RPM
                part.state.mechanicalEnergy -= 5 * dt
                onPartStateChanged?(part)
            } else {
                part.state.rotationSpeed = max(part.state.rotationSpeed - 20 * dt, 0)
            }
        }
        
        // Windup springs release energy
        for part in contraption.parts where part.type == .windupSpring {
            if part.state.isActive && part.state.mechanicalEnergy > 0 {
                let release = min(part.state.mechanicalEnergy, 20 * dt)
                part.state.mechanicalEnergy -= release
                part.state.rotationSpeed = release * 10
                onPartStateChanged?(part)
            }
        }
        
        // Rotation propagates through chains and axles
        propagateRotation()
        
        // Flywheels store rotational energy
        for part in contraption.parts where part.type == .flywheel {
            if part.state.rotationSpeed > 0 {
                part.state.mechanicalEnergy += part.state.rotationSpeed * 0.01 * dt
            } else if part.state.mechanicalEnergy > 0 {
                part.state.rotationSpeed = part.state.mechanicalEnergy * 0.5
                part.state.mechanicalEnergy -= 2 * dt
            }
        }
        
        // Apply rotation to wheels
        for part in contraption.parts where part.type == .cogWheel || part.type == .spikedWheel {
            if part.state.rotationSpeed > 0, let node = part.node, let body = node.physicsBody {
                let torque = part.state.rotationSpeed * 0.1
                body.applyTorque(torque)
            }
        }
        
        // Propellers generate thrust
        for part in contraption.parts where part.type == .propellerBlade {
            if part.state.rotationSpeed > 0, let node = part.node, let body = node.physicsBody {
                let thrust = part.state.rotationSpeed * 2
                let angle = node.zRotation + .pi / 2
                body.applyForce(CGVector(dx: cos(angle) * thrust, dy: sin(angle) * thrust))
            }
        }
    }
    
    private func propagateRotation() {
        var changed = true
        
        while changed {
            changed = false
            
            for connection in contraption.connections {
                guard connection.connectionType == .chain || connection.connectionType == .axle else { continue }
                guard let partA = contraption.part(withID: connection.partA),
                      let partB = contraption.part(withID: connection.partB) else { continue }
                
                // Calculate gear ratio
                var ratio: CGFloat = 1.0
                if partA.type == .smallGear && partB.type == .largeGear {
                    ratio = 0.5  // Speed halves, torque doubles
                } else if partA.type == .largeGear && partB.type == .smallGear {
                    ratio = 2.0  // Speed doubles, torque halves
                }
                
                // Propagate faster rotation to slower
                if partA.state.rotationSpeed > partB.state.rotationSpeed * ratio {
                    let transfer = (partA.state.rotationSpeed - partB.state.rotationSpeed * ratio) * 0.5
                    partB.state.rotationSpeed += transfer * ratio
                    partA.state.rotationSpeed -= transfer
                    changed = true
                } else if partB.state.rotationSpeed > partA.state.rotationSpeed / ratio {
                    let transfer = (partB.state.rotationSpeed - partA.state.rotationSpeed / ratio) * 0.5
                    partA.state.rotationSpeed += transfer / ratio
                    partB.state.rotationSpeed -= transfer
                    changed = true
                }
            }
        }
    }
    
    // MARK: - Trigger System
    private func updateTriggers(dt: CGFloat) {
        // Timer switches
        for part in contraption.parts where part.type == .timerSwitch {
            if part.state.isActive {
                part.state.mechanicalEnergy -= dt
                if part.state.mechanicalEnergy <= 0 {
                    part.state.isTriggered = true
                    part.state.isActive = false
                    onPartStateChanged?(part)
                    handleTrigger(part)
                }
            }
        }
        
        // Check triggered parts
        for part in contraption.parts where part.state.isTriggered {
            handleTrigger(part)
            part.state.isTriggered = false
        }
    }
    
    private func handleTrigger(_ trigger: GamePart) {
        // Find connected reactive parts
        for connection in contraption.connections where connection.partA == trigger.id || connection.partB == trigger.id {
            let otherID = connection.partA == trigger.id ? connection.partB : connection.partA
            guard let other = contraption.part(withID: otherID) else { continue }
            
            switch other.type {
            case .steamValve:
                other.state.isActive.toggle()
            case .dynamite:
                explode(part: other)
            case .cannon:
                fireCannon(other)
            case .bellows:
                activateBellows(other)
            case .windupSpring:
                other.state.isActive = true
            case .clockworkMotor:
                other.state.isActive.toggle()
            case .teslaCoil:
                other.state.isActive.toggle()
            case .coalFurnace:
                other.state.isActive.toggle()
            default:
                break
            }
            
            onPartStateChanged?(other)
        }
    }
    
    private func activateBellows(_ bellows: GamePart) {
        guard let node = bellows.node else { return }
        
        // Push air/steam in facing direction
        let direction = CGVector(
            dx: cos(node.zRotation) * 500,
            dy: sin(node.zRotation) * 500
        )
        
        // Affect nearby light parts
        for part in contraption.parts where part.type.mass < 0.5 {
            guard let partNode = part.node, let body = partNode.physicsBody else { continue }
            
            let dx = partNode.position.x - node.position.x
            let dy = partNode.position.y - node.position.y
            let dist = sqrt(dx * dx + dy * dy)
            
            if dist < 200 {
                let falloff = 1 - dist / 200
                body.applyImpulse(CGVector(dx: direction.dx * falloff, dy: direction.dy * falloff))
            }
        }
        
        onSteamRelease?(node.position, direction)
    }
    
    private func fireCannon(_ cannon: GamePart) {
        guard let node = cannon.node else { return }
        
        // Apply recoil
        if let body = node.physicsBody {
            let recoil = CGVector(
                dx: -cos(node.zRotation) * 1000,
                dy: -sin(node.zRotation) * 1000
            )
            body.applyImpulse(recoil)
        }
        
        // Create projectile (handled by scene)
        let launchPos = CGPoint(
            x: node.position.x + cos(node.zRotation) * 40,
            y: node.position.y + sin(node.zRotation) * 40
        )
        let launchVelocity = CGVector(
            dx: cos(node.zRotation) * 800,
            dy: sin(node.zRotation) * 800
        )
        
        // Notify scene to create projectile
        NotificationCenter.default.post(
            name: .cannonFired,
            object: nil,
            userInfo: ["position": launchPos, "velocity": launchVelocity]
        )
    }
    
    // MARK: - Explosions & Damage
    private func checkForExplosions() {
        for part in contraption.parts {
            // Steam pressure explosion
            if part.state.steamPressure > GameConstants.explosionThreshold {
                explode(part: part)
            }
            
            // Dynamite near heat
            if part.type == .dynamite && part.state.temperature > 200 {
                explode(part: part)
            }
            
            // Overloaded electrical
            if part.state.electricCharge > 120 && part.type != .teslaCoil {
                explode(part: part)
            }
        }
    }
    
    private func explode(part: GamePart) {
        guard let node = part.node else { return }
        
        let explosionForce: CGFloat = part.type == .dynamite ? 2000 : 1000
        let explosionRadius: CGFloat = part.type == .dynamite ? 300 : 150
        
        // Apply force to all nearby parts
        for other in contraption.parts where other.id != part.id {
            guard let otherNode = other.node, let body = otherNode.physicsBody else { continue }
            
            let dx = otherNode.position.x - node.position.x
            let dy = otherNode.position.y - node.position.y
            let dist = sqrt(dx * dx + dy * dy)
            
            if dist < explosionRadius && dist > 0 {
                let falloff = 1 - dist / explosionRadius
                let force = explosionForce * falloff
                body.applyImpulse(CGVector(
                    dx: (dx / dist) * force,
                    dy: (dy / dist) * force
                ))
                
                // Damage nearby parts
                other.state.durability -= 30 * falloff
                
                // Destroy wooden parts
                if other.type == .woodenFrame && falloff > 0.5 {
                    other.state.durability = 0
                }
            }
        }
        
        onExplosion?(node.position)
        
        // Remove exploded part
        contraption.removePart(part)
    }
    
    private func checkForDamage() {
        // Check KameraMan
        for part in contraption.parts where part.type == .kameraMan {
            if part.state.durability < 100 {
                onKameraManDamaged?(part.state.durability)
            }
            if part.state.durability <= 0 {
                onKameraManDestroyed?()
                isRunning = false
            }
        }
        
        // Remove destroyed parts
        let destroyed = contraption.parts.filter { $0.state.durability <= 0 }
        for part in destroyed {
            contraption.removePart(part)
        }
    }
    
    // MARK: - Control
    func start() {
        isRunning = true
        buildNetworks()
        
        // Activate initial power sources
        for part in contraption.parts {
            if part.type == .coalFurnace {
                part.state.isActive = true
            }
            if part.type == .clockworkMotor {
                part.state.mechanicalEnergy = 100  // Pre-wound
                part.state.isActive = true
            }
            if part.type == .windupSpring {
                part.state.mechanicalEnergy = 50
            }
            if part.type == .timerSwitch {
                part.state.mechanicalEnergy = 5  // 5 second timer
                part.state.isActive = true
            }
        }
    }
    
    func stop() {
        isRunning = false
    }
    
    func reset() {
        isRunning = false
        for part in contraption.parts {
            part.state = PartState()
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let cannonFired = Notification.Name("cannonFired")
    static let goalReached = Notification.Name("goalReached")
}
