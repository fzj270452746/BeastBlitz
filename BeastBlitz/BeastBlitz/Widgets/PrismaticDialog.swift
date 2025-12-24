//
//  PrismaticDialog.swift
//  BeastBlitz
//
//  Custom modal dialog with game-themed design
//

import UIKit

final class PrismaticDialog: UIView {

    // MARK: - Components
    private let dimmingBackdrop = UIView()
    private let contentVessel = GlassomorphicCard()
    private let titleInscription = UILabel()
    private let messageInscription = UILabel()
    private let actionButtonStack = UIStackView()
    private var iconEmblem: UIImageView?

    // MARK: - Callbacks
    var primaryActionHandler: (() -> Void)?
    var secondaryActionHandler: (() -> Void)?
    var dismissalHandler: (() -> Void)?

    // MARK: - Configuration
    struct DialogConfiguration {
        let titleText: String
        let messageText: String
        let primaryButtonText: String?
        let secondaryButtonText: String?
        let iconImageName: String?
        let iconTintColor: UIColor?
        let dismissOnBackgroundTap: Bool

        static func alert(title: String, message: String, confirmText: String = "OK") -> DialogConfiguration {
            return DialogConfiguration(
                titleText: title,
                messageText: message,
                primaryButtonText: confirmText,
                secondaryButtonText: nil,
                iconImageName: nil,
                iconTintColor: nil,
                dismissOnBackgroundTap: true
            )
        }

        static func confirmation(title: String, message: String, confirmText: String = "Confirm", cancelText: String = "Cancel") -> DialogConfiguration {
            return DialogConfiguration(
                titleText: title,
                messageText: message,
                primaryButtonText: confirmText,
                secondaryButtonText: cancelText,
                iconImageName: nil,
                iconTintColor: nil,
                dismissOnBackgroundTap: true
            )
        }

        static func gameOver(score: Int, isHighScore: Bool) -> DialogConfiguration {
            let message = isHighScore ? "New High Score!" : "Better luck next time!"
            return DialogConfiguration(
                titleText: "Game Over",
                messageText: "Score: \(score)\n\(message)",
                primaryButtonText: "Play Again",
                secondaryButtonText: "Home",
                iconImageName: "gamecontroller.fill",
                iconTintColor: isHighScore ? ChromaticPalette.goldenSavannah : ChromaticPalette.coralDawn,
                dismissOnBackgroundTap: false
            )
        }

        static func victory(score: Int, roundsCompleted: Int) -> DialogConfiguration {
            return DialogConfiguration(
                titleText: "Victory!",
                messageText: "Score: \(score)\nRounds: \(roundsCompleted)",
                primaryButtonText: "Continue",
                secondaryButtonText: "Home",
                iconImageName: "star.fill",
                iconTintColor: ChromaticPalette.goldenSavannah,
                dismissOnBackgroundTap: false
            )
        }
    }

    // MARK: - Initialization
    init(configuration: DialogConfiguration) {
        super.init(frame: UIScreen.main.bounds)
        establishDialogStructure(with: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func establishDialogStructure(with config: DialogConfiguration) {
        setupDimmingBackdrop(dismissOnTap: config.dismissOnBackgroundTap)
        setupContentVessel()
        setupIconEmblem(imageName: config.iconImageName, tintColor: config.iconTintColor)
        setupTitleInscription(text: config.titleText)
        setupMessageInscription(text: config.messageText)
        setupActionButtons(primary: config.primaryButtonText, secondary: config.secondaryButtonText)
    }

    private func setupDimmingBackdrop(dismissOnTap: Bool) {
        dimmingBackdrop.backgroundColor = ChromaticPalette.overlayVeil
        dimmingBackdrop.alpha = 0
        dimmingBackdrop.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dimmingBackdrop)

        NSLayoutConstraint.activate([
            dimmingBackdrop.topAnchor.constraint(equalTo: topAnchor),
            dimmingBackdrop.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmingBackdrop.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmingBackdrop.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        if dismissOnTap {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackdropTap))
            dimmingBackdrop.addGestureRecognizer(tapGesture)
        }
    }

    private func setupContentVessel() {
        contentVessel.translatesAutoresizingMaskIntoConstraints = false
        contentVessel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        contentVessel.alpha = 0
        addSubview(contentVessel)

        let horizontalPadding: CGFloat = 32
        NSLayoutConstraint.activate([
            contentVessel.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentVessel.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentVessel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: horizontalPadding),
            contentVessel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -horizontalPadding),
            contentVessel.widthAnchor.constraint(lessThanOrEqualToConstant: 320)
        ])
    }

    private func setupIconEmblem(imageName: String?, tintColor: UIColor?) {
        guard let imageName = imageName else { return }

        let emblem = UIImageView()
        emblem.image = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
        emblem.tintColor = tintColor ?? ChromaticPalette.amberSunset
        emblem.contentMode = .scaleAspectFit
        emblem.translatesAutoresizingMaskIntoConstraints = false
        contentVessel.addSubview(emblem)
        iconEmblem = emblem

        NSLayoutConstraint.activate([
            emblem.topAnchor.constraint(equalTo: contentVessel.topAnchor, constant: DimensionalMetrics.Spacing.generous),
            emblem.centerXAnchor.constraint(equalTo: contentVessel.centerXAnchor),
            emblem.widthAnchor.constraint(equalToConstant: 48),
            emblem.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupTitleInscription(text: String) {
        titleInscription.text = text
        titleInscription.font = TypographyAtelier.cardTitleFont
        titleInscription.textColor = ChromaticPalette.primaryTextLight
        titleInscription.textAlignment = .center
        titleInscription.numberOfLines = 0
        titleInscription.translatesAutoresizingMaskIntoConstraints = false
        contentVessel.addSubview(titleInscription)

        let topAnchor = iconEmblem?.bottomAnchor ?? contentVessel.topAnchor
        let topPadding: CGFloat = iconEmblem != nil ? DimensionalMetrics.Spacing.moderate : DimensionalMetrics.Spacing.generous

        NSLayoutConstraint.activate([
            titleInscription.topAnchor.constraint(equalTo: topAnchor, constant: topPadding),
            titleInscription.leadingAnchor.constraint(equalTo: contentVessel.leadingAnchor, constant: DimensionalMetrics.Spacing.generous),
            titleInscription.trailingAnchor.constraint(equalTo: contentVessel.trailingAnchor, constant: -DimensionalMetrics.Spacing.generous)
        ])
    }

    private func setupMessageInscription(text: String) {
        messageInscription.text = text
        messageInscription.font = TypographyAtelier.bodyTextFont
        messageInscription.textColor = ChromaticPalette.secondaryTextLight
        messageInscription.textAlignment = .center
        messageInscription.numberOfLines = 0
        messageInscription.translatesAutoresizingMaskIntoConstraints = false
        contentVessel.addSubview(messageInscription)

        NSLayoutConstraint.activate([
            messageInscription.topAnchor.constraint(equalTo: titleInscription.bottomAnchor, constant: DimensionalMetrics.Spacing.compact),
            messageInscription.leadingAnchor.constraint(equalTo: contentVessel.leadingAnchor, constant: DimensionalMetrics.Spacing.generous),
            messageInscription.trailingAnchor.constraint(equalTo: contentVessel.trailingAnchor, constant: -DimensionalMetrics.Spacing.generous)
        ])
    }

    private func setupActionButtons(primary: String?, secondary: String?) {
        actionButtonStack.axis = .horizontal
        actionButtonStack.spacing = DimensionalMetrics.Spacing.compact
        actionButtonStack.distribution = .fillEqually
        actionButtonStack.translatesAutoresizingMaskIntoConstraints = false
        contentVessel.addSubview(actionButtonStack)

        NSLayoutConstraint.activate([
            actionButtonStack.topAnchor.constraint(equalTo: messageInscription.bottomAnchor, constant: DimensionalMetrics.Spacing.generous),
            actionButtonStack.leadingAnchor.constraint(equalTo: contentVessel.leadingAnchor, constant: DimensionalMetrics.Spacing.generous),
            actionButtonStack.trailingAnchor.constraint(equalTo: contentVessel.trailingAnchor, constant: -DimensionalMetrics.Spacing.generous),
            actionButtonStack.bottomAnchor.constraint(equalTo: contentVessel.bottomAnchor, constant: -DimensionalMetrics.Spacing.generous),
            actionButtonStack.heightAnchor.constraint(equalToConstant: 50)
        ])

        if let secondaryText = secondary {
            let secondaryButton = GlimmeringButton(labelText: secondaryText, buttonStyle: .muted)
            secondaryButton.addTarget(self, action: #selector(handleSecondaryAction), for: .touchUpInside)
            actionButtonStack.addArrangedSubview(secondaryButton)
        }

        if let primaryText = primary {
            let primaryButton = GlimmeringButton(labelText: primaryText, buttonStyle: .primary)
            primaryButton.addTarget(self, action: #selector(handlePrimaryAction), for: .touchUpInside)
            actionButtonStack.addArrangedSubview(primaryButton)
        }
    }

    // MARK: - Presentation
    func presentAnimated(in parentView: UIView? = nil) {
        let targetView = parentView ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIWindow()
        targetView.addSubview(self)

        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.5
        ) {
            self.dimmingBackdrop.alpha = 1
            self.contentVessel.transform = .identity
            self.contentVessel.alpha = 1
        }

        commenceIconPulseAnimation()
    }

    func dismissAnimated(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25, animations: {
            self.dimmingBackdrop.alpha = 0
            self.contentVessel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.contentVessel.alpha = 0
        }) { _ in
            self.removeFromSuperview()
            completion?()
        }
    }

    // MARK: - Animations
    private func commenceIconPulseAnimation() {
        guard let icon = iconEmblem else { return }

        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.15
        pulseAnimation.duration = 0.8
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        icon.layer.add(pulseAnimation, forKey: "iconPulse")
    }

    // MARK: - Actions
    @objc private func handleBackdropTap() {
        dismissAnimated()
        dismissalHandler?()
    }

    @objc private func handlePrimaryAction() {
        dismissAnimated()
        primaryActionHandler?()
    }

    @objc private func handleSecondaryAction() {
        dismissAnimated()
        secondaryActionHandler?()
    }
}

// MARK: - Toast Notification
final class EphemeralToastNotification: UIView {

    private let messageLabel = UILabel()
    private let containerCard = GlassomorphicCard()

    init(message: String) {
        super.init(frame: .zero)
        establishToastStructure(message: message)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func establishToastStructure(message: String) {
        translatesAutoresizingMaskIntoConstraints = false

        containerCard.translatesAutoresizingMaskIntoConstraints = false
        containerCard.cardCornerRadius = DimensionalMetrics.CornerCurvature.circular
        addSubview(containerCard)

        messageLabel.text = message
        messageLabel.font = TypographyAtelier.captionTextFont
        messageLabel.textColor = ChromaticPalette.primaryTextLight
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        containerCard.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            containerCard.topAnchor.constraint(equalTo: topAnchor),
            containerCard.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerCard.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerCard.bottomAnchor.constraint(equalTo: bottomAnchor),

            messageLabel.topAnchor.constraint(equalTo: containerCard.topAnchor, constant: DimensionalMetrics.Spacing.compact),
            messageLabel.leadingAnchor.constraint(equalTo: containerCard.leadingAnchor, constant: DimensionalMetrics.Spacing.substantial),
            messageLabel.trailingAnchor.constraint(equalTo: containerCard.trailingAnchor, constant: -DimensionalMetrics.Spacing.substantial),
            messageLabel.bottomAnchor.constraint(equalTo: containerCard.bottomAnchor, constant: -DimensionalMetrics.Spacing.compact)
        ])
    }

    func displayInView(_ parentView: UIView, duration: TimeInterval = 2.0) {
        parentView.addSubview(self)
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: 20)

        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor, constant: -DimensionalMetrics.Spacing.voluminous)
        ])

        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.transform = .identity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(translationX: 0, y: -20)
            }) { _ in
                self.removeFromSuperview()
            }
        }
    }
}
