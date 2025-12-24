

import Foundation

enum ContestDifficultyTier: String, CaseIterable {
    case noviceTier = "Beginner"
    case veteranTier = "Advanced"

    var gridColumnQuantity: Int {
        switch self {
        case .noviceTier: return 4
        case .veteranTier: return 6
        }
    }

    var gridRowQuantity: Int {
        switch self {
        case .noviceTier: return 5
        case .veteranTier: return 6
        }
    }

    var countdownDurationSeconds: TimeInterval {
        switch self {
        case .noviceTier: return 15.0
        case .veteranTier: return 20.0
        }
    }

    var pointsPerVictoriousRound: Int {
        switch self {
        case .noviceTier: return 10
        case .veteranTier: return 20
        }
    }

    var comboActivationThreshold: Int {
        return 3
    }

    var totalCellCount: Int {
        return gridColumnQuantity * gridRowQuantity
    }

    var descriptiveLabel: String {
        switch self {
        case .noviceTier:
            return "4×5 Grid • 5s Timer • 10 pts/round"
        case .veteranTier:
            return "6×6 Grid • 10s Timer • 20 pts/round"
        }
    }
}

struct ContestConfiguration {
    let difficultyTier: ContestDifficultyTier
    let enableSoundEffects: Bool
    let enableHapticFeedback: Bool

    static let defaultConfiguration = ContestConfiguration(
        difficultyTier: .noviceTier,
        enableSoundEffects: true,
        enableHapticFeedback: true
    )
}

final class PreferencesVault {

    static let sharedInstance = PreferencesVault()

    private let soundEnabledKey = "AudioEffectsEnabled"
    private let hapticEnabledKey = "HapticResponseEnabled"
    private let playerNameKey = "ContestantMoniker"

    private init() {
        registerDefaultValues()
    }

    private func registerDefaultValues() {
        let defaults: [String: Any] = [
            soundEnabledKey: true,
            hapticEnabledKey: true,
            playerNameKey: "Player"
        ]
        UserDefaults.standard.register(defaults: defaults)
    }

    var isSoundEffectsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: soundEnabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: soundEnabledKey) }
    }

    var isHapticFeedbackEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: hapticEnabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: hapticEnabledKey) }
    }

    var contestantMoniker: String {
        get { UserDefaults.standard.string(forKey: playerNameKey) ?? "Player" }
        set { UserDefaults.standard.set(newValue, forKey: playerNameKey) }
    }
}
