//
//  GlassomorphicCard.swift
//  BeastBlitz
//
//  Frosted glass style card component
//

import UIKit

class GlassomorphicCard: UIView {

    // MARK: - Visual Layers
    private var blurEffectView: UIVisualEffectView?
    private var borderGradientLayer: CAGradientLayer?
    private var innerGlowLayer: CAGradientLayer?

    var cardCornerRadius: CGFloat = DimensionalMetrics.CornerCurvature.substantial {
        didSet { refreshCardGeometry() }
    }

    var enableInnerGlow: Bool = true {
        didSet { refreshInnerGlowAppearance() }
    }

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        establishCardStructure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        establishCardStructure()
    }

    // MARK: - Setup
    private func establishCardStructure() {
        backgroundColor = .clear

        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.layer.cornerRadius = cardCornerRadius
        effectView.clipsToBounds = true
        insertSubview(effectView, at: 0)
        blurEffectView = effectView

        NSLayoutConstraint.activate([
            effectView.topAnchor.constraint(equalTo: topAnchor),
            effectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            effectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            effectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        layer.cornerRadius = cardCornerRadius
        applyShadowConfiguration(.moderateElevation)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        refreshCardGeometry()
        refreshInnerGlowAppearance()
        refreshBorderGradient()

        // Ensure all subviews are above the gradient layers
        for subview in subviews where subview != blurEffectView {
            bringSubviewToFront(subview)
        }
    }

    // MARK: - Visual Refresh
    private func refreshCardGeometry() {
        layer.cornerRadius = cardCornerRadius
        blurEffectView?.layer.cornerRadius = cardCornerRadius
    }

    private func refreshInnerGlowAppearance() {
        innerGlowLayer?.removeFromSuperlayer()

        guard enableInnerGlow else { return }

        // Only apply glow to top portion of the card (not covering content)
        let glowHeight: CGFloat = min(bounds.height * 0.4, 40)
        let glowLayer = CAGradientLayer()
        glowLayer.colors = [
            UIColor.white.withAlphaComponent(0.12).cgColor,
            UIColor.white.withAlphaComponent(0.03).cgColor,
            UIColor.clear.cgColor
        ]
        glowLayer.locations = [0, 0.5, 1]
        glowLayer.startPoint = CGPoint(x: 0.5, y: 0)
        glowLayer.endPoint = CGPoint(x: 0.5, y: 1)
        glowLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: glowHeight)
        glowLayer.cornerRadius = cardCornerRadius

        // Mask to only show in top corners
        let maskPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.width, height: glowHeight),
                                     byRoundingCorners: [.topLeft, .topRight],
                                     cornerRadii: CGSize(width: cardCornerRadius, height: cardCornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        glowLayer.mask = maskLayer

        layer.insertSublayer(glowLayer, above: blurEffectView?.layer)
        innerGlowLayer = glowLayer
    }

    private func refreshBorderGradient() {
        borderGradientLayer?.removeFromSuperlayer()

        let borderLayer = CAGradientLayer()
        borderLayer.colors = [
            UIColor.white.withAlphaComponent(0.3).cgColor,
            UIColor.white.withAlphaComponent(0.1).cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor
        ]
        borderLayer.locations = [0, 0.5, 1]
        borderLayer.startPoint = CGPoint(x: 0, y: 0)
        borderLayer.endPoint = CGPoint(x: 1, y: 1)
        borderLayer.frame = bounds
        borderLayer.cornerRadius = cardCornerRadius

        let maskLayer = CAShapeLayer()
        let outerPath = UIBezierPath(roundedRect: bounds, cornerRadius: cardCornerRadius)
        let innerRect = bounds.insetBy(dx: 1.5, dy: 1.5)
        let innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: cardCornerRadius - 1.5)
        outerPath.append(innerPath.reversing())
        maskLayer.path = outerPath.cgPath

        borderLayer.mask = maskLayer
        // Insert border layer below subviews, not on top
        if let innerGlow = innerGlowLayer {
            layer.insertSublayer(borderLayer, above: innerGlow)
        } else if let blur = blurEffectView?.layer {
            layer.insertSublayer(borderLayer, above: blur)
        } else {
            layer.insertSublayer(borderLayer, at: 0)
        }
        borderGradientLayer = borderLayer
    }
}

// MARK: - Solid Card Variant
final class SolidElevatedCard: UIView {

    var fillChroma: UIColor = ChromaticPalette.cardSurfaceDark {
        didSet { backgroundColor = fillChroma }
    }

    var cardCornerRadius: CGFloat = DimensionalMetrics.CornerCurvature.substantial {
        didSet { layer.cornerRadius = cardCornerRadius }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        establishCardAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        establishCardAppearance()
    }

    private func establishCardAppearance() {
        backgroundColor = fillChroma
        layer.cornerRadius = cardCornerRadius
        applyShadowConfiguration(.moderateElevation)
    }
}

// MARK: - Animated Selection Card
final class SelectableGlassCard: GlassomorphicCard {

    var isSelectedState: Bool = false {
        didSet { transitionSelectionState() }
    }

    private var selectionBorderLayer: CAShapeLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        establishSelectionMechanism()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        establishSelectionMechanism()
    }

    private func establishSelectionMechanism() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapInteraction))
        addGestureRecognizer(tapRecognizer)
    }

    @objc private func handleTapInteraction() {
        isSelectedState.toggle()
    }

    private func transitionSelectionState() {
        selectionBorderLayer?.removeFromSuperlayer()

        if isSelectedState {
            let borderLayer = CAShapeLayer()
            borderLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 2, dy: 2), cornerRadius: cardCornerRadius - 2).cgPath
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.strokeColor = ChromaticPalette.triumphGreen.cgColor
            borderLayer.lineWidth = 3
            layer.addSublayer(borderLayer)
            selectionBorderLayer = borderLayer

            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
            }
        }
    }
}
