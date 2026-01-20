import Foundation
import SpriteKit

// MARK: - Grid System
struct GridPosition: Hashable, Codable, Equatable {
    var x: Int
    var y: Int
    
    static let zero = GridPosition(x: 0, y: 0)
    
    func offset(dx: Int, dy: Int) -> GridPosition {
        GridPosition(x: x + dx, y: y + dy)
    }
    
    func distance(to other: GridPosition) -> Int {
        abs(x - other.x) + abs(y - other.y)
    }
    
    var neighbors: [GridPosition] {
        [offset(dx: 0, dy: 1), offset(dx: 1, dy: 0),
         offset(dx: 0, dy: -1), offset(dx: -1, dy: 0)]
    }
}

// MARK: - Attachment System
enum AttachmentSide: Int, CaseIterable, Codable {
    case top = 0
    case right = 1
    case bottom = 2
    case left = 3
    
    var opposite: AttachmentSide {
        AttachmentSide(rawValue: (rawValue + 2) % 4)!
    }
    
    var gridOffset: GridPosition {
        switch self {
        case .top: return GridPosition(x: 0, y: 1)
        case .right: return GridPosition(x: 1, y: 0)
        case .bottom: return GridPosition(x: 0, y: -1)
        case .left: return GridPosition(x: -1, y: 0)
        }
    }
    
    var angle: CGFloat {
        CGFloat(rawValue) * .pi / 2
    }
}

// MARK: - Connection Types
enum ConnectionType: String, Codable {
    case rigid           // Solid welded connection
    case hinged          // Can rotate (for flapping wings)
    case axle            // Wheel/gear axle connection
    case steam           // Steam pipe connection
    case electrical      // Copper wire connection
    case pneumatic       // Pneumatic tube
    case chain           // Chain/belt drive
    case magnetic        // Magnetic coupling
}

// MARK: - Part Categories
enum PartCategory: String, CaseIterable, Codable {
    case structural = "Structural"
    case locomotion = "Locomotion"
    case power = "Power"
    case mechanical = "Mechanical"
    case electrical = "Electrical"
    case triggers = "Triggers"
    case special = "Special"
    
    var icon: String {
        switch self {
        case .structural: return "⚙️"
        case .locomotion: return "🔩"
        case .power: return "🔥"
        case .mechanical: return "⚡"
        case .electrical: return "💡"
        case .triggers: return "🎯"
        case .special: return "✨"
        }
    }
}

// MARK: - Steampunk Part Types
enum PartType: String, CaseIterable, Codable {
    // Structural
    case brassFrame = "brass_frame"
    case ironFrame = "iron_frame"
    case woodenFrame = "wooden_frame"
    case copperPlate = "copper_plate"
    case reinforcedFrame = "reinforced_frame"
    
    // Locomotion
    case cogWheel = "cog_wheel"
    case spikedWheel = "spiked_wheel"
    case tankTread = "tank_tread"
    case propellerBlade = "propeller_blade"
    case ornithopterWing = "ornithopter_wing"
    case springLeg = "spring_leg"
    
    // Power Sources
    case steamBoiler = "steam_boiler"
    case coalFurnace = "coal_furnace"
    case clockworkMotor = "clockwork_motor"
    case teslaCoil = "tesla_coil"
    case windupSpring = "windup_spring"
    case pressureTank = "pressure_tank"
    
    // Mechanical
    case smallGear = "small_gear"
    case largeGear = "large_gear"
    case gearBox = "gear_box"
    case piston = "piston"
    case crankshaft = "crankshaft"
    case flywheel = "flywheel"
    case beltDrive = "belt_drive"
    
    // Electrical
    case copperWire = "copper_wire"
    case capacitor = "capacitor"
    case sparkGap = "spark_gap"
    case electromagneticCoil = "em_coil"
    case lightningRod = "lightning_rod"
    case arcLamp = "arc_lamp"
    
    // Triggers & Reactions
    case pressurePlate = "pressure_plate"
    case tripwire = "tripwire"
    case timerSwitch = "timer_switch"
    case steamValve = "steam_valve"
    case pneumaticTube = "pneumatic_tube"
    case bellows = "bellows"
    case cannon = "cannon"
    case dynamite = "dynamite"
    
    // Special
    case hotAirBalloon = "hot_air_balloon"
    case parachute = "parachute"
    case grappleHook = "grapple_hook"
    case magneticAttractor = "magnetic_attractor"
    case gyroscope = "gyroscope"
    case kameraMan = "kamera_man"  // Main character - THE legendary photographer!
    
    var category: PartCategory {
        switch self {
        case .brassFrame, .ironFrame, .woodenFrame, .copperPlate, .reinforcedFrame:
            return .structural
        case .cogWheel, .spikedWheel, .tankTread, .propellerBlade, .ornithopterWing, .springLeg:
            return .locomotion
        case .steamBoiler, .coalFurnace, .clockworkMotor, .teslaCoil, .windupSpring, .pressureTank:
            return .power
        case .smallGear, .largeGear, .gearBox, .piston, .crankshaft, .flywheel, .beltDrive:
            return .mechanical
        case .copperWire, .capacitor, .sparkGap, .electromagneticCoil, .lightningRod, .arcLamp:
            return .electrical
        case .pressurePlate, .tripwire, .timerSwitch, .steamValve, .pneumaticTube, .bellows, .cannon, .dynamite:
            return .triggers
        case .hotAirBalloon, .parachute, .grappleHook, .magneticAttractor, .gyroscope, .kameraMan:
            return .special
        }
    }
    
    var displayName: String {
        rawValue.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    var description: String {
        switch self {
        case .brassFrame: return "Standard frame. Lightweight and versatile."
        case .ironFrame: return "Heavy duty frame. Strong but heavier."
        case .woodenFrame: return "Light frame that burns when heated."
        case .copperPlate: return "Conducts electricity and heat."
        case .reinforcedFrame: return "Withstands explosions."
        case .cogWheel: return "Standard wheel driven by gears or steam."
        case .spikedWheel: return "Grips rough terrain."
        case .tankTread: return "Excellent traction on all surfaces."
        case .propellerBlade: return "Generates thrust when powered."
        case .ornithopterWing: return "Flapping wing for flight."
        case .springLeg: return "Bouncy leg for jumping."
        case .steamBoiler: return "Generates steam when heated."
        case .coalFurnace: return "Burns fuel to generate heat."
        case .clockworkMotor: return "Wind-up motor for steady rotation."
        case .teslaCoil: return "Generates electrical arcs."
        case .windupSpring: return "Stores mechanical energy."
        case .pressureTank: return "Stores steam pressure."
        case .smallGear: return "High speed, low torque (2:1)."
        case .largeGear: return "Low speed, high torque (1:2)."
        case .gearBox: return "Changes gear ratios."
        case .piston: return "Converts pressure to linear motion."
        case .crankshaft: return "Converts linear to rotational motion."
        case .flywheel: return "Stores rotational energy."
        case .beltDrive: return "Transfers rotation between shafts."
        case .copperWire: return "Conducts electricity."
        case .capacitor: return "Stores electrical charge."
        case .sparkGap: return "Releases electrical discharge."
        case .electromagneticCoil: return "Creates magnetic field when powered."
        case .lightningRod: return "Attracts electrical arcs."
        case .arcLamp: return "Emits light when electrified."
        case .pressurePlate: return "Triggers when weight applied."
        case .tripwire: return "Triggers when touched."
        case .timerSwitch: return "Triggers after set time."
        case .steamValve: return "Controls steam flow."
        case .pneumaticTube: return "Transports small objects."
        case .bellows: return "Pushes air when compressed."
        case .cannon: return "Launches projectiles."
        case .dynamite: return "Explodes when triggered!"
        case .hotAirBalloon: return "Provides lift when heated."
        case .parachute: return "Slows descent."
        case .grappleHook: return "Attaches to surfaces."
        case .magneticAttractor: return "Attracts metal objects."
        case .gyroscope: return "Stabilizes contraption."
        case .kameraMan: return "📷 KAMERA-MAN! The legendary 360° photographer. Keep him safe!"
        }
    }
    
    var mass: CGFloat {
        switch self {
        case .woodenFrame: return 0.5
        case .brassFrame, .copperPlate: return 1.0
        case .ironFrame, .reinforcedFrame: return 2.0
        case .cogWheel, .smallGear: return 0.3
        case .spikedWheel, .largeGear: return 0.5
        case .tankTread: return 1.5
        case .propellerBlade, .ornithopterWing: return 0.2
        case .springLeg: return 0.4
        case .steamBoiler, .pressureTank: return 2.5
        case .coalFurnace: return 3.0
        case .clockworkMotor: return 1.5
        case .teslaCoil: return 2.0
        case .windupSpring, .flywheel: return 1.0
        case .gearBox, .crankshaft: return 0.8
        case .piston: return 0.6
        case .beltDrive: return 0.2
        case .copperWire: return 0.1
        case .capacitor: return 0.5
        case .sparkGap, .arcLamp: return 0.3
        case .electromagneticCoil: return 0.7
        case .lightningRod: return 0.4
        case .pressurePlate, .tripwire: return 0.2
        case .timerSwitch: return 0.3
        case .steamValve: return 0.4
        case .pneumaticTube, .bellows: return 0.3
        case .cannon: return 2.0
        case .dynamite: return 0.5
        case .hotAirBalloon: return 0.1
        case .parachute: return 0.1
        case .grappleHook: return 0.5
        case .magneticAttractor: return 1.5
        case .gyroscope: return 1.0
        case .kameraMan: return 1.5
        }
    }
    
    var attachmentSides: [AttachmentSide] {
        switch self {
        case .brassFrame, .ironFrame, .woodenFrame, .copperPlate, .reinforcedFrame:
            return AttachmentSide.allCases
        case .cogWheel, .spikedWheel, .tankTread:
            return [.top]
        case .propellerBlade:
            return [.bottom]
        case .ornithopterWing:
            return [.left, .right]
        case .springLeg:
            return [.top]
        case .steamBoiler:
            return [.top, .bottom, .left, .right]
        case .coalFurnace:
            return [.top, .left, .right]
        case .clockworkMotor, .windupSpring:
            return [.top, .bottom]
        case .teslaCoil:
            return [.bottom]
        case .pressureTank:
            return [.left, .right, .bottom]
        case .smallGear, .largeGear:
            return [.left, .right]
        case .gearBox:
            return AttachmentSide.allCases
        case .piston:
            return [.top, .bottom]
        case .crankshaft:
            return [.left, .right]
        case .flywheel, .beltDrive:
            return [.left, .right]
        case .copperWire:
            return AttachmentSide.allCases
        case .capacitor, .sparkGap:
            return [.left, .right]
        case .electromagneticCoil:
            return [.top, .bottom]
        case .lightningRod:
            return [.bottom]
        case .arcLamp:
            return [.bottom, .left, .right]
        case .pressurePlate:
            return [.bottom]
        case .tripwire:
            return [.left, .right]
        case .timerSwitch, .steamValve:
            return [.top, .bottom, .left, .right]
        case .pneumaticTube:
            return [.left, .right]
        case .bellows:
            return [.bottom, .left, .right]
        case .cannon:
            return [.bottom, .left, .right]
        case .dynamite:
            return AttachmentSide.allCases
        case .hotAirBalloon:
            return [.bottom]
        case .parachute:
            return [.bottom]
        case .grappleHook:
            return [.bottom, .left, .right]
        case .magneticAttractor:
            return [.bottom]
        case .gyroscope:
            return [.bottom]
        case .kameraMan:
            return [.bottom]
        }
    }
    
    var connectionTypes: [ConnectionType] {
        switch self {
        case .brassFrame, .ironFrame, .woodenFrame, .reinforcedFrame:
            return [.rigid, .hinged]
        case .copperPlate:
            return [.rigid, .electrical]
        case .cogWheel, .spikedWheel, .tankTread:
            return [.axle]
        case .propellerBlade, .ornithopterWing:
            return [.axle, .hinged]
        case .springLeg:
            return [.hinged]
        case .steamBoiler, .pressureTank, .steamValve, .pneumaticTube:
            return [.rigid, .steam, .pneumatic]
        case .coalFurnace:
            return [.rigid]
        case .clockworkMotor, .windupSpring:
            return [.rigid, .chain]
        case .teslaCoil, .capacitor, .sparkGap, .electromagneticCoil, .lightningRod, .arcLamp:
            return [.electrical, .rigid]
        case .smallGear, .largeGear, .flywheel:
            return [.chain, .axle]
        case .gearBox, .crankshaft:
            return [.chain, .axle, .rigid]
        case .piston:
            return [.steam, .rigid]
        case .beltDrive:
            return [.chain]
        case .copperWire:
            return [.electrical]
        case .pressurePlate, .tripwire, .timerSwitch:
            return [.rigid, .electrical]
        case .bellows:
            return [.pneumatic, .hinged]
        case .cannon:
            return [.rigid, .steam]
        case .dynamite:
            return [.rigid]
        case .hotAirBalloon, .parachute:
            return [.rigid]
        case .grappleHook:
            return [.rigid, .chain]
        case .magneticAttractor:
            return [.magnetic, .electrical]
        case .gyroscope:
            return [.rigid]
        case .kameraMan:
            return [.rigid]
        }
    }
    
    var isPowered: Bool {
        switch self {
        case .clockworkMotor, .teslaCoil, .windupSpring, .steamBoiler, .coalFurnace:
            return true
        default:
            return false
        }
    }
    
    var requiresPower: Bool {
        switch self {
        case .cogWheel, .spikedWheel, .tankTread, .propellerBlade, .ornithopterWing,
             .arcLamp, .electromagneticCoil, .sparkGap, .cannon:
            return true
        default:
            return false
        }
    }
    
    var gridSize: (width: Int, height: Int) {
        switch self {
        case .tankTread: return (2, 1)
        case .steamBoiler, .coalFurnace: return (1, 2)
        case .hotAirBalloon: return (2, 2)
        case .ornithopterWing: return (2, 1)
        default: return (1, 1)
        }
    }
}

// MARK: - Resource Types (for simulation)
enum ResourceType: String, Codable {
    case steam
    case heat
    case electricity
    case rotation
    case pressure
    case magnetism
}

// MARK: - Part State
struct PartState: Codable {
    var steamPressure: CGFloat = 0       // 0-100
    var temperature: CGFloat = 20        // Celsius
    var electricCharge: CGFloat = 0      // 0-100
    var rotationSpeed: CGFloat = 0       // RPM
    var mechanicalEnergy: CGFloat = 0    // Stored energy
    var isTriggered: Bool = false
    var isActive: Bool = false
    var durability: CGFloat = 100        // 0-100, breaks at 0
}

// MARK: - Game Part Instance
class GamePart: Codable, Identifiable, Equatable {
    let id: UUID
    var type: PartType
    var gridPosition: GridPosition
    var rotation: Int  // 0, 90, 180, 270 degrees
    var isFlipped: Bool
    var state: PartState
    var customLabel: String?
    
    // Runtime (not encoded)
    weak var node: SKNode?
    var connections: [UUID] = []
    
    enum CodingKeys: String, CodingKey {
        case id, type, gridPosition, rotation, isFlipped, state, customLabel
    }
    
    init(type: PartType, gridPosition: GridPosition = .zero, rotation: Int = 0, isFlipped: Bool = false) {
        self.id = UUID()
        self.type = type
        self.gridPosition = gridPosition
        self.rotation = rotation
        self.isFlipped = isFlipped
        self.state = PartState()
    }
    
    static func == (lhs: GamePart, rhs: GamePart) -> Bool {
        lhs.id == rhs.id
    }
    
    func rotatedAttachmentSides() -> [AttachmentSide] {
        let steps = (rotation / 90) % 4
        return type.attachmentSides.map { side in
            AttachmentSide(rawValue: (side.rawValue + steps) % 4)!
        }
    }
    
    func canConnect(to other: GamePart, onSide side: AttachmentSide) -> Bool {
        let mySides = rotatedAttachmentSides()
        let otherSides = other.rotatedAttachmentSides()
        
        guard mySides.contains(side) else { return false }
        guard otherSides.contains(side.opposite) else { return false }
        
        // Check compatible connection types
        let myConnections = Set(type.connectionTypes)
        let otherConnections = Set(other.type.connectionTypes)
        return !myConnections.isDisjoint(with: otherConnections)
    }
    
    var worldPosition: CGPoint {
        CGPoint(x: CGFloat(gridPosition.x) * GameConstants.gridSize,
                y: CGFloat(gridPosition.y) * GameConstants.gridSize)
    }
}

// MARK: - Connection
struct PartConnection: Codable, Identifiable {
    let id: UUID
    let partA: UUID
    let partB: UUID
    let sideA: AttachmentSide
    let sideB: AttachmentSide
    let connectionType: ConnectionType
    
    init(partA: UUID, partB: UUID, sideA: AttachmentSide, connectionType: ConnectionType) {
        self.id = UUID()
        self.partA = partA
        self.partB = partB
        self.sideA = sideA
        self.sideB = sideA.opposite
        self.connectionType = connectionType
    }
}

// MARK: - Contraption (collection of connected parts)
class Contraption: Codable, Identifiable {
    let id: UUID
    var name: String
    var parts: [GamePart]
    var connections: [PartConnection]
    
    init(name: String = "New Contraption") {
        self.id = UUID()
        self.name = name
        self.parts = []
        self.connections = []
    }
    
    func part(at position: GridPosition) -> GamePart? {
        parts.first { part in
            let size = part.type.gridSize
            for dx in 0..<size.width {
                for dy in 0..<size.height {
                    if part.gridPosition.offset(dx: dx, dy: dy) == position {
                        return true
                    }
                }
            }
            return false
        }
    }
    
    func part(withID id: UUID) -> GamePart? {
        parts.first { $0.id == id }
    }
    
    func addPart(_ part: GamePart) {
        parts.append(part)
        autoConnect(part)
    }
    
    func removePart(_ part: GamePart) {
        parts.removeAll { $0.id == part.id }
        connections.removeAll { $0.partA == part.id || $0.partB == part.id }
    }
    
    private func autoConnect(_ newPart: GamePart) {
        for side in newPart.rotatedAttachmentSides() {
            let neighborPos = newPart.gridPosition.offset(
                dx: side.gridOffset.x,
                dy: side.gridOffset.y
            )
            
            if let neighbor = part(at: neighborPos),
               newPart.canConnect(to: neighbor, onSide: side) {
                let commonTypes = Set(newPart.type.connectionTypes)
                    .intersection(Set(neighbor.type.connectionTypes))
                if let connectionType = commonTypes.first {
                    let connection = PartConnection(
                        partA: newPart.id,
                        partB: neighbor.id,
                        sideA: side,
                        connectionType: connectionType
                    )
                    connections.append(connection)
                }
            }
        }
    }
    
    var hasKameraMan: Bool {
        parts.contains { $0.type == .kameraMan }
    }
    
    var centerOfMass: CGPoint {
        guard !parts.isEmpty else { return .zero }
        var totalMass: CGFloat = 0
        var weightedX: CGFloat = 0
        var weightedY: CGFloat = 0
        
        for part in parts {
            let mass = part.type.mass
            totalMass += mass
            weightedX += CGFloat(part.gridPosition.x) * mass
            weightedY += CGFloat(part.gridPosition.y) * mass
        }
        
        return CGPoint(
            x: (weightedX / totalMass) * GameConstants.gridSize,
            y: (weightedY / totalMass) * GameConstants.gridSize
        )
    }
}

// MARK: - Game Constants
enum GameConstants {
    static let gridSize: CGFloat = 64
    static let maxSteamPressure: CGFloat = 100
    static let maxTemperature: CGFloat = 500
    static let maxElectricCharge: CGFloat = 100
    static let explosionThreshold: CGFloat = 120  // Pressure above this = boom
    static let meltingPoint: CGFloat = 400
}
