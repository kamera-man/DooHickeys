import AVFoundation
import SpriteKit

// MARK: - Sound Effect Types
enum SoundEffect: String, CaseIterable {
    // UI Sounds
    case buttonTap = "button_tap"
    case partSelect = "part_select"
    case partPlace = "part_place"
    case partRemove = "part_remove"
    case partRotate = "part_rotate"
    case menuOpen = "menu_open"
    case menuClose = "menu_close"
    
    // Mechanical Sounds
    case gearTurn = "gear_turn"
    case gearGrind = "gear_grind"
    case wheelRoll = "wheel_roll"
    case springBoing = "spring_boing"
    case pistonPump = "piston_pump"
    case clockworkTick = "clockwork_tick"
    case windupKey = "windup_key"
    case beltWhir = "belt_whir"
    case flywheelSpin = "flywheel_spin"
    
    // Steam Sounds
    case steamHiss = "steam_hiss"
    case steamBurst = "steam_burst"
    case boilerBubble = "boiler_bubble"
    case valveOpen = "valve_open"
    case valveClose = "valve_close"
    case pressureWarning = "pressure_warning"
    case pressureRelease = "pressure_release"
    
    // Electrical Sounds
    case electricZap = "electric_zap"
    case electricHum = "electric_hum"
    case sparkCrackle = "spark_crackle"
    case teslaDischarge = "tesla_discharge"
    case capacitorCharge = "capacitor_charge"
    case lightBuzz = "light_buzz"
    
    // Fire/Explosion Sounds
    case fireRoar = "fire_roar"
    case fireCrackle = "fire_crackle"
    case explosionSmall = "explosion_small"
    case explosionMedium = "explosion_medium"
    case explosionLarge = "explosion_large"
    case dynamiteFuse = "dynamite_fuse"
    case cannonFire = "cannon_fire"
    
    // Trigger Sounds
    case pressurePlateClick = "pressure_plate_click"
    case tripwireSnap = "tripwire_snap"
    case timerTick = "timer_tick"
    case timerDing = "timer_ding"
    case bellowsPuff = "bellows_puff"
    
    // Special Sounds
    case balloonInflate = "balloon_inflate"
    case parachuteOpen = "parachute_open"
    case grappleLaunch = "grapple_launch"
    case grappleAttach = "grapple_attach"
    case magnetHum = "magnet_hum"
    case gyroscopeSpin = "gyroscope_spin"
    
    // KameraMan Sounds
    case kameraManHappy = "kamera_man_happy"
    case kameraManWorried = "kamera_man_worried"
    case kameraManHurt = "kamera_man_hurt"
    case kameraManCheer = "kamera_man_cheer"
    case cameraShutter = "camera_shutter"
    case cameraFlash = "camera_flash"
    
    // Game State Sounds
    case simulationStart = "simulation_start"
    case simulationStop = "simulation_stop"
    case victory = "victory"
    case defeat = "defeat"
    case starEarned = "star_earned"
    case levelUnlock = "level_unlock"
    
    // Collision Sounds
    case metalClank = "metal_clank"
    case woodThud = "wood_thud"
    case softBounce = "soft_bounce"
    case hardImpact = "hard_impact"
    case splash = "splash"
    case shatter = "shatter"
    
    var category: SoundCategory {
        switch self {
        case .buttonTap, .partSelect, .partPlace, .partRemove, .partRotate, .menuOpen, .menuClose:
            return .ui
        case .gearTurn, .gearGrind, .wheelRoll, .springBoing, .pistonPump, .clockworkTick, .windupKey, .beltWhir, .flywheelSpin:
            return .mechanical
        case .steamHiss, .steamBurst, .boilerBubble, .valveOpen, .valveClose, .pressureWarning, .pressureRelease:
            return .steam
        case .electricZap, .electricHum, .sparkCrackle, .teslaDischarge, .capacitorCharge, .lightBuzz:
            return .electrical
        case .fireRoar, .fireCrackle, .explosionSmall, .explosionMedium, .explosionLarge, .dynamiteFuse, .cannonFire:
            return .explosion
        case .pressurePlateClick, .tripwireSnap, .timerTick, .timerDing, .bellowsPuff:
            return .trigger
        case .balloonInflate, .parachuteOpen, .grappleLaunch, .grappleAttach, .magnetHum, .gyroscopeSpin:
            return .special
        case .kameraManHappy, .kameraManWorried, .kameraManHurt, .kameraManCheer, .cameraShutter, .cameraFlash:
            return .kameraMan
        case .simulationStart, .simulationStop, .victory, .defeat, .starEarned, .levelUnlock:
            return .gameState
        case .metalClank, .woodThud, .softBounce, .hardImpact, .splash, .shatter:
            return .collision
        }
    }
    
    var defaultVolume: Float {
        switch category {
        case .ui: return 0.5
        case .mechanical: return 0.6
        case .steam: return 0.7
        case .electrical: return 0.6
        case .explosion: return 0.8
        case .trigger: return 0.5
        case .special: return 0.6
        case .kameraMan: return 0.7
        case .gameState: return 0.8
        case .collision: return 0.6
        }
    }
}

enum SoundCategory: String {
    case ui
    case mechanical
    case steam
    case electrical
    case explosion
    case trigger
    case special
    case kameraMan
    case gameState
    case collision
}

// MARK: - Music Tracks
enum MusicTrack: String, CaseIterable {
    case mainMenu = "music_main_menu"
    case building = "music_building"
    case simulation = "music_simulation"
    case victory = "music_victory"
    case tense = "music_tense"
    
    var looping: Bool {
        switch self {
        case .mainMenu, .building, .simulation, .tense:
            return true
        case .victory:
            return false
        }
    }
}

// MARK: - Audio Manager
class AudioManager {
    static let shared = AudioManager()
    
    // Settings
    var isSoundEnabled = true {
        didSet { UserDefaults.standard.set(isSoundEnabled, forKey: "sound_enabled") }
    }
    var isMusicEnabled = true {
        didSet { 
            UserDefaults.standard.set(isMusicEnabled, forKey: "music_enabled")
            if !isMusicEnabled { stopMusic() }
        }
    }
    var soundVolume: Float = 1.0 {
        didSet { UserDefaults.standard.set(soundVolume, forKey: "sound_volume") }
    }
    var musicVolume: Float = 0.7 {
        didSet { 
            UserDefaults.standard.set(musicVolume, forKey: "music_volume")
            musicPlayer?.volume = musicVolume
        }
    }
    
    // Players
    private var soundPlayers: [SoundEffect: [AVAudioPlayer]] = [:]
    private var musicPlayer: AVAudioPlayer?
    private var currentMusic: MusicTrack?
    
    // Looping sound management
    private var loopingSounds: [String: AVAudioPlayer] = [:]
    
    // Audio session
    private let audioSession = AVAudioSession.sharedInstance()
    
    private init() {
        loadSettings()
        setupAudioSession()
        preloadCommonSounds()
    }
    
    private func loadSettings() {
        if UserDefaults.standard.object(forKey: "sound_enabled") != nil {
            isSoundEnabled = UserDefaults.standard.bool(forKey: "sound_enabled")
        }
        if UserDefaults.standard.object(forKey: "music_enabled") != nil {
            isMusicEnabled = UserDefaults.standard.bool(forKey: "music_enabled")
        }
        if UserDefaults.standard.object(forKey: "sound_volume") != nil {
            soundVolume = UserDefaults.standard.float(forKey: "sound_volume")
        }
        if UserDefaults.standard.object(forKey: "music_volume") != nil {
            musicVolume = UserDefaults.standard.float(forKey: "music_volume")
        }
    }
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func preloadCommonSounds() {
        // Preload frequently used sounds
        let commonSounds: [SoundEffect] = [
            .buttonTap, .partSelect, .partPlace, .gearTurn, .steamHiss,
            .electricZap, .metalClank, .kameraManHappy, .kameraManHurt
        ]
        
        for sound in commonSounds {
            preloadSound(sound)
        }
    }
    
    private func preloadSound(_ sound: SoundEffect) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav") ??
                        Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            soundPlayers[sound] = [player]
        } catch {
            print("Failed to preload sound \(sound.rawValue): \(error)")
        }
    }
    
    // MARK: - Sound Playback
    
    /// Play a sound effect
    func playSound(_ sound: SoundEffect, volume: Float? = nil, pitch: Float = 1.0) {
        guard isSoundEnabled else { return }
        
        let finalVolume = (volume ?? sound.defaultVolume) * soundVolume
        
        // Try to find or create a player
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav") ??
                        Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            // Sound file not found - use synthesized sound as fallback
            playSynthesizedSound(sound, volume: finalVolume)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = finalVolume
                player.enableRate = true
                player.rate = pitch
                player.prepareToPlay()
                player.play()
            } catch {
                print("Failed to play sound \(sound.rawValue): \(error)")
            }
        }
    }
    
    /// Play a looping sound effect
    func playLoopingSound(_ sound: SoundEffect, identifier: String, volume: Float? = nil) {
        guard isSoundEnabled else { return }
        
        // Stop existing loop with same identifier
        stopLoopingSound(identifier: identifier)
        
        let finalVolume = (volume ?? sound.defaultVolume) * soundVolume
        
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav") ??
                        Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = finalVolume
            player.numberOfLoops = -1  // Infinite loop
            player.prepareToPlay()
            player.play()
            loopingSounds[identifier] = player
        } catch {
            print("Failed to play looping sound \(sound.rawValue): \(error)")
        }
    }
    
    /// Stop a looping sound
    func stopLoopingSound(identifier: String, fadeOut: Bool = true) {
        guard let player = loopingSounds[identifier] else { return }
        
        if fadeOut {
            // Fade out over 0.3 seconds
            let fadeSteps = 10
            let fadeInterval = 0.03
            let volumeStep = player.volume / Float(fadeSteps)
            
            for i in 0..<fadeSteps {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * fadeInterval) {
                    player.volume -= volumeStep
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                player.stop()
                self.loopingSounds.removeValue(forKey: identifier)
            }
        } else {
            player.stop()
            loopingSounds.removeValue(forKey: identifier)
        }
    }
    
    /// Stop all looping sounds
    func stopAllLoopingSounds() {
        for (identifier, _) in loopingSounds {
            stopLoopingSound(identifier: identifier, fadeOut: false)
        }
    }
    
    // MARK: - Music Playback
    
    /// Play a music track
    func playMusic(_ track: MusicTrack, fadeIn: Bool = true) {
        guard isMusicEnabled else { return }
        guard track != currentMusic else { return }
        
        // Stop current music
        if currentMusic != nil {
            stopMusic(fadeOut: true)
        }
        
        guard let url = Bundle.main.url(forResource: track.rawValue, withExtension: "mp3") ??
                        Bundle.main.url(forResource: track.rawValue, withExtension: "m4a") else {
            print("Music file not found: \(track.rawValue)")
            return
        }
        
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = track.looping ? -1 : 0
            musicPlayer?.volume = fadeIn ? 0 : musicVolume
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
            currentMusic = track
            
            if fadeIn {
                fadeInMusic()
            }
        } catch {
            print("Failed to play music \(track.rawValue): \(error)")
        }
    }
    
    /// Stop music playback
    func stopMusic(fadeOut: Bool = true) {
        guard let player = musicPlayer else { return }
        
        if fadeOut {
            fadeOutMusic {
                player.stop()
                self.musicPlayer = nil
                self.currentMusic = nil
            }
        } else {
            player.stop()
            musicPlayer = nil
            currentMusic = nil
        }
    }
    
    /// Pause music
    func pauseMusic() {
        musicPlayer?.pause()
    }
    
    /// Resume music
    func resumeMusic() {
        guard isMusicEnabled else { return }
        musicPlayer?.play()
    }
    
    private func fadeInMusic() {
        guard let player = musicPlayer else { return }
        
        let fadeSteps = 20
        let fadeInterval = 0.05
        let volumeStep = musicVolume / Float(fadeSteps)
        
        for i in 0..<fadeSteps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * fadeInterval) {
                player.volume = min(player.volume + volumeStep, self.musicVolume)
            }
        }
    }
    
    private func fadeOutMusic(completion: @escaping () -> Void) {
        guard let player = musicPlayer else {
            completion()
            return
        }
        
        let fadeSteps = 20
        let fadeInterval = 0.05
        let volumeStep = player.volume / Float(fadeSteps)
        
        for i in 0..<fadeSteps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * fadeInterval) {
                player.volume = max(player.volume - volumeStep, 0)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion()
        }
    }
    
    // MARK: - Synthesized Fallback Sounds
    
    /// Generate basic sounds when audio files aren't available
    private func playSynthesizedSound(_ sound: SoundEffect, volume: Float) {
        // Use SpriteKit's built-in sound actions for basic feedback
        // This is a fallback when actual audio files aren't present

        let _action: SKAction?

        switch sound.category {
        case .ui:
            _action = SKAction.playSoundFileNamed("click.caf", waitForCompletion: false)
        case .mechanical:
            _action = SKAction.playSoundFileNamed("gear.caf", waitForCompletion: false)
        case .explosion:
            _action = SKAction.playSoundFileNamed("boom.caf", waitForCompletion: false)
        default:
            _action = nil
        }

        // Note: These would need actual .caf files in the bundle
        // For development, we just log that a sound would play
        _ = _action  // Suppress unused warning until audio files are added
        print("🔊 Sound: \(sound.rawValue)")
    }
}

// MARK: - SpriteKit Integration
extension SKScene {
    /// Play a sound effect in this scene
    func playSound(_ sound: SoundEffect, volume: Float? = nil) {
        AudioManager.shared.playSound(sound, volume: volume)
    }
    
    /// Play a looping sound tied to a node
    func playLoopingSound(_ sound: SoundEffect, for node: SKNode) {
        let identifier = "\(sound.rawValue)_\(node.hashValue)"
        AudioManager.shared.playLoopingSound(sound, identifier: identifier)
    }
    
    /// Stop a looping sound tied to a node
    func stopLoopingSound(_ sound: SoundEffect, for node: SKNode) {
        let identifier = "\(sound.rawValue)_\(node.hashValue)"
        AudioManager.shared.stopLoopingSound(identifier: identifier)
    }
}

// MARK: - Sound Groups for Parts
extension PartType {
    /// Get appropriate sounds for this part type
    var sounds: PartSounds {
        switch self {
        case .cogWheel, .spikedWheel, .tankTread:
            return PartSounds(
                active: .wheelRoll,
                activate: .gearTurn,
                deactivate: nil,
                impact: .metalClank
            )
        case .steamBoiler:
            return PartSounds(
                active: .boilerBubble,
                activate: .steamHiss,
                deactivate: .pressureRelease,
                impact: .metalClank
            )
        case .coalFurnace:
            return PartSounds(
                active: .fireRoar,
                activate: .fireCrackle,
                deactivate: nil,
                impact: .metalClank
            )
        case .clockworkMotor:
            return PartSounds(
                active: .clockworkTick,
                activate: .windupKey,
                deactivate: nil,
                impact: .metalClank
            )
        case .teslaCoil:
            return PartSounds(
                active: .electricHum,
                activate: .teslaDischarge,
                deactivate: nil,
                impact: .electricZap
            )
        case .smallGear, .largeGear:
            return PartSounds(
                active: .gearTurn,
                activate: nil,
                deactivate: nil,
                impact: .gearGrind
            )
        case .piston:
            return PartSounds(
                active: .pistonPump,
                activate: nil,
                deactivate: nil,
                impact: .metalClank
            )
        case .dynamite:
            return PartSounds(
                active: .dynamiteFuse,
                activate: .explosionLarge,
                deactivate: nil,
                impact: nil
            )
        case .cannon:
            return PartSounds(
                active: nil,
                activate: .cannonFire,
                deactivate: nil,
                impact: .metalClank
            )
        case .springLeg:
            return PartSounds(
                active: nil,
                activate: .springBoing,
                deactivate: nil,
                impact: .softBounce
            )
        case .steamValve:
            return PartSounds(
                active: .steamHiss,
                activate: .valveOpen,
                deactivate: .valveClose,
                impact: .metalClank
            )
        case .pressurePlate:
            return PartSounds(
                active: nil,
                activate: .pressurePlateClick,
                deactivate: nil,
                impact: nil
            )
        case .tripwire:
            return PartSounds(
                active: nil,
                activate: .tripwireSnap,
                deactivate: nil,
                impact: nil
            )
        case .timerSwitch:
            return PartSounds(
                active: .timerTick,
                activate: .timerDing,
                deactivate: nil,
                impact: nil
            )
        case .bellows:
            return PartSounds(
                active: nil,
                activate: .bellowsPuff,
                deactivate: nil,
                impact: nil
            )
        case .hotAirBalloon:
            return PartSounds(
                active: nil,
                activate: .balloonInflate,
                deactivate: nil,
                impact: .softBounce
            )
        case .parachute:
            return PartSounds(
                active: nil,
                activate: .parachuteOpen,
                deactivate: nil,
                impact: .softBounce
            )
        case .grappleHook:
            return PartSounds(
                active: nil,
                activate: .grappleLaunch,
                deactivate: .grappleAttach,
                impact: .metalClank
            )
        case .magneticAttractor:
            return PartSounds(
                active: .magnetHum,
                activate: nil,
                deactivate: nil,
                impact: .metalClank
            )
        case .gyroscope:
            return PartSounds(
                active: .gyroscopeSpin,
                activate: nil,
                deactivate: nil,
                impact: .metalClank
            )
        case .kameraMan:
            return PartSounds(
                active: .cameraShutter,       // Click click click!
                activate: .kameraManHappy,
                deactivate: .kameraManWorried,
                impact: .kameraManHurt
            )
        case .arcLamp:
            return PartSounds(
                active: .lightBuzz,
                activate: .electricZap,
                deactivate: nil,
                impact: .shatter
            )
        case .capacitor:
            return PartSounds(
                active: .electricHum,
                activate: .capacitorCharge,
                deactivate: .electricZap,
                impact: .metalClank
            )
        case .flywheel:
            return PartSounds(
                active: .flywheelSpin,
                activate: nil,
                deactivate: nil,
                impact: .metalClank
            )
        case .beltDrive:
            return PartSounds(
                active: .beltWhir,
                activate: nil,
                deactivate: nil,
                impact: nil
            )
        case .woodenFrame:
            return PartSounds(
                active: nil,
                activate: nil,
                deactivate: nil,
                impact: .woodThud
            )
        default:
            return PartSounds(
                active: nil,
                activate: nil,
                deactivate: nil,
                impact: .metalClank
            )
        }
    }
}

struct PartSounds {
    let active: SoundEffect?      // Played while part is active/running
    let activate: SoundEffect?    // Played when part activates
    let deactivate: SoundEffect?  // Played when part deactivates
    let impact: SoundEffect?      // Played on collision
}
