import SpriteKit
import GameplayKit

// MARK: - Game State
enum GameState {
    case building
    case simulating
    case victory
    case failure
}

// MARK: - Main Game Scene
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    var gameState: GameState = .building {
        didSet { updateUIForState() }
    }
    
    var contraption = Contraption(name: "My DooHickey")
    var simulationEngine: SimulationEngine!
    var level: LevelData?
    
    // Layers
    private var backgroundLayer: SKNode!
    private var gridLayer: SKNode!
    var contraptionLayer: SKNode!
    var environmentLayer: SKNode!
    private var uiLayer: SKNode!
    private var effectsLayer: SKNode!
    
    // Building
    private var selectedPartType: PartType?
    private var ghostPart: SKNode?
    private var isDraggingPart: GamePart?
    private var buildAreaRect: CGRect = .zero
    
    // UI Elements
    private var toolboxNode: SKNode!
    private var playButton: SKNode!
    private var resetButton: SKNode!
    private var categoryButtons: [SKNode] = []
    private var partButtons: [SKNode] = []
    var statusLabel: SKLabelNode!
    private var kameraManHealthBar: SKNode?
    
    // Grid
    let gridSize = GameConstants.gridSize
    var gridWidth = 12
    var gridHeight = 8
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        backgroundColor = SteampunkColors.background
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        
        setupLayers()
        setupBackground()
        setupGrid()
        setupUI()
        setupEnvironment()
        
        simulationEngine = SimulationEngine(contraption: contraption)
        setupSimulationCallbacks()
        
        // Load level or start sandbox
        if level == nil {
            setupSandboxMode()
        }
    }
    
    private func setupLayers() {
        backgroundLayer = SKNode()
        backgroundLayer.zPosition = -100
        addChild(backgroundLayer)
        
        gridLayer = SKNode()
        gridLayer.zPosition = 0
        addChild(gridLayer)
        
        environmentLayer = SKNode()
        environmentLayer.zPosition = 10
        addChild(environmentLayer)
        
        contraptionLayer = SKNode()
        contraptionLayer.zPosition = 50
        addChild(contraptionLayer)
        
        effectsLayer = SKNode()
        effectsLayer.zPosition = 100
        addChild(effectsLayer)
        
        uiLayer = SKNode()
        uiLayer.zPosition = 200
        addChild(uiLayer)
    }
    
    // MARK: - Background
    private func setupBackground() {
        // Victorian wallpaper pattern
        let patternSize: CGFloat = 80
        let cols = Int(size.width / patternSize) + 2
        let rows = Int(size.height / patternSize) + 2
        
        for row in 0..<rows {
            for col in 0..<cols {
                let x = CGFloat(col) * patternSize
                let y = CGFloat(row) * patternSize
                
                // Alternating diamond pattern
                let isDark = (row + col) % 2 == 0
                let color = isDark ? SteampunkColors.background : SteampunkColors.backgroundLight
                
                let tile = SKShapeNode(rectOf: CGSize(width: patternSize, height: patternSize))
                tile.fillColor = color
                tile.strokeColor = .clear
                tile.position = CGPoint(x: x, y: y)
                backgroundLayer.addChild(tile)
                
                // Decorative gear watermark
                if (row + col) % 4 == 0 {
                    let watermark = createGearWatermark(size: patternSize * 0.6)
                    watermark.position = CGPoint(x: x, y: y)
                    watermark.alpha = 0.1
                    backgroundLayer.addChild(watermark)
                }
            }
        }
    }
    
    private func createGearWatermark(size: CGFloat) -> SKNode {
        let path = CGMutablePath()
        let teeth = 8
        let innerRadius = size * 0.35
        let outerRadius = size * 0.5
        
        for i in 0..<teeth {
            let angle = CGFloat(i) * .pi * 2 / CGFloat(teeth)
            let toothAngle = .pi * 2 / CGFloat(teeth * 2)
            
            if i == 0 {
                path.move(to: CGPoint(x: cos(angle) * innerRadius, y: sin(angle) * innerRadius))
            }
            
            path.addLine(to: CGPoint(x: cos(angle + toothAngle * 0.3) * outerRadius,
                                     y: sin(angle + toothAngle * 0.3) * outerRadius))
            path.addLine(to: CGPoint(x: cos(angle + toothAngle * 0.7) * outerRadius,
                                     y: sin(angle + toothAngle * 0.7) * outerRadius))
            path.addLine(to: CGPoint(x: cos(angle + toothAngle * 2) * innerRadius,
                                     y: sin(angle + toothAngle * 2) * innerRadius))
        }
        path.closeSubpath()
        
        let gear = SKShapeNode(path: path)
        gear.fillColor = SteampunkColors.brass
        gear.strokeColor = .clear
        return gear
    }
    
    // MARK: - Grid Setup
    private func setupGrid() {
        let totalWidth = CGFloat(gridWidth) * gridSize
        let totalHeight = CGFloat(gridHeight) * gridSize
        let startX = (size.width - totalWidth) / 2
        let startY: CGFloat = 120  // Above UI
        
        buildAreaRect = CGRect(x: startX, y: startY, width: totalWidth, height: totalHeight)
        
        // Grid background
        let gridBg = SKShapeNode(rectOf: CGSize(width: totalWidth + 20, height: totalHeight + 20), cornerRadius: 8)
        gridBg.fillColor = SteampunkColors.background.withAlphaComponent(0.8)
        gridBg.strokeColor = SteampunkColors.brass
        gridBg.lineWidth = 3
        gridBg.position = CGPoint(x: startX + totalWidth/2, y: startY + totalHeight/2)
        gridLayer.addChild(gridBg)
        
        // Grid lines
        for col in 0...gridWidth {
            let x = startX + CGFloat(col) * gridSize
            let line = SKShapeNode(rectOf: CGSize(width: 1, height: totalHeight))
            line.fillColor = SteampunkColors.grid
            line.strokeColor = .clear
            line.position = CGPoint(x: x, y: startY + totalHeight/2)
            gridLayer.addChild(line)
        }
        
        for row in 0...gridHeight {
            let y = startY + CGFloat(row) * gridSize
            let line = SKShapeNode(rectOf: CGSize(width: totalWidth, height: 1))
            line.fillColor = SteampunkColors.grid
            line.strokeColor = .clear
            line.position = CGPoint(x: startX + totalWidth/2, y: y)
            gridLayer.addChild(line)
        }
        
        // Position contraption layer
        contraptionLayer.position = CGPoint(x: startX + gridSize/2, y: startY + gridSize/2)
    }
    
    // MARK: - Environment Setup
    private func setupEnvironment() {
        // Ground
        let groundHeight: CGFloat = 120
        let ground = SKShapeNode(rectOf: CGSize(width: size.width, height: groundHeight))
        ground.fillColor = SteampunkColors.woodDark
        ground.strokeColor = SteampunkColors.wood
        ground.lineWidth = 3
        ground.position = CGPoint(x: size.width/2, y: groundHeight/2)
        environmentLayer.addChild(ground)
        
        // Ground physics
        let groundBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: groundHeight))
        groundBody.isDynamic = false
        groundBody.categoryBitMask = PhysicsCategory.ground
        groundBody.friction = 0.8
        ground.physicsBody = groundBody
        
        // Metal floor plates
        for x in stride(from: 40, to: size.width - 40, by: 80) {
            let plate = SKShapeNode(rectOf: CGSize(width: 70, height: 8), cornerRadius: 2)
            plate.fillColor = SteampunkColors.iron
            plate.strokeColor = SteampunkColors.ironLight
            plate.position = CGPoint(x: x, y: groundHeight - 4)
            environmentLayer.addChild(plate)
        }
        
        // Decorative pipes along top
        let pipeY = size.height - 30
        let pipe = SKShapeNode(rectOf: CGSize(width: size.width, height: 20))
        pipe.fillColor = SteampunkColors.copper
        pipe.strokeColor = SteampunkColors.copperLight
        pipe.lineWidth = 2
        pipe.position = CGPoint(x: size.width/2, y: pipeY)
        environmentLayer.addChild(pipe)
        
        // Pipe joints
        for x in stride(from: 100, to: size.width, by: 200) {
            let joint = SKShapeNode(circleOfRadius: 18)
            joint.fillColor = SteampunkColors.brass
            joint.strokeColor = SteampunkColors.brassLight
            joint.lineWidth = 2
            joint.position = CGPoint(x: x, y: pipeY)
            environmentLayer.addChild(joint)
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupToolbox()
        setupControlButtons()
        setupStatusDisplay()
    }
    
    private func setupToolbox() {
        toolboxNode = SKNode()
        toolboxNode.position = CGPoint(x: 10, y: size.height/2)
        uiLayer.addChild(toolboxNode)
        
        // Category tabs
        let categories = PartCategory.allCases
        var yOffset: CGFloat = CGFloat(categories.count) * 50 / 2
        
        for (index, category) in categories.enumerated() {
            let button = createCategoryButton(category: category, index: index)
            button.position = CGPoint(x: 35, y: yOffset)
            button.name = "category_\(category.rawValue)"
            toolboxNode.addChild(button)
            categoryButtons.append(button)
            yOffset -= 55
        }
        
        // Select first category
        selectCategory(.structural)
    }
    
    private func createCategoryButton(category: PartCategory, index: Int) -> SKNode {
        let node = SKNode()
        
        let bg = SKShapeNode(rectOf: CGSize(width: 60, height: 50), cornerRadius: 8)
        bg.fillColor = SteampunkColors.brass
        bg.strokeColor = SteampunkColors.brassLight
        bg.lineWidth = 2
        bg.name = "bg"
        node.addChild(bg)
        
        let icon = SKLabelNode(text: category.icon)
        icon.fontSize = 24
        icon.verticalAlignmentMode = .center
        icon.position = CGPoint(x: 0, y: 4)
        node.addChild(icon)
        
        let label = SKLabelNode(text: String(category.rawValue.prefix(4)))
        label.fontName = "Menlo-Bold"
        label.fontSize = 9
        label.fontColor = SteampunkColors.background
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -14)
        node.addChild(label)
        
        return node
    }
    
    private func selectCategory(_ category: PartCategory) {
        // Update button states
        for button in categoryButtons {
            if let bg = button.childNode(withName: "bg") as? SKShapeNode {
                let isSelected = button.name == "category_\(category.rawValue)"
                bg.fillColor = isSelected ? SteampunkColors.copper : SteampunkColors.brass
            }
        }
        
        // Clear existing part buttons
        for button in partButtons {
            button.removeFromParent()
        }
        partButtons.removeAll()
        
        // Add parts for this category
        let parts = PartType.allCases.filter { $0.category == category }
        let startX: CGFloat = 90
        var x = startX
        var y: CGFloat = CGFloat(parts.count) * 35 / 2
        
        for part in parts {
            let button = createPartButton(partType: part)
            button.position = CGPoint(x: x, y: y)
            button.name = "part_\(part.rawValue)"
            toolboxNode.addChild(button)
            partButtons.append(button)
            y -= 70
            
            if y < -CGFloat(parts.count) * 35 / 2 {
                y = CGFloat(parts.count) * 35 / 2
                x += 75
            }
        }
    }
    
    private func createPartButton(partType: PartType) -> SKNode {
        let node = SKNode()
        
        let bg = SKShapeNode(rectOf: CGSize(width: 65, height: 65), cornerRadius: 8)
        bg.fillColor = SteampunkColors.iron
        bg.strokeColor = SteampunkColors.ironLight
        bg.lineWidth = 2
        bg.name = "bg"
        node.addChild(bg)
        
        // Mini version of the part
        let renderer = PartRenderer.shared
        let tempPart = GamePart(type: partType)
        let visual = renderer.createNode(for: tempPart)
        visual.setScale(0.5)
        visual.physicsBody = nil  // Remove physics for preview
        node.addChild(visual)
        
        return node
    }
    
    private func setupControlButtons() {
        let buttonY: CGFloat = 60
        
        // Play button
        playButton = createControlButton(icon: "▶", color: SteampunkColors.success)
        playButton.position = CGPoint(x: size.width - 150, y: buttonY)
        playButton.name = "playButton"
        uiLayer.addChild(playButton)
        
        // Reset button
        resetButton = createControlButton(icon: "↺", color: SteampunkColors.copper)
        resetButton.position = CGPoint(x: size.width - 80, y: buttonY)
        resetButton.name = "resetButton"
        uiLayer.addChild(resetButton)
    }
    
    private func createControlButton(icon: String, color: SKColor) -> SKNode {
        let node = SKNode()
        
        let bg = SKShapeNode(circleOfRadius: 30)
        bg.fillColor = color
        bg.strokeColor = color.lighter(by: 0.2)
        bg.lineWidth = 3
        node.addChild(bg)
        
        let label = SKLabelNode(text: icon)
        label.fontSize = 28
        label.fontName = "Menlo-Bold"
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        node.addChild(label)
        
        return node
    }
    
    private func setupStatusDisplay() {
        statusLabel = SKLabelNode(text: "BUILD YOUR DOOHICKEY!")
        statusLabel.fontName = "Menlo-Bold"
        statusLabel.fontSize = 18
        statusLabel.fontColor = SteampunkColors.brassLight
        statusLabel.position = CGPoint(x: size.width/2, y: size.height - 50)
        uiLayer.addChild(statusLabel)
    }
    
    // MARK: - Sandbox Mode
    private func setupSandboxMode() {
        statusLabel.text = "SANDBOX MODE - Build anything!"
        
        // Add a starting KameraMan
        let kameraMan = GamePart(type: .kameraMan, gridPosition: GridPosition(x: 5, y: 1))
        contraption.addPart(kameraMan)
        
        let node = PartRenderer.shared.createNode(for: kameraMan)
        contraptionLayer.addChild(node)
    }
    
    // MARK: - Simulation Callbacks
    private func setupSimulationCallbacks() {
        simulationEngine.onExplosion = { [weak self] position in
            self?.createExplosionEffect(at: position)
        }
        
        simulationEngine.onElectricalArc = { [weak self] start, end in
            self?.createElectricalArc(from: start, to: end)
        }
        
        simulationEngine.onSteamRelease = { [weak self] position, direction in
            self?.createSteamEffect(at: position, direction: direction)
        }
        
        simulationEngine.onKameraManDamaged = { [weak self] health in
            self?.updateKameraManHealth(health)
        }
        
        simulationEngine.onKameraManDestroyed = { [weak self] in
            self?.gameState = .failure
        }
        
        simulationEngine.onPartStateChanged = { [weak self] part in
            self?.updatePartVisuals(part)
        }
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check UI interactions
        if handleUITouch(at: location) {
            return
        }
        
        // Building mode interactions
        if gameState == .building {
            handleBuildingTouch(at: location)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if gameState == .building {
            if isDraggingPart != nil {
                // Move existing part
                let gridPos = screenToGrid(location)
                updateGhostPosition(to: gridPos)
            } else if ghostPart != nil {
                // Move ghost for new part
                let gridPos = screenToGrid(location)
                updateGhostPosition(to: gridPos)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if gameState == .building {
            if let dragging = isDraggingPart {
                // Finish moving part
                let gridPos = screenToGrid(location)
                if isValidPlacement(for: dragging.type, at: gridPos) {
                    dragging.gridPosition = gridPos
                    dragging.node?.position = gridToScreen(gridPos)
                }
                isDraggingPart = nil
            } else if let partType = selectedPartType {
                // Place new part
                let gridPos = screenToGrid(location)
                if isValidPlacement(for: partType, at: gridPos) {
                    placePart(type: partType, at: gridPos)
                }
            }
            
            clearGhost()
        }
    }
    
    private func handleUITouch(at location: CGPoint) -> Bool {
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            guard let name = node.name ?? node.parent?.name else { continue }
            
            // Category buttons
            if name.hasPrefix("category_") {
                let categoryName = String(name.dropFirst(9))
                if let category = PartCategory(rawValue: categoryName) {
                    selectCategory(category)
                    return true
                }
            }
            
            // Part buttons
            if name.hasPrefix("part_") {
                let partName = String(name.dropFirst(5))
                if let partType = PartType(rawValue: partName) {
                    selectedPartType = partType
                    highlightPartButton(named: name)
                    return true
                }
            }
            
            // Control buttons
            if name == "playButton" {
                toggleSimulation()
                return true
            }
            
            if name == "resetButton" {
                resetContraption()
                return true
            }
        }
        
        return false
    }
    
    private func handleBuildingTouch(at location: CGPoint) {
        _ = convert(location, to: contraptionLayer)
        
        // Check if touching existing part
        for part in contraption.parts {
            if let node = part.node {
                let localPos = convert(location, to: node)
                if node.contains(localPos) {
                    // Start dragging
                    isDraggingPart = part
                    createGhost(for: part.type, at: part.gridPosition)
                    return
                }
            }
        }
        
        // Create ghost for new part
        if let partType = selectedPartType {
            let gridPos = screenToGrid(location)
            createGhost(for: partType, at: gridPos)
        }
    }
    
    private func highlightPartButton(named name: String) {
        for button in partButtons {
            if let bg = button.childNode(withName: "bg") as? SKShapeNode {
                let isSelected = button.name == name
                bg.strokeColor = isSelected ? SteampunkColors.electricity : SteampunkColors.ironLight
                bg.lineWidth = isSelected ? 4 : 2
            }
        }
    }
    
    // MARK: - Grid Helpers
    private func screenToGrid(_ point: CGPoint) -> GridPosition {
        let localPoint = convert(point, to: contraptionLayer)
        let x = Int(floor(localPoint.x / gridSize))
        let y = Int(floor(localPoint.y / gridSize))
        return GridPosition(x: x, y: y)
    }
    
    private func gridToScreen(_ pos: GridPosition) -> CGPoint {
        CGPoint(x: CGFloat(pos.x) * gridSize, y: CGFloat(pos.y) * gridSize)
    }
    
    private func isValidPlacement(for partType: PartType, at position: GridPosition) -> Bool {
        // Check bounds
        let size = partType.gridSize
        guard position.x >= 0 && position.x + size.width <= gridWidth else { return false }
        guard position.y >= 0 && position.y + size.height <= gridHeight else { return false }
        
        // Check overlap with existing parts
        for dx in 0..<size.width {
            for dy in 0..<size.height {
                let checkPos = position.offset(dx: dx, dy: dy)
                if contraption.part(at: checkPos) != nil {
                    // Allow if it's the part being dragged
                    if isDraggingPart?.gridPosition != checkPos {
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    // MARK: - Ghost (Preview)
    private func createGhost(for partType: PartType, at position: GridPosition) {
        clearGhost()
        
        let tempPart = GamePart(type: partType, gridPosition: position)
        ghostPart = PartRenderer.shared.createNode(for: tempPart)
        ghostPart?.alpha = 0.5
        ghostPart?.physicsBody = nil
        ghostPart?.position = gridToScreen(position)
        contraptionLayer.addChild(ghostPart!)
    }
    
    private func updateGhostPosition(to position: GridPosition) {
        guard let ghost = ghostPart else { return }
        ghost.position = gridToScreen(position)
        
        // Color based on validity
        let partType = selectedPartType ?? isDraggingPart?.type ?? .brassFrame
        let valid = isValidPlacement(for: partType, at: position)
        ghost.alpha = valid ? 0.5 : 0.3
    }
    
    private func clearGhost() {
        ghostPart?.removeFromParent()
        ghostPart = nil
    }
    
    // MARK: - Part Placement
    private func placePart(type: PartType, at position: GridPosition) {
        let part = GamePart(type: type, gridPosition: position)
        contraption.addPart(part)
        
        let node = PartRenderer.shared.createNode(for: part)
        contraptionLayer.addChild(node)
        
        // Play placement sound effect
        run(SKAction.playSoundFileNamed("place.wav", waitForCompletion: false))
    }
    
    private func removePart(_ part: GamePart) {
        // Don't remove KameraMan!
        guard part.type != .kameraMan else { return }
        
        part.node?.removeFromParent()
        contraption.removePart(part)
    }
    
    // MARK: - Simulation Control
    private func toggleSimulation() {
        if gameState == .building {
            startSimulation()
        } else if gameState == .simulating {
            stopSimulation()
        }
    }
    
    private func startSimulation() {
        guard contraption.hasKameraMan else {
            statusLabel.text = "Add KameraMan to your contraption!"
            return
        }
        
        gameState = .simulating
        simulationEngine.start()
        
        // Enable physics on all parts
        for part in contraption.parts {
            part.node?.physicsBody?.isDynamic = true
        }
        
        // Update play button
        if let label = playButton.children.compactMap({ $0 as? SKLabelNode }).first {
            label.text = "⏸"
        }
        
        statusLabel.text = "SIMULATION RUNNING..."
    }
    
    private func stopSimulation() {
        gameState = .building
        simulationEngine.stop()
        
        // Disable physics
        for part in contraption.parts {
            part.node?.physicsBody?.isDynamic = false
        }
        
        // Update play button
        if let label = playButton.children.compactMap({ $0 as? SKLabelNode }).first {
            label.text = "▶"
        }
        
        statusLabel.text = "BUILD YOUR DOOHICKEY!"
    }
    
    private func resetContraption() {
        // Reset positions
        for part in contraption.parts {
            part.node?.position = gridToScreen(part.gridPosition)
            part.node?.zRotation = CGFloat(part.rotation) * .pi / 180
            part.node?.physicsBody?.velocity = .zero
            part.node?.physicsBody?.angularVelocity = 0
            part.state = PartState()
        }
        
        simulationEngine.reset()
        
        if gameState != .building {
            stopSimulation()
        }
    }
    
    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        if gameState == .simulating {
            let deltaTime = 1.0 / 60.0  // Assuming 60fps
            simulationEngine.update(deltaTime: deltaTime)
        }
    }
    
    // MARK: - Visual Effects
    private func createExplosionEffect(at position: CGPoint) {
        let worldPos = convert(position, from: contraptionLayer)
        
        // Flash
        let flash = SKShapeNode(circleOfRadius: 50)
        flash.fillColor = SteampunkColors.fire
        flash.strokeColor = .clear
        flash.position = worldPos
        flash.zPosition = 150
        effectsLayer.addChild(flash)
        
        let expand = SKAction.scale(to: 3, duration: 0.3)
        let fade = SKAction.fadeOut(withDuration: 0.3)
        let group = SKAction.group([expand, fade])
        flash.run(SKAction.sequence([group, .removeFromParent()]))
        
        // Particles
        for _ in 0..<20 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...8))
            particle.fillColor = [SteampunkColors.fire, SteampunkColors.brass, SteampunkColors.iron].randomElement()!
            particle.strokeColor = .clear
            particle.position = worldPos
            effectsLayer.addChild(particle)
            
            let angle = CGFloat.random(in: 0...(.pi * 2))
            let distance = CGFloat.random(in: 50...150)
            let destination = CGPoint(
                x: worldPos.x + cos(angle) * distance,
                y: worldPos.y + sin(angle) * distance
            )
            
            let move = SKAction.move(to: destination, duration: 0.5)
            move.timingMode = .easeOut
            let fade = SKAction.fadeOut(withDuration: 0.5)
            particle.run(SKAction.sequence([SKAction.group([move, fade]), .removeFromParent()]))
        }
        
        // Screen shake
        let shake = SKAction.sequence([
            SKAction.moveBy(x: 10, y: 5, duration: 0.05),
            SKAction.moveBy(x: -20, y: -10, duration: 0.05),
            SKAction.moveBy(x: 15, y: 8, duration: 0.05),
            SKAction.moveBy(x: -5, y: -3, duration: 0.05)
        ])
        run(shake)
    }
    
    private func createElectricalArc(from start: CGPoint, to end: CGPoint) {
        let worldStart = convert(start, from: contraptionLayer)
        let worldEnd = convert(end, from: contraptionLayer)
        
        let path = CGMutablePath()
        path.move(to: worldStart)
        
        // Jagged line
        let segments = 8
        for i in 1..<segments {
            let t = CGFloat(i) / CGFloat(segments)
            let baseX = worldStart.x + (worldEnd.x - worldStart.x) * t
            let baseY = worldStart.y + (worldEnd.y - worldStart.y) * t
            let offset = CGFloat.random(in: -15...15)
            path.addLine(to: CGPoint(x: baseX + offset, y: baseY + offset))
        }
        path.addLine(to: worldEnd)
        
        let arc = SKShapeNode(path: path)
        arc.strokeColor = SteampunkColors.electricityBright
        arc.lineWidth = 3
        arc.glowWidth = 8
        arc.zPosition = 150
        effectsLayer.addChild(arc)
        
        arc.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            .removeFromParent()
        ]))
    }
    
    private func createSteamEffect(at position: CGPoint, direction: CGVector) {
        let worldPos = convert(position, from: contraptionLayer)
        
        for _ in 0..<10 {
            let puff = SKShapeNode(circleOfRadius: CGFloat.random(in: 8...16))
            puff.fillColor = SteampunkColors.steam
            puff.strokeColor = .clear
            puff.position = worldPos
            puff.alpha = 0.6
            effectsLayer.addChild(puff)
            
            let normalizedDir = CGVector(
                dx: direction.dx / 500 + CGFloat.random(in: -0.3...0.3),
                dy: direction.dy / 500 + CGFloat.random(in: -0.3...0.3)
            )
            let destination = CGPoint(
                x: worldPos.x + normalizedDir.dx * CGFloat.random(in: 50...100),
                y: worldPos.y + normalizedDir.dy * CGFloat.random(in: 50...100)
            )
            
            let move = SKAction.move(to: destination, duration: 0.8)
            let scale = SKAction.scale(to: 2, duration: 0.8)
            let fade = SKAction.fadeOut(withDuration: 0.8)
            puff.run(SKAction.sequence([
                SKAction.group([move, scale, fade]),
                .removeFromParent()
            ]))
        }
    }
    
    private func updatePartVisuals(_ part: GamePart) {
        guard let node = part.node else { return }
        
        // Fire glow for furnace
        if part.type == .coalFurnace, let glow = node.childNode(withName: "fireGlow") as? SKShapeNode {
            let intensity = part.state.temperature / 400
            glow.alpha = intensity
        }
        
        // Electric glow for tesla coil
        if part.type == .teslaCoil, let glow = node.childNode(withName: "electricGlow") {
            glow.alpha = part.state.electricCharge / 100
        }
        
        // Lamp glow
        if part.type == .arcLamp, let glow = node.childNode(withName: "lampGlow") {
            glow.alpha = part.state.isActive ? 1.0 : 0.3
        }
        
        // Rotating parts
        if part.state.rotationSpeed > 0 {
            let rotation = part.state.rotationSpeed / 60 * .pi * 2 / 60  // Convert RPM to radians per frame
            node.zRotation += rotation
        }
    }
    
    private func updateKameraManHealth(_ health: CGFloat) {
        statusLabel.text = "TINKER HEALTH: \(Int(health))%"
        if health < 30 {
            statusLabel.fontColor = SteampunkColors.danger
        }
    }
    
    private func updateUIForState() {
        switch gameState {
        case .building:
            toolboxNode.alpha = 1.0
            statusLabel.fontColor = SteampunkColors.brassLight
        case .simulating:
            toolboxNode.alpha = 0.5
        case .victory:
            statusLabel.text = "🎉 VICTORY! KameraMan made it! 🎉"
            statusLabel.fontColor = SteampunkColors.success
        case .failure:
            statusLabel.text = "💥 KameraMan was destroyed! Try again! 💥"
            statusLabel.fontColor = SteampunkColors.danger
        }
    }
    
    // MARK: - Physics Contact
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.contraption | PhysicsCategory.goal {
            // Check if KameraMan reached goal
            if let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node {
                let isKameraManA = contraption.parts.first(where: { $0.node == nodeA && $0.type == .kameraMan }) != nil
                let isKameraManB = contraption.parts.first(where: { $0.node == nodeB && $0.type == .kameraMan }) != nil
                
                if isKameraManA || isKameraManB {
                    gameState = .victory
                    simulationEngine.stop()
                }
            }
        }
    }
}

