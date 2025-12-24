//
//  ChromaticPalette.swift
//  BeastBlitz
//
//  Design system colors optimized for animal theme game
//

import UIKit

struct ChromaticPalette {

    // MARK: - Primary Gradient Colors (Jungle Theme)
    static let verdantCanopy = UIColor(red: 0.16, green: 0.50, blue: 0.38, alpha: 1.0)      // #298061
    static let emeraldForest = UIColor(red: 0.13, green: 0.40, blue: 0.30, alpha: 1.0)      // #216650
    static let deepWilderness = UIColor(red: 0.08, green: 0.28, blue: 0.22, alpha: 1.0)     // #154838
    static let forestFloor = UIColor(red: 0.05, green: 0.18, blue: 0.14, alpha: 1.0)        // #0D2E24

    // MARK: - Accent Colors (Safari Sunset)
    static let amberSunset = UIColor(red: 1.00, green: 0.68, blue: 0.26, alpha: 1.0)        // #FFAD42
    static let coralDawn = UIColor(red: 1.00, green: 0.52, blue: 0.42, alpha: 1.0)          // #FF856B
    static let goldenSavannah = UIColor(red: 0.98, green: 0.82, blue: 0.38, alpha: 1.0)     // #FAD161

    // MARK: - Semantic Colors
    static let triumphGreen = UIColor(red: 0.30, green: 0.78, blue: 0.45, alpha: 1.0)       // #4DC773
    static let perilRed = UIColor(red: 0.96, green: 0.34, blue: 0.38, alpha: 1.0)           // #F55761
    static let cautionAmber = UIColor(red: 1.00, green: 0.76, blue: 0.28, alpha: 1.0)       // #FFC247

    // MARK: - Neutral Tones
    static let ivoryMist = UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1.0)          // #FAF8F2
    static let parchmentBeige = UIColor(red: 0.95, green: 0.92, blue: 0.87, alpha: 1.0)     // #F2EBDE
    static let stoneGray = UIColor(red: 0.60, green: 0.58, blue: 0.55, alpha: 1.0)          // #99948C
    static let obsidianDark = UIColor(red: 0.12, green: 0.11, blue: 0.10, alpha: 1.0)       // #1F1C1A

    // MARK: - Card and Surface Colors
    static let cardSurfaceLight = UIColor(white: 1.0, alpha: 0.95)
    static let cardSurfaceDark = UIColor(red: 0.10, green: 0.22, blue: 0.18, alpha: 0.90)   // Dark jungle
    static let overlayVeil = UIColor(white: 0.0, alpha: 0.6)

    // MARK: - Text Colors
    static let primaryTextLight = UIColor(white: 1.0, alpha: 1.0)
    static let secondaryTextLight = UIColor(white: 1.0, alpha: 0.75)
    static let primaryTextDark = obsidianDark
    static let secondaryTextDark = stoneGray

    // MARK: - Combo Colors (Progressive)
    static let comboLevel1 = UIColor(red: 0.30, green: 0.78, blue: 0.45, alpha: 1.0)        // Green
    static let comboLevel2 = UIColor(red: 0.40, green: 0.70, blue: 0.98, alpha: 1.0)        // Blue
    static let comboLevel3 = UIColor(red: 0.75, green: 0.45, blue: 0.98, alpha: 1.0)        // Purple
    static let comboLevel4 = UIColor(red: 0.98, green: 0.55, blue: 0.25, alpha: 1.0)        // Orange
    static let comboLevel5 = UIColor(red: 0.98, green: 0.30, blue: 0.40, alpha: 1.0)        // Red Hot

    // MARK: - Gradient Generation
    static func jungleGradientColors() -> [CGColor] {
        return [
            verdantCanopy.cgColor,
            emeraldForest.cgColor,
            deepWilderness.cgColor
        ]
    }

    static func sunsetGradientColors() -> [CGColor] {
        return [
            coralDawn.cgColor,
            amberSunset.cgColor,
            goldenSavannah.cgColor
        ]
    }

    static func buttonGradientColors() -> [CGColor] {
        return [
            amberSunset.cgColor,
            coralDawn.cgColor
        ]
    }

    static func comboGradientColors(forStreak streak: Int) -> [CGColor] {
        switch streak {
        case 3...4: return [comboLevel1.cgColor, comboLevel2.cgColor]
        case 5...6: return [comboLevel2.cgColor, comboLevel3.cgColor]
        case 7...8: return [comboLevel3.cgColor, comboLevel4.cgColor]
        default: return [comboLevel4.cgColor, comboLevel5.cgColor]
        }
    }
}

// MARK: - Gradient Layer Factory
final class GradientBackdropFactory {

    static func fabricateJungleGradient(forBounds bounds: CGRect) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = ChromaticPalette.jungleGradientColors()
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = bounds
        return gradientLayer
    }

    static func fabricateButtonGradient(forBounds bounds: CGRect) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = ChromaticPalette.buttonGradientColors()
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = bounds.height / 2
        return gradientLayer
    }

    static func fabricateCardGradient(forBounds bounds: CGRect) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(white: 1.0, alpha: 0.25).cgColor,
            UIColor(white: 1.0, alpha: 0.10).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = 20
        return gradientLayer
    }
}
