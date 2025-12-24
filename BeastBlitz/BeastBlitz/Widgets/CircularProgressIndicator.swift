//
//  CircularProgressIndicator.swift
//  BeastBlitz
//
//  Animated circular timer display
//

import UIKit

final class CircularProgressIndicator: UIView {

    // MARK: - Layer Properties
    private var backgroundTrackLayer: CAShapeLayer!
    private var progressArcLayer: CAShapeLayer!
    private var glowEffectLayer: CAShapeLayer!
    private let timeDisplayLabel = UILabel()

    // MARK: - Configuration
    var trackWidth: CGFloat = 8 {
        didSet { reconstructLayerHierarchy() }
    }

    var trackBackgroundChroma: UIColor = UIColor.white.withAlphaComponent(0.2) {
        didSet { backgroundTrackLayer?.strokeColor = trackBackgroundChroma.cgColor }
    }

    var progressGradientColors: [UIColor] = [ChromaticPalette.triumphGreen, ChromaticPalette.verdantCanopy] {
        didSet { applyGradientToProgress() }
    }

    var currentProgressValue: CGFloat = 1.0 {
        didSet { updateProgressPresentation(animated: false) }
    }

    var displayedTimeText: String = "" {
        didSet { timeDisplayLabel.text = displayedTimeText }
    }

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        establishIndicatorStructure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        establishIndicatorStructure()
    }

    // MARK: - Setup
    private func establishIndicatorStructure() {
        backgroundColor = .clear
        reconstructLayerHierarchy()
        setupTimeDisplayLabel()
    }

    private func reconstructLayerHierarchy() {
        backgroundTrackLayer?.removeFromSuperlayer()
        progressArcLayer?.removeFromSuperlayer()
        glowEffectLayer?.removeFromSuperlayer()

        let circularPath = createCircularPath()

        backgroundTrackLayer = CAShapeLayer()
        backgroundTrackLayer.path = circularPath.cgPath
        backgroundTrackLayer.fillColor = UIColor.clear.cgColor
        backgroundTrackLayer.strokeColor = trackBackgroundChroma.cgColor
        backgroundTrackLayer.lineWidth = trackWidth
        backgroundTrackLayer.lineCap = .round
        layer.addSublayer(backgroundTrackLayer)

        glowEffectLayer = CAShapeLayer()
        glowEffectLayer.path = circularPath.cgPath
        glowEffectLayer.fillColor = UIColor.clear.cgColor
        glowEffectLayer.strokeColor = progressGradientColors.first?.cgColor
        glowEffectLayer.lineWidth = trackWidth + 4
        glowEffectLayer.lineCap = .round
        glowEffectLayer.strokeEnd = currentProgressValue
        glowEffectLayer.shadowColor = progressGradientColors.first?.cgColor
        glowEffectLayer.shadowRadius = 8
        glowEffectLayer.shadowOpacity = 0.6
        glowEffectLayer.shadowOffset = .zero
        layer.addSublayer(glowEffectLayer)

        progressArcLayer = CAShapeLayer()
        progressArcLayer.path = circularPath.cgPath
        progressArcLayer.fillColor = UIColor.clear.cgColor
        progressArcLayer.strokeColor = progressGradientColors.first?.cgColor
        progressArcLayer.lineWidth = trackWidth
        progressArcLayer.lineCap = .round
        progressArcLayer.strokeEnd = currentProgressValue
        layer.addSublayer(progressArcLayer)

        applyGradientToProgress()
    }

    private func createCircularPath() -> UIBezierPath {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = (min(bounds.width, bounds.height) - trackWidth) / 2
        return UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: 3 * CGFloat.pi / 2,
            clockwise: true
        )
    }

    private func setupTimeDisplayLabel() {
        timeDisplayLabel.font = TypographyAtelier.timerDisplayFont
        timeDisplayLabel.textColor = ChromaticPalette.primaryTextLight
        timeDisplayLabel.textAlignment = .center
        timeDisplayLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(timeDisplayLabel)

        NSLayoutConstraint.activate([
            timeDisplayLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeDisplayLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        reconstructLayerHierarchy()
    }

    // MARK: - Progress Updates
    func updateProgressPresentation(animated: Bool, duration: TimeInterval = 0.3) {
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressArcLayer.strokeEnd
            animation.toValue = currentProgressValue
            animation.duration = duration
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            progressArcLayer.add(animation, forKey: "progressAnimation")
            glowEffectLayer.add(animation, forKey: "glowProgressAnimation")
        }

        progressArcLayer.strokeEnd = currentProgressValue
        glowEffectLayer.strokeEnd = currentProgressValue

        updateColorBasedOnProgress()
    }

    private func updateColorBasedOnProgress() {
        let progressColor: UIColor
        if currentProgressValue > 0.5 {
            progressColor = ChromaticPalette.triumphGreen
        } else if currentProgressValue > 0.25 {
            progressColor = ChromaticPalette.cautionAmber
        } else {
            progressColor = ChromaticPalette.perilRed
        }

        progressArcLayer.strokeColor = progressColor.cgColor
        glowEffectLayer.strokeColor = progressColor.cgColor
        glowEffectLayer.shadowColor = progressColor.cgColor
    }

    private func applyGradientToProgress() {
        // Gradient effect simulation through color transition
    }

    // MARK: - Warning Animation
    func commenceWarningPulsation() {
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 0.5
        pulseAnimation.duration = 0.3
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity

        progressArcLayer.add(pulseAnimation, forKey: "warningPulse")
        glowEffectLayer.add(pulseAnimation, forKey: "glowWarningPulse")

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.05
        scaleAnimation.duration = 0.3
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = .infinity

        timeDisplayLabel.layer.add(scaleAnimation, forKey: "labelPulse")
    }

    func ceaseWarningPulsation() {
        progressArcLayer.removeAnimation(forKey: "warningPulse")
        glowEffectLayer.removeAnimation(forKey: "glowWarningPulse")
        timeDisplayLabel.layer.removeAnimation(forKey: "labelPulse")
    }
}
