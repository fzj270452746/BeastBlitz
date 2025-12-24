//
//  DimensionalMetrics.swift
//  BeastBlitz
//
//  Spacing, sizing, and dimensional constants
//

import UIKit

struct DimensionalMetrics {

    // MARK: - Screen Proportions
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }

    static var safeAreaInsets: UIEdgeInsets {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
    }

    // MARK: - Spacing Tokens
    struct Spacing {
        static let microscopic: CGFloat = 4
        static let diminutive: CGFloat = 8
        static let compact: CGFloat = 12
        static let moderate: CGFloat = 16
        static let substantial: CGFloat = 20
        static let generous: CGFloat = 24
        static let expansive: CGFloat = 32
        static let voluminous: CGFloat = 40
        static let cavernous: CGFloat = 48
    }

    // MARK: - Corner Radius Tokens
    struct CornerCurvature {
        static let subtle: CGFloat = 8
        static let moderate: CGFloat = 12
        static let pronounced: CGFloat = 16
        static let substantial: CGFloat = 20
        static let circular: CGFloat = 24
        static let capsular: CGFloat = 999
    }

    // MARK: - Shadow Configurations
    struct ShadowParameters {
        let chromaValue: CGColor
        let opacityLevel: Float
        let displacementOffset: CGSize
        let blurRadius: CGFloat

        static let subtleElevation = ShadowParameters(
            chromaValue: UIColor.black.cgColor,
            opacityLevel: 0.08,
            displacementOffset: CGSize(width: 0, height: 2),
            blurRadius: 8
        )

        static let moderateElevation = ShadowParameters(
            chromaValue: UIColor.black.cgColor,
            opacityLevel: 0.15,
            displacementOffset: CGSize(width: 0, height: 4),
            blurRadius: 12
        )

        static let prominentElevation = ShadowParameters(
            chromaValue: UIColor.black.cgColor,
            opacityLevel: 0.25,
            displacementOffset: CGSize(width: 0, height: 8),
            blurRadius: 24
        )

        static let glowingElevation = ShadowParameters(
            chromaValue: ChromaticPalette.amberSunset.cgColor,
            opacityLevel: 0.5,
            displacementOffset: CGSize(width: 0, height: 0),
            blurRadius: 16
        )
    }

    // MARK: - Grid Calculations
    static func calculateCellDimension(
        forColumns columns: Int,
        containerWidth: CGFloat,
        horizontalPadding: CGFloat,
        interCellSpacing: CGFloat
    ) -> CGFloat {
        let totalSpacing = horizontalPadding * 2 + interCellSpacing * CGFloat(columns - 1)
        let availableWidth = containerWidth - totalSpacing
        return floor(availableWidth / CGFloat(columns))
    }

    // MARK: - Responsive Sizing
    static func proportionalValue(
        baseValue: CGFloat,
        referenceWidth: CGFloat = 375
    ) -> CGFloat {
        let scaleFactor = min(screenWidth / referenceWidth, 1.3)
        return baseValue * scaleFactor
    }

    // MARK: - Button Dimensions
    struct ButtonDimensions {
        static let standardHeight: CGFloat = 56
        static let compactHeight: CGFloat = 44
        static let iconButtonSize: CGFloat = 48
        static let floatingActionSize: CGFloat = 64
    }

    // MARK: - Card Dimensions
    struct CardDimensions {
        static let standardPadding: CGFloat = 20
        static let compactPadding: CGFloat = 16
        static let minHeight: CGFloat = 80
    }
}

// MARK: - UIView Shadow Extension
extension UIView {
    func applyShadowConfiguration(_ parameters: DimensionalMetrics.ShadowParameters) {
        layer.shadowColor = parameters.chromaValue
        layer.shadowOpacity = parameters.opacityLevel
        layer.shadowOffset = parameters.displacementOffset
        layer.shadowRadius = parameters.blurRadius
        layer.masksToBounds = false
    }
}
