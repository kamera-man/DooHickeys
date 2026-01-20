import Foundation
import SpriteKit

// MARK: - Level Definition
struct LevelData: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let difficulty: Difficulty
    let world: Int
    let levelNumber: Int
    
    // Grid setup
    let gridWidth: Int
    let gridHeight: Int
    
    // Part restrictions
    let availableParts: [PartType]
    let partLimits: [String: Int]  // PartType.rawValue : count
    let budgetPoints: Int?  // Optional point budget system
    
    // Goal
    let goalPosition: GridPosition
    let goalType: GoalType
    
    // Starting configuration
    let startingParts: [PartPlacement]
    let lockedParts: [GridPosition]  // Parts that can't be moved
    
    // Obstacles & environment
    let obstacles: [ObstacleData]
    let hazards: [HazardData]
    
    // Optional hints
    let hints: [String]
    
    // Star ratings
    let starThresholds: StarThresholds
    
    enum Difficulty: String, Codable, CaseIterable {
        case tutorial = "Tutorial"
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        case expert = "Expert"
        case insane = "Insane"
        
        var color: SKColor {
            switch self {
            case .tutorial: return .systemGreen
            case .easy: return .systemBlue
            case .medium: return .systemYellow
            case .hard: return .systemOrange
            case .expert: return .systemRed
            case .insane: return .systemPurple
            }
        }
    }
    
    enum GoalType: String, Codable {
        case reachGoal       // KameraMan reaches target
        case collectItems    // Collect all items
        case destroyTargets  // Blow up targets
        case survive         // Survive for X seconds
        case chain           // Trigger chain reaction
    }
}

struct PartPlacement: Codable {
    let type: PartType
    let position: GridPosition
    let rotation: Int
    let isLocked: Bool
    let isPrePlaced: Bool  // Part given to player vs placed by player
}

struct ObstacleData: Codable {
    let type: ObstacleType
    let position: CGPoint
    let size: CGSize
    let properties: [String: String]?
    
    enum ObstacleType: String, Codable {
        case wall
        case platform
        case movingPlatform
        case seesaw
        case ramp
        case bridge
    }
}

struct HazardData: Codable {
    let type: HazardType
    let position: CGPoint
    let size: CGSize
    
    enum HazardType: String, Codable {
        case spikes
        case fire
        case water
        case acid
        case crusher
        case electricField
    }
}

struct StarThresholds: Codable {
    let oneStar: StarCondition
    let twoStar: StarCondition
    let threeStar: StarCondition
}

struct StarCondition: Codable {
    let maxParts: Int?
    let maxTime: TimeInterval?
    let minHealth: CGFloat?
}

// MARK: - Level Manager
class LevelManager {
    static let shared = LevelManager()
    
    private(set) var levels: [LevelData] = []
    private(set) var completedLevels: Set<String> = []
    private(set) var starRatings: [String: Int] = [:]  // levelId: stars
    
    private let userDefaultsKey = "DooHickeys_Progress"
    
    private init() {
        loadBuiltInLevels()
        loadProgress()
    }
    
    // MARK: - Built-in Levels
    private func loadBuiltInLevels() {
        levels = [
            // WORLD 1: Tutorial
            createLevel_1_1(),
            createLevel_1_2(),
            createLevel_1_3(),
            
            // WORLD 2: Steam Power
            createLevel_2_1(),
            createLevel_2_2(),
            
            // WORLD 3: Gears & Motion
            createLevel_3_1(),
            createLevel_3_2(),
            
            // WORLD 4: Electricity
            createLevel_4_1(),
            
            // WORLD 5: Chain Reactions
            createLevel_5_1(),
            createLevel_5_2(),
        ]
    }
    
    // MARK: - Tutorial Levels
    
    private func createLevel_1_1() -> LevelData {
        LevelData(
            id: "1-1",
            name: "First Steps",
            description: "Help KameraMan roll to the goal! Add a wheel to get moving.",
            difficulty: .tutorial,
            world: 1,
            levelNumber: 1,
            gridWidth: 8,
            gridHeight: 6,
            availableParts: [.cogWheel, .brassFrame],
            partLimits: ["cog_wheel": 2, "brass_frame": 3],
            budgetPoints: nil,
            goalPosition: GridPosition(x: 6, y: 1),
            goalType: .reachGoal,
            startingParts: [
                PartPlacement(type: .kameraMan, position: GridPosition(x: 1, y: 2), rotation: 0, isLocked: true, isPrePlaced: true),
                PartPlacement(type: .brassFrame, position: GridPosition(x: 1, y: 1), rotation: 0, isLocked: true, isPrePlaced: true)
            ],
            lockedParts: [GridPosition(x: 1, y: 2), GridPosition(x: 1, y: 1)],
            obstacles: [
                ObstacleData(type: .ramp, position: CGPoint(x: 200, y: 100), size: CGSize(width: 150, height: 20), properties: ["angle": "10"])
            ],
            hazards: [],
            hints: [
                "Tap the Locomotion category (🔩)",
                "Select the Cog Wheel",
                "Place it under the brass frame",
                "Press ▶ to start!"
            ],
            starThresholds: StarThresholds(
                oneStar: StarCondition(maxParts: 5, maxTime: nil, minHealth: 50),
                twoStar: StarCondition(maxParts: 3, maxTime: nil, minHealth: 80),
                threeStar: StarCondition(maxParts: 2, maxTime: nil, minHealth: 100)
            )
        )
    }
    
    private func createLevel_1_2() -> LevelData {
        LevelData(
            id: "1-2",
            name: "Over the Gap",
            description: "There's a gap! Build a vehicle that can jump or fly over it.",
            difficulty: .tutorial,
            world: 1,
            levelNumber: 2,
            gridWidth: 10,
            gridHeight: 6,
            availableParts: [.cogWheel, .spikedWheel, .brassFrame, .springLeg],
            partLimits: ["cog_wheel": 2, "spiked_wheel": 2, "brass_frame": 4, "spring_leg": 2],
            budgetPoints: nil,
            goalPosition: GridPosition(x: 8, y: 1),
            goalType: .reachGoal,
            startingParts: [
                PartPlacement(type: .kameraMan, position: GridPosition(x: 1, y: 2), rotation: 0, isLocked: true, isPrePlaced: true),
                PartPlacement(type: .brassFrame, position: GridPosition(x: 1, y: 1), rotation: 0, isLocked: false, isPrePlaced: true)
            ],
            lockedParts: [GridPosition(x: 1, y: 2)],
            obstacles: [],
            hazards: [
                HazardData(type: .spikes, position: CGPoint(x: 350, y: 60), size: CGSize(width: 100, height: 40))
            ],
            hints: [
                "Spring Legs can help you jump!",
                "Or try building a wider vehicle to span the gap"
            ],
            starThresholds: StarThresholds(
                oneStar: StarCondition(maxParts: 8, maxTime: 30, minHealth: 30),
                twoStar: StarCondition(maxParts: 5, maxTime: 20, minHealth: 60),
                threeStar: StarCondition(maxParts: 3, maxTime: 15, minHealth: 100)
            )
        )
    }
    
    private func createLevel_1_3() -> LevelData {
        LevelData(
            id: "1-3",
            name: "Power Up!",
            description: "Your wheels need power! Connect a Clockwork Motor to get moving.",
            difficulty: .tutorial,
            world: 1,
            levelNumber: 3,
            gridWidth: 10,
            gridHeight: 6,
            availableParts: [.cogWheel, .brassFrame, .clockworkMotor, .smallGear, .beltDrive],
            partLimits: ["cog_wheel": 2, "brass_frame": 4, "clockwork_motor": 1, "small_gear": 2, "belt_drive": 2],
            budgetPoints: nil,
            goalPosition: GridPosition(x: 8, y: 1),
            goalType: .reachGoal,
            startingParts: [
                PartPlacement(type: .kameraMan, position: GridPosition(x: 1, y: 3), rotation: 0, isLocked: true, isPrePlaced: true),
                PartPlacement(type: .brassFrame, position: GridPosition(x: 1, y: 2), rotation: 0, isLocked: false, isPrePlaced: true),
                PartPlacement(type: .brassFrame, position: GridPosition(x: 1, y: 1), rotation: 0, isLocked: false, isPrePlaced: true)
            ],
            lockedParts: [GridPosition(x: 1, y: 3)],
            obstacles: [],
            hazards: [],
            hints: [
                "Place the Clockwork Motor on your frame",
                "Connect gears or belt drives to the wheels",
                "The motor provides rotation power!"
            ],
            starThresholds: StarThresholds(
                oneStar: StarCondition(maxParts: 10, maxTime: 45, minHealth: 50),
                twoStar: StarCondition(maxParts: 7, maxTime: 30, minHealth: 80),
                threeStar: StarCondition(maxParts: 5, maxTime: 20, minHealth: 100)
            )
        )
    }
    
    // MARK: - Steam Power Levels
    
    private func createLevel_2_1() -> LevelData {
        LevelData(
            id: "2-1",
            name: "Steam Dream",
            description: "Use steam power to push KameraMan up the hill!",
            difficulty: .easy,
            world: 2,
            levelNumber: 1,
            gridWidth: 12,
            gridHeight: 8,
            availableParts: [.cogWheel, .brassFrame, .ironFrame, .steamBoiler, .coalFurnace, .piston, .pressureTank],
            partLimits: ["cog_wheel": 2, "brass_frame": 4, "iron_frame": 2, "steam_boiler": 1, "coal_furnace": 1, "piston": 2, "pressure_tank": 1],
            budgetPoints: 100,
            goalPosition: GridPosition(x: 10, y: 5),
            goalType: .reachGoal,
            startingParts: [
                PartPlacement(type: .kameraMan, position: GridPosition(x: 1, y: 2), rotation: 0, isLocked: true, isPrePlaced: true)
            ],
            lockedParts: [GridPosition(x: 1, y: 2)],
            obstacles: [
                ObstacleData(type: .ramp, position: CGPoint(x: 400, y: 150), size: CGSize(width: 300, height: 150), properties: ["angle": "25"])
            ],
            hazards: [],
            hints: [
                "Coal Furnace heats the Steam Boiler",
                "Steam pressure powers the Piston",
                "Pistons can push wheels or create thrust!"
            ],
            starThresholds: StarThresholds(
                oneStar: StarCondition(maxParts: 12, maxTime: 60, minHealth: 30),
                twoStar: StarCondition(maxParts: 8, maxTime: 40, minHealth: 60),
                threeStar: StarCondition(maxParts: 6, maxTime: 25, minHealth: 90)
            )
        )
    }
    
    private func createLevel_2_2() -> LevelData {
        LevelData(
            id: "2-2",
            name: "Pressure Cooker",
            description: "Don't let the pressure build too high or BOOM! 💥",
            difficulty: .medium,
            world: 2,
            levelNumber: 2,
            gridWidth: 12,
            gridHeight: 8,
            availableParts: [.cogWheel, .brassFrame, .reinforcedFrame, .steamBoiler, .coalFurnace, .steamValve, .pressureTank, .piston],
            partLimits: ["cog_wheel": 2, "brass_frame": 3, "reinforced_frame": 2, "steam_boiler": 1, "coal_furnace": 1, "steam_valve": 2, "pressure_tank": 1, "piston": 2],
            budgetPoints: 120,
            goalPosition: GridPosition(x: 10, y: 1),
            goalType: .reachGoal,
            startingParts: [
                PartPlacement(type: .kameraMan, position: GridPosition(x: 1, y: 2), rotation: 0, isLocked: true, isPrePlaced: true)
            ],
            lockedParts: [GridPosition(x: 1, y: 2)],
            obstacles: [],
            hazards: [],
            hints: [
                "Steam Valves release excess pressure",
                "Watch the pressure gauge on the boiler!",
                "Reinforced frames survive explosions"
            ],
            starThresholds: StarThresholds(
                oneStar: StarCondition(maxParts: 14, maxTime: 60, minHealth: 20),
                twoStar: StarCondition(maxParts: 10, maxTime: 45, minHealth: 50),
                threeStar: StarCondition(maxParts: 7, maxTime: 30, minHealth: 80)
            )
        )
    }
    
    // MARK: - Gear Levels
    
    private func createLevel_3_1() -> LevelData {
        LevelData(
            id: "3-1",
            name: "Gear Ratio",
            description: "Use gears to trade speed for power (or vice versa)!",
            difficulty: .easy,
            world: 3,
            levelNumber: 1,
            gridWidth: 12,
            gridHeight: 8,
            availableParts: [.cogWheel, .spikedWheel, .brassFrame, .clockworkMotor, .smallGear, .largeGear, .gearBox, .beltDrive],
            partLimits: ["cog_wheel": 2, "spiked_wheel": 2, "brass_frame": 4, "clockwork_motor": 1, "small_gear": 3, "large_gear": 3, "gear_box": 1, "belt_drive": 2],
            budgetPoints: 100,
            goalPosition: GridPosition(x: 10, y: 1),
            goalType: .reachGoal,
            startingParts: [
                PartPlacement(type: .kameraMan, position: GridPosition(x: 1, y: 2), rotation: 0, isLocked: true, isPrePlaced: true)
            ],
            lockedParts: [GridPosition(x: 1, y: 2)],
            obstacles: [
                ObstacleData(type: .ramp, position: CGPoint(x: 500, y: 100), size: CGSize(width: 200, height: 100), properties: ["angle": "30"])
            ],
            hazards: [],
            hints: [
                "Small gear → Large gear = More torque, less speed",
                "Large gear → Small gear = More speed, less torque",
                "You need torque to climb hills!"
            ],
            starThresholds: StarThresholds(
                oneStar: StarCondition(maxParts: 12, maxTime: 45, minHealth: 50),
                twoStar: StarCondition(maxParts: 8, maxTime: 30, minHealth: 70),
                threeStar: StarCondition(maxParts: 6, maxTime: 20, minHealth: 100)
            )
        )
    }
    
    private func createLevel_3_2() -> LevelData {
        LevelData(
            id: "3-2",
            name: "Flywheel Frenzy",
            description: "Store energy in the flywheel to coast through!",
            difficulty: .medium,
            world: 3,
            levelNumber: 2,
            gridWidth: 14,
            gridHeight: 8,
            availableParts: [.cogWheel, .brassFrame, .clockworkMotor, .windupSpring, .smallGear, .largeGear, .flywheel, .beltDrive],
            partLimits: ["cog_wheel": 2, "brass_frame": 5, "clockwork_motor": 1, "windup_spring": 1, "small_gear": 2, "large_gear": 2, "flywheel": 2, "belt_drive": 2],
            budgetPoints: 110,
            goalPosition: GridPosition(x: 12, y: 1),
            goalType: .reachGoal,
            startingParts: [
                PartPlacement(type: .kameraMan, position: GridPosition(x: 1, y: 2), rotation: 0, isLocked: true, isPrePlaced: true)
            ],
            lockedParts: [GridPosition(x: 1, y: 2)],
            obstacles: [],
            hazards: [
                HazardData(type: .spikes, position: CGPoint(x: 400, y: 60), size: CGSize(width: 60, height: 40)),
                HazardData(type: .spikes, position: CGPoint(x: 600, y: 60), size: CGSize(width: 60, height: 40))
            ],
            hints: [
                "Flywheels store rotational energy",
                "Build up speed before the gaps!",
                "Momentum is your friend"
            ],
            starThresholds: StarThresholds(
                oneStar: StarCondition(maxParts: 14, maxTime: 60, minHealth: 30),
                twoStar: StarCondition(maxParts: 10, maxTime: 40, minHealth: 60),
                threeStar: StarCondition(maxParts: 7, maxTime: 25, minHealth: 90)
            )
        )
    }
    
    // MARK: - Electrical Levels
    
    private func createLevel_4_1() -> LevelData {
        LevelData(
            id: "4-1",
            name: "Shock Therapy",
            description: "Use electricity to power your contraption!",
            difficulty: .medium,
            world: 4,
            levelNumber: 1,
            gridWidth: 12,
            gridHeight: 8,
            availableParts: [.cogWheel, .brassFrame, .copperPlate, .teslaCoil, .copperWire, .capacitor, .electromagneticCoil, .arcLamp],
            partLimits: ["cog_wheel": 2, "brass_frame": 4, "copper_plate": 3, "tesla_coil": 1, "copper_wire": 4, "capacitor": 2, "em_coil": 1, "arc_lamp": 1],
            budgetPoints: 130,
            goalPosition: GridPosition(x: 10, y: 1),
            goalType: .reachGoal,
            startingParts: [
                PartPlacement(type: .kameraMan, position: GridPosition(x: 1, y: 2), rotation: 0, isLocked: true, isPrePlaced: true)
            ],
            lockedParts: [GridPosition(x: 1, y: 2)],
            obstacles: [],
            hazards: [],
            hints: [
                "Tesla Coils generate electricity",
                "Copper wires and plates conduct it",
                "Electromagnetic coils create magnetic force!"
            ],
            starThresholds: StarThresholds(
                oneStar: StarCondition(maxParts: 14, maxTime: 60, minHealth: 40),
                twoStar: StarCondition(maxParts: 10, maxTime: 45, minHealth: 65),
                threeStar: StarCondition(maxParts: 7, maxTime: 30, minHealth: 90)
            )
        )
    }
    
    // MARK: - Chain Reaction Levels
    
    private func createLevel_5_1() -> LevelData {
        LevelData(
            id: "5-1",
            name: "Rube Goldberg",
            description: "Set up a chain reaction to launch KameraMan to the goal!",
            difficulty: .hard,
            world: 5,
            levelNumber: 1,
            gridWidth: 14,
            gridHeight: 10,
            availableParts: [.brassFrame, .pressurePlate, .tripwire, .timerSwitch, .steamValve, .bellows, .cannon, .dynamite, .cogWheel],
            partLimits: ["brass_frame": 4, "pressure_plate": 2, "tripwire": 2, "timer_switch": 2, "steam_valve": 2, "bellows": 2, "cannon": 1, "dynamite": 3, "cog_wheel": 2],
            budgetPoints: 150,
            goalPosition: GridPosition(x: 12, y: 8),
            goalType: .reachGoal,
            startingParts: [
                PartPlacement(type: .kameraMan, position: GridPosition(x: 1, y: 2), rotation: 0, isLocked: true, isPrePlaced: true),
                PartPlacement(type: .cannon, position: GridPosition(x: 3, y: 1), rotation: 45, isLocked: true, isPrePlaced: true)
            ],
            lockedParts: [GridPosition(x: 1, y: 2), GridPosition(x: 3, y: 1)],
            obstacles: [
                ObstacleData(type: .platform, position: CGPoint(x: 700, y: 400), size: CGSize(width: 100, height: 20), properties: nil)
            ],
            hazards: [],
            hints: [
                "Trigger → Timer → Valve → Cannon!",
                "Chain your triggers together",
                "Timing is everything!"
            ],
            starThresholds: StarThresholds(
                oneStar: StarCondition(maxParts: 16, maxTime: 90, minHealth: 20),
                twoStar: StarCondition(maxParts: 12, maxTime: 60, minHealth: 50),
                threeStar: StarCondition(maxParts: 8, maxTime: 40, minHealth: 80)
            )
        )
    }
    
    private func createLevel_5_2() -> LevelData {
        LevelData(
            id: "5-2",
            name: "Explosive Finale",
            description: "Use controlled explosions to clear the path!",
            difficulty: .hard,
            world: 5,
            levelNumber: 2,
            gridWidth: 14,
            gridHeight: 10,
            availableParts: [.brassFrame, .reinforcedFrame, .cogWheel, .timerSwitch, .dynamite, .pressurePlate, .steamBoiler, .coalFurnace],
            partLimits: ["brass_frame": 3, "reinforced_frame": 3, "cog_wheel": 2, "timer_switch": 3, "dynamite": 5, "pressure_plate": 2, "steam_boiler": 1, "coal_furnace": 1],
            budgetPoints: 180,
            goalPosition: GridPosition(x: 12, y: 1),
            goalType: .reachGoal,
            startingParts: [
                PartPlacement(type: .kameraMan, position: GridPosition(x: 1, y: 2), rotation: 0, isLocked: true, isPrePlaced: true)
            ],
            lockedParts: [GridPosition(x: 1, y: 2)],
            obstacles: [
                ObstacleData(type: .wall, position: CGPoint(x: 350, y: 200), size: CGSize(width: 40, height: 300), properties: nil),
                ObstacleData(type: .wall, position: CGPoint(x: 550, y: 200), size: CGSize(width: 40, height: 300), properties: nil),
                ObstacleData(type: .wall, position: CGPoint(x: 750, y: 200), size: CGSize(width: 40, height: 300), properties: nil)
            ],
            hazards: [],
            hints: [
                "Dynamite destroys walls!",
                "Use reinforced frames to protect KameraMan",
                "Time your explosions carefully"
            ],
            starThresholds: StarThresholds(
                oneStar: StarCondition(maxParts: 18, maxTime: 120, minHealth: 10),
                twoStar: StarCondition(maxParts: 14, maxTime: 90, minHealth: 40),
                threeStar: StarCondition(maxParts: 10, maxTime: 60, minHealth: 70)
            )
        )
    }
    
    // MARK: - Progress Management
    
    func completeLevel(_ levelId: String, stars: Int) {
        completedLevels.insert(levelId)
        if let existingStars = starRatings[levelId] {
            starRatings[levelId] = max(existingStars, stars)
        } else {
            starRatings[levelId] = stars
        }
        saveProgress()
    }
    
    func isLevelUnlocked(_ levelId: String) -> Bool {
        guard let level = levels.first(where: { $0.id == levelId }) else { return false }
        
        // First level of each world is unlocked if previous world is complete
        if level.levelNumber == 1 {
            if level.world == 1 { return true }
            let previousWorldLevels = levels.filter { $0.world == level.world - 1 }
            return previousWorldLevels.allSatisfy { completedLevels.contains($0.id) }
        }
        
        // Otherwise, previous level must be complete
        let previousLevelId = "\(level.world)-\(level.levelNumber - 1)"
        return completedLevels.contains(previousLevelId)
    }
    
    func totalStars() -> Int {
        starRatings.values.reduce(0, +)
    }
    
    private func saveProgress() {
        let progress = LevelProgress(completed: Array(completedLevels), stars: starRatings)
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    private func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let progress = try? JSONDecoder().decode(LevelProgress.self, from: data) else { return }
        completedLevels = Set(progress.completed)
        starRatings = progress.stars
    }
}

struct LevelProgress: Codable {
    let completed: [String]
    let stars: [String: Int]
}

// MARK: - Level Scene Extension
extension GameScene {
    func loadLevel(_ levelData: LevelData) {
        // Clear existing
        contraption.parts.forEach { $0.node?.removeFromParent() }
        contraption = Contraption(name: levelData.name)
        
        // Set grid size
        gridWidth = levelData.gridWidth
        gridHeight = levelData.gridHeight
        
        // Place starting parts
        for placement in levelData.startingParts {
            let part = GamePart(type: placement.type, gridPosition: placement.position, rotation: placement.rotation)
            contraption.addPart(part)
            
            let node = PartRenderer.shared.createNode(for: part)
            if placement.isLocked {
                // Visual indicator for locked parts
                let lock = SKSpriteNode(imageNamed: "lock_icon")
                lock.setScale(0.3)
                lock.position = CGPoint(x: 20, y: 20)
                lock.zPosition = 10
                node.addChild(lock)
            }
            contraptionLayer.addChild(node)
        }
        
        // Create goal marker
        createGoalMarker(at: levelData.goalPosition)
        
        // Create obstacles
        for obstacle in levelData.obstacles {
            createObstacle(obstacle)
        }
        
        // Create hazards
        for hazard in levelData.hazards {
            createHazard(hazard)
        }
        
        // Update status
        statusLabel.text = levelData.name.uppercased()
    }
    
    private func createGoalMarker(at position: GridPosition) {
        let goalNode = SKNode()
        goalNode.name = "goal"
        
        // Glowing circle
        let glow = SKShapeNode(circleOfRadius: gridSize * 0.6)
        glow.fillColor = SteampunkColors.success.withAlphaComponent(0.3)
        glow.strokeColor = SteampunkColors.success
        glow.lineWidth = 3
        glow.glowWidth = 10
        goalNode.addChild(glow)
        
        // Star icon
        let star = SKLabelNode(text: "⭐")
        star.fontSize = 32
        star.verticalAlignmentMode = .center
        goalNode.addChild(star)
        
        // Pulse animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        goalNode.run(SKAction.repeatForever(pulse))
        
        // Physics
        let body = SKPhysicsBody(circleOfRadius: gridSize * 0.5)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.goal
        body.contactTestBitMask = PhysicsCategory.contraption
        goalNode.physicsBody = body
        
        goalNode.position = CGPoint(
            x: CGFloat(position.x) * gridSize,
            y: CGFloat(position.y) * gridSize
        )
        contraptionLayer.addChild(goalNode)
    }
    
    private func createObstacle(_ data: ObstacleData) {
        let obstacle: SKShapeNode
        
        switch data.type {
        case .wall:
            obstacle = SKShapeNode(rectOf: data.size)
            obstacle.fillColor = SteampunkColors.iron
            obstacle.strokeColor = SteampunkColors.ironLight
            
        case .platform:
            obstacle = SKShapeNode(rectOf: data.size, cornerRadius: 4)
            obstacle.fillColor = SteampunkColors.wood
            obstacle.strokeColor = SteampunkColors.woodDark
            
        case .ramp:
            let angle = CGFloat(Double(data.properties?["angle"] ?? "20") ?? 20) * .pi / 180
            obstacle = SKShapeNode(rectOf: data.size)
            obstacle.fillColor = SteampunkColors.iron
            obstacle.strokeColor = SteampunkColors.ironLight
            obstacle.zRotation = angle
            
        case .movingPlatform:
            obstacle = SKShapeNode(rectOf: data.size, cornerRadius: 4)
            obstacle.fillColor = SteampunkColors.brass
            obstacle.strokeColor = SteampunkColors.brassLight
            // Add movement animation
            let moveRight = SKAction.moveBy(x: 100, y: 0, duration: 2)
            let moveLeft = SKAction.moveBy(x: -100, y: 0, duration: 2)
            obstacle.run(SKAction.repeatForever(SKAction.sequence([moveRight, moveLeft])))
            
        case .seesaw:
            obstacle = SKShapeNode(rectOf: data.size, cornerRadius: 4)
            obstacle.fillColor = SteampunkColors.wood
            obstacle.strokeColor = SteampunkColors.woodDark
            // Physics joint would be added here
            
        case .bridge:
            obstacle = SKShapeNode(rectOf: data.size)
            obstacle.fillColor = SteampunkColors.woodDark
            obstacle.strokeColor = SteampunkColors.wood
        }
        
        obstacle.lineWidth = 2
        obstacle.position = data.position
        
        let body = SKPhysicsBody(rectangleOf: data.size)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.ground
        body.friction = 0.8
        obstacle.physicsBody = body
        
        environmentLayer.addChild(obstacle)
    }
    
    private func createHazard(_ data: HazardData) {
        let hazard = SKNode()
        hazard.name = "hazard_\(data.type.rawValue)"
        
        switch data.type {
        case .spikes:
            let spikeCount = Int(data.size.width / 15)
            for i in 0..<spikeCount {
                let spike = createSpike()
                spike.position = CGPoint(x: CGFloat(i) * 15 - data.size.width/2 + 7.5, y: 0)
                hazard.addChild(spike)
            }
            
        case .fire:
            let fireEmitter = createFireEmitter(size: data.size)
            hazard.addChild(fireEmitter)
            
        case .water:
            let water = SKShapeNode(rectOf: data.size)
            water.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 0.6)
            water.strokeColor = SKColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 0.8)
            hazard.addChild(water)
            
        case .acid:
            let acid = SKShapeNode(rectOf: data.size)
            acid.fillColor = SKColor(red: 0.4, green: 0.8, blue: 0.2, alpha: 0.6)
            acid.strokeColor = SKColor(red: 0.5, green: 0.9, blue: 0.3, alpha: 0.8)
            hazard.addChild(acid)
            
        case .crusher:
            let crusher = SKShapeNode(rectOf: data.size)
            crusher.fillColor = SteampunkColors.ironDark
            crusher.strokeColor = SteampunkColors.iron
            hazard.addChild(crusher)
            // Crushing animation
            let down = SKAction.moveBy(x: 0, y: -data.size.height, duration: 0.3)
            let wait = SKAction.wait(forDuration: 1)
            let up = SKAction.moveBy(x: 0, y: data.size.height, duration: 1)
            crusher.run(SKAction.repeatForever(SKAction.sequence([wait, down, wait, up])))
            
        case .electricField:
            let field = SKShapeNode(rectOf: data.size)
            field.fillColor = SteampunkColors.electricity.withAlphaComponent(0.3)
            field.strokeColor = SteampunkColors.electricityBright
            field.glowWidth = 5
            hazard.addChild(field)
        }
        
        hazard.position = data.position
        
        let body = SKPhysicsBody(rectangleOf: data.size)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.hazard
        body.contactTestBitMask = PhysicsCategory.contraption
        hazard.physicsBody = body
        
        environmentLayer.addChild(hazard)
    }
    
    private func createSpike() -> SKNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -6, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 20))
        path.addLine(to: CGPoint(x: 6, y: 0))
        path.closeSubpath()
        
        let spike = SKShapeNode(path: path)
        spike.fillColor = SteampunkColors.ironLight
        spike.strokeColor = SteampunkColors.iron
        spike.lineWidth = 1
        return spike
    }
    
    private func createFireEmitter(size: CGSize) -> SKNode {
        let container = SKNode()
        
        // Animated fire shapes
        let fireCount = Int(size.width / 20)
        for i in 0..<fireCount {
            let fire = SKShapeNode(ellipseOf: CGSize(width: 15, height: 25))
            fire.fillColor = SteampunkColors.fire
            fire.strokeColor = .clear
            fire.position = CGPoint(x: CGFloat(i) * 20 - size.width/2 + 10, y: 5)
            
            let flicker = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.7, duration: 0.1),
                SKAction.fadeAlpha(to: 1.0, duration: 0.1),
                SKAction.scaleY(to: 1.2, duration: 0.15),
                SKAction.scaleY(to: 0.8, duration: 0.15)
            ])
            fire.run(SKAction.repeatForever(flicker))
            container.addChild(fire)
        }
        
        return container
    }
}
