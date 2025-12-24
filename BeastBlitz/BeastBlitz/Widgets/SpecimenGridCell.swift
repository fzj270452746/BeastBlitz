//
//  SpecimenGridCell.swift
//  BeastBlitz
//
//  Animal cell for game grid display
//

import UIKit

final class SpecimenGridCell: UICollectionViewCell {

    // MARK: - Reuse Identifier
    static let reuseIdentifier = "SpecimenGridCell"

    // MARK: - Visual Components
    private let specimenImageView = UIImageView()
    private let selectionHighlightLayer = CAShapeLayer()
    private let correctIndicatorView = UIView()
    private let incorrectIndicatorView = UIView()
    private var cardBackdrop: GlassomorphicCard!

    // MARK: - State
    private(set) var isSelectedForAnswer: Bool = false
    private(set) var boundSpecimen: WildernessSpecimen?

    // MARK: - Callbacks
    var selectionToggleHandler: ((SpecimenGridCell, Bool) -> Void)?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        establishCellHierarchy()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        establishCellHierarchy()
    }

    // MARK: - Setup
    private func establishCellHierarchy() {
        cardBackdrop = GlassomorphicCard()
        cardBackdrop.translatesAutoresizingMaskIntoConstraints = false
        cardBackdrop.cardCornerRadius = DimensionalMetrics.CornerCurvature.moderate
        cardBackdrop.enableInnerGlow = false
        contentView.addSubview(cardBackdrop)

        specimenImageView.contentMode = .scaleAspectFit
        specimenImageView.translatesAutoresizingMaskIntoConstraints = false
        specimenImageView.clipsToBounds = true
        cardBackdrop.addSubview(specimenImageView)

        setupSelectionHighlight()
        setupFeedbackIndicators()
        setupInteractionGestures()

        NSLayoutConstraint.activate([
            cardBackdrop.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            cardBackdrop.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 3),
            cardBackdrop.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3),
            cardBackdrop.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),

            specimenImageView.topAnchor.constraint(equalTo: cardBackdrop.topAnchor, constant: 8),
            specimenImageView.leadingAnchor.constraint(equalTo: cardBackdrop.leadingAnchor, constant: 8),
            specimenImageView.trailingAnchor.constraint(equalTo: cardBackdrop.trailingAnchor, constant: -8),
            specimenImageView.bottomAnchor.constraint(equalTo: cardBackdrop.bottomAnchor, constant: -8)
        ])
    }

    private func setupSelectionHighlight() {
        selectionHighlightLayer.fillColor = UIColor.clear.cgColor
        selectionHighlightLayer.strokeColor = ChromaticPalette.amberSunset.cgColor
        selectionHighlightLayer.lineWidth = 3
        selectionHighlightLayer.opacity = 0
        cardBackdrop.layer.addSublayer(selectionHighlightLayer)
    }

    private func setupFeedbackIndicators() {
        correctIndicatorView.backgroundColor = ChromaticPalette.triumphGreen.withAlphaComponent(0.4)
        correctIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        correctIndicatorView.alpha = 0
        correctIndicatorView.layer.cornerRadius = DimensionalMetrics.CornerCurvature.moderate - 3
        cardBackdrop.addSubview(correctIndicatorView)

        incorrectIndicatorView.backgroundColor = ChromaticPalette.perilRed.withAlphaComponent(0.4)
        incorrectIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        incorrectIndicatorView.alpha = 0
        incorrectIndicatorView.layer.cornerRadius = DimensionalMetrics.CornerCurvature.moderate - 3
        cardBackdrop.addSubview(incorrectIndicatorView)

        NSLayoutConstraint.activate([
            correctIndicatorView.topAnchor.constraint(equalTo: cardBackdrop.topAnchor),
            correctIndicatorView.leadingAnchor.constraint(equalTo: cardBackdrop.leadingAnchor),
            correctIndicatorView.trailingAnchor.constraint(equalTo: cardBackdrop.trailingAnchor),
            correctIndicatorView.bottomAnchor.constraint(equalTo: cardBackdrop.bottomAnchor),

            incorrectIndicatorView.topAnchor.constraint(equalTo: cardBackdrop.topAnchor),
            incorrectIndicatorView.leadingAnchor.constraint(equalTo: cardBackdrop.leadingAnchor),
            incorrectIndicatorView.trailingAnchor.constraint(equalTo: cardBackdrop.trailingAnchor),
            incorrectIndicatorView.bottomAnchor.constraint(equalTo: cardBackdrop.bottomAnchor)
        ])
    }

    private func setupInteractionGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCellTap))
        cardBackdrop.addGestureRecognizer(tapGesture)
        cardBackdrop.isUserInteractionEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateSelectionHighlightPath()
    }

    private func updateSelectionHighlightPath() {
        let highlightPath = UIBezierPath(
            roundedRect: cardBackdrop.bounds.insetBy(dx: 1.5, dy: 1.5),
            cornerRadius: DimensionalMetrics.CornerCurvature.moderate - 1.5
        )
        selectionHighlightLayer.path = highlightPath.cgPath
        selectionHighlightLayer.frame = cardBackdrop.bounds
    }

    // MARK: - Configuration
    func configureWithSpecimen(_ specimen: WildernessSpecimen) {
        boundSpecimen = specimen
        specimenImageView.image = UIImage(named: specimen.visualAssetName)
        resetToNeutralState()
    }

    func resetToNeutralState() {
        isSelectedForAnswer = false
        selectionHighlightLayer.opacity = 0
        correctIndicatorView.alpha = 0
        incorrectIndicatorView.alpha = 0
        cardBackdrop.transform = .identity
        cardBackdrop.alpha = 1
    }

    // MARK: - Selection
    @objc private func handleCellTap() {
        toggleSelectionState()
        performHapticResponse()
    }

    private func toggleSelectionState() {
        isSelectedForAnswer.toggle()
        animateSelectionTransition()
        selectionToggleHandler?(self, isSelectedForAnswer)
    }

    private func animateSelectionTransition() {
        let targetOpacity: Float = isSelectedForAnswer ? 1.0 : 0.0
        let targetScale: CGFloat = isSelectedForAnswer ? 1.05 : 1.0

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5
        ) {
            self.cardBackdrop.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
        }

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = selectionHighlightLayer.opacity
        opacityAnimation.toValue = targetOpacity
        opacityAnimation.duration = 0.2
        selectionHighlightLayer.add(opacityAnimation, forKey: "opacityTransition")
        selectionHighlightLayer.opacity = targetOpacity
    }

    // MARK: - Feedback Display
    func displayCorrectFeedback() {
        UIView.animate(withDuration: 0.3) {
            self.correctIndicatorView.alpha = 1
        }

        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.15, 0.95, 1.05, 1.0]
        bounceAnimation.keyTimes = [0, 0.2, 0.4, 0.7, 1.0]
        bounceAnimation.duration = 0.4
        cardBackdrop.layer.add(bounceAnimation, forKey: "correctBounce")
    }

    func displayIncorrectFeedback() {
        UIView.animate(withDuration: 0.3) {
            self.incorrectIndicatorView.alpha = 1
        }

        let shakeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shakeAnimation.values = [0, -8, 8, -6, 6, -4, 4, 0]
        shakeAnimation.duration = 0.4
        cardBackdrop.layer.add(shakeAnimation, forKey: "incorrectShake")
    }

    func displayMissedCorrectFeedback() {
        UIView.animate(withDuration: 0.3) {
            self.correctIndicatorView.alpha = 0.6
        }

        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.fromValue = 0.3
        pulseAnimation.toValue = 0.8
        pulseAnimation.duration = 0.3
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = 2
        correctIndicatorView.layer.add(pulseAnimation, forKey: "missedPulse")
    }

    // MARK: - Haptic
    private func performHapticResponse() {
        guard PreferencesVault.sharedInstance.isHapticFeedbackEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        boundSpecimen = nil
        specimenImageView.image = nil
        resetToNeutralState()
        selectionToggleHandler = nil
    }
}
