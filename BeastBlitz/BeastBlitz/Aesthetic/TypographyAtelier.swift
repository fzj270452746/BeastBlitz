//
//  TypographyAtelier.swift
//  BeastBlitz
//
//  Typography system with game-appropriate fonts
//

import UIKit

struct TypographyAtelier {

    // MARK: - Font Weight Definitions
    enum TypographicWeight {
        case gossamer       // Light
        case standard       // Regular
        case substantial    // Medium
        case emphatic       // Semibold
        case commanding     // Bold
        case monumental     // Heavy

        var systemWeight: UIFont.Weight {
            switch self {
            case .gossamer: return .light
            case .standard: return .regular
            case .substantial: return .medium
            case .emphatic: return .semibold
            case .commanding: return .bold
            case .monumental: return .heavy
            }
        }
    }

    // MARK: - Font Size Presets
    enum TypographicScale: CGFloat {
        case minuscule = 10
        case petite = 12
        case compact = 14
        case moderate = 16
        case substantial = 18
        case prominent = 22
        case commanding = 28
        case grandiose = 36
        case monumental = 48
        case colossal = 64
    }

    // MARK: - Font Generation
    static func composeFont(
        magnitude: TypographicScale,
        gravitas: TypographicWeight = .standard,
        roundedVariant: Bool = false
    ) -> UIFont {
        if roundedVariant {
            if let roundedDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
                .withDesign(.rounded) {
                return UIFont(descriptor: roundedDescriptor, size: magnitude.rawValue)
                    .withWeight(gravitas.systemWeight)
            }
        }
        return UIFont.systemFont(ofSize: magnitude.rawValue, weight: gravitas.systemWeight)
    }

    // MARK: - Semantic Font Styles
    static var heroTitleFont: UIFont {
        return composeFont(magnitude: .colossal, gravitas: .monumental, roundedVariant: true)
    }

    static var sectionHeaderFont: UIFont {
        return composeFont(magnitude: .grandiose, gravitas: .commanding, roundedVariant: true)
    }

    static var cardTitleFont: UIFont {
        return composeFont(magnitude: .commanding, gravitas: .emphatic, roundedVariant: true)
    }

    static var buttonLabelFont: UIFont {
        return composeFont(magnitude: .substantial, gravitas: .commanding, roundedVariant: true)
    }

    static var bodyTextFont: UIFont {
        return composeFont(magnitude: .moderate, gravitas: .standard, roundedVariant: false)
    }

    static var captionTextFont: UIFont {
        return composeFont(magnitude: .compact, gravitas: .substantial, roundedVariant: false)
    }

    static var scoreDisplayFont: UIFont {
        return composeFont(magnitude: .monumental, gravitas: .monumental, roundedVariant: true)
    }

    static var timerDisplayFont: UIFont {
        return UIFont.monospacedDigitSystemFont(ofSize: TypographicScale.grandiose.rawValue, weight: .bold)
    }

    static var riddleTextFont: UIFont {
        return composeFont(magnitude: .prominent, gravitas: .emphatic, roundedVariant: true)
    }

    static var comboTextFont: UIFont {
        return composeFont(magnitude: .commanding, gravitas: .monumental, roundedVariant: true)
    }

    static var leaderboardRankFont: UIFont {
        return composeFont(magnitude: .prominent, gravitas: .commanding, roundedVariant: true)
    }

    static var leaderboardScoreFont: UIFont {
        return UIFont.monospacedDigitSystemFont(ofSize: TypographicScale.substantial.rawValue, weight: .semibold)
    }

    static var smallLabelFont: UIFont {
        return composeFont(magnitude: .petite, gravitas: .substantial, roundedVariant: false)
    }
}

// MARK: - UIFont Extension
extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let newDescriptor = fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: weight]
        ])
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}
