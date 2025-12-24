//
//  GlimmeringButton.swift
//  BeastBlitz
//
//  Custom gradient button with animations
//

import UIKit

final class GlimmeringButton: UIButton {

    // MARK: - Visual Properties
    private var gradientBackdrop: CAGradientLayer?
    private var glowOverlay: CALayer?

    var chromaticScheme: GlimmerButtonStyle = .primary {
        didSet { refreshGradientAppearance() }
    }

    enum GlimmerButtonStyle {
        case primary
        case secondary
        case destructive
        case muted

        var gradientColors: [CGColor] {
            switch self {
            case .primary:
                return ChromaticPalette.buttonGradientColors()
            case .secondary:
                return [
                    ChromaticPalette.verdantCanopy.cgColor,
                    ChromaticPalette.emeraldForest.cgColor
                ]
            case .destructive:
                return [
                    ChromaticPalette.perilRed.cgColor,
                    ChromaticPalette.coralDawn.cgColor
                ]
            case .muted:
                return [
                    ChromaticPalette.stoneGray.cgColor,
                    ChromaticPalette.stoneGray.withAlphaComponent(0.8).cgColor
                ]
            }
        }

        var textColor: UIColor {
            return .white
        }
    }

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        establishVisualHierarchy()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        establishVisualHierarchy()
    }

    convenience init(labelText: String, buttonStyle: GlimmerButtonStyle = .primary) {
        self.init(frame: .zero)
        setTitle(labelText, for: .normal)
        chromaticScheme = buttonStyle
        refreshGradientAppearance()
    }

    // MARK: - Setup
    private func establishVisualHierarchy() {
        titleLabel?.font = TypographyAtelier.buttonLabelFont
        setTitleColor(.white, for: .normal)
        setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .highlighted)

        layer.cornerRadius = DimensionalMetrics.CornerCurvature.capsular
        clipsToBounds = true

        addTarget(self, action: #selector(initiateDepressedState), for: .touchDown)
        addTarget(self, action: #selector(terminateDepressedState), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        refreshGradientAppearance()
    }

    // MARK: - Gradient Management
    private func refreshGradientAppearance() {
        gradientBackdrop?.removeFromSuperlayer()

        let newGradient = CAGradientLayer()
        newGradient.colors = chromaticScheme.gradientColors
        newGradient.startPoint = CGPoint(x: 0, y: 0)
        newGradient.endPoint = CGPoint(x: 1, y: 1)
        newGradient.frame = bounds
        newGradient.cornerRadius = layer.cornerRadius

        layer.insertSublayer(newGradient, at: 0)
        gradientBackdrop = newGradient

        applyShadowConfiguration(.moderateElevation)
    }

    // MARK: - Touch Animations
    @objc private func initiateDepressedState() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.alpha = 0.9
        }

        performHapticResponse()
    }

    @objc private func terminateDepressedState() {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.8,
            options: .curveEaseOut
        ) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }

    // MARK: - Haptic Feedback
    private func performHapticResponse() {
        guard PreferencesVault.sharedInstance.isHapticFeedbackEnabled else { return }
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.impactOccurred()
    }

    // MARK: - Shimmer Animation
    func commenceShimmerAnimation() {
        let shimmerLayer = CAGradientLayer()
        shimmerLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.4).cgColor,
            UIColor.clear.cgColor
        ]
        shimmerLayer.locations = [0, 0.5, 1]
        shimmerLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: 1, y: 0.5)
        shimmerLayer.frame = CGRect(x: -bounds.width, y: 0, width: bounds.width * 3, height: bounds.height)

        layer.addSublayer(shimmerLayer)

        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -bounds.width * 2
        animation.toValue = bounds.width * 2
        animation.duration = 2.0
        animation.repeatCount = .infinity

        shimmerLayer.add(animation, forKey: "shimmerAnimation")
    }
}

// MARK: - Circular Icon Button
final class CircularGlyphButton: UIButton {

    private var backdropCircle: CAShapeLayer?

    var glyphImage: UIImage? {
        didSet {
            setImage(glyphImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }

    var backdropChroma: UIColor = ChromaticPalette.cardSurfaceLight.withAlphaComponent(0.2) {
        didSet { refreshBackdropAppearance() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        establishVisualElements()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        establishVisualElements()
    }

    private func establishVisualElements() {
        tintColor = .white
        imageView?.contentMode = .scaleAspectFit
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        addTarget(self, action: #selector(initiateDepression), for: .touchDown)
        addTarget(self, action: #selector(terminateDepression), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
        refreshBackdropAppearance()
    }

    private func refreshBackdropAppearance() {
        backgroundColor = backdropChroma
    }

    @objc private func initiateDepression() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.alpha = 0.7
        }
    }

    @objc private func terminateDepression() {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8
        ) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
}
