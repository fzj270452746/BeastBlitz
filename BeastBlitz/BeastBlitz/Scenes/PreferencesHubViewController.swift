//
//  PreferencesHubViewController.swift
//  BeastBlitz
//
//  Settings screen with app preferences
//

import UIKit
import StoreKit

final class PreferencesHubViewController: UIViewController {

    // MARK: - Visual Components
    private var gradientBackdropLayer: CAGradientLayer!

    private let navigationBar = UIView()
    private let backButton = CircularGlyphButton()
    private let titleLabel = UILabel()

    private let scrollableContent = UIScrollView()
    private let contentStackView = UIStackView()

    // Setting Cards
    private let playerNameCard = GlassomorphicCard()
    private let soundToggleCard = GlassomorphicCard()
    private let hapticToggleCard = GlassomorphicCard()
    private let rateAppCard = GlassomorphicCard()
    private let feedbackCard = GlassomorphicCard()
    private let resetDataCard = GlassomorphicCard()
    private let versionCard = GlassomorphicCard()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        establishGradientBackdrop()
        constructVisualHierarchy()
        applyLayoutConstraints()
        loadCurrentSettings()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientBackdropLayer.frame = view.bounds
    }

    // MARK: - Setup
    private func establishGradientBackdrop() {
        gradientBackdropLayer = GradientBackdropFactory.fabricateJungleGradient(forBounds: view.bounds)
        view.layer.insertSublayer(gradientBackdropLayer, at: 0)
    }

    private func constructVisualHierarchy() {
        configureNavigationBar()
        configureScrollableContent()
        configureSettingsCards()
    }

    private func configureNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)

        backButton.glyphImage = UIImage(systemName: "chevron.left")
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(handleBackTap), for: .touchUpInside)
        navigationBar.addSubview(backButton)

        titleLabel.text = "Settings"
        titleLabel.font = TypographyAtelier.cardTitleFont
        titleLabel.textColor = ChromaticPalette.primaryTextLight
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(titleLabel)
    }

    private func configureScrollableContent() {
        scrollableContent.translatesAutoresizingMaskIntoConstraints = false
        scrollableContent.showsVerticalScrollIndicator = false
        view.addSubview(scrollableContent)

        contentStackView.axis = .vertical
        contentStackView.spacing = DimensionalMetrics.Spacing.moderate
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollableContent.addSubview(contentStackView)
    }

    private func configureSettingsCards() {
        configurePlayerNameCard()
        configureSoundToggleCard()
        configureHapticToggleCard()
        configureRateAppCard()
        configureFeedbackCard()
        configureResetDataCard()
        configureVersionCard()

        contentStackView.addArrangedSubview(playerNameCard)
        contentStackView.addArrangedSubview(soundToggleCard)
        contentStackView.addArrangedSubview(hapticToggleCard)
        contentStackView.addArrangedSubview(rateAppCard)
        contentStackView.addArrangedSubview(feedbackCard)
        contentStackView.addArrangedSubview(resetDataCard)
        contentStackView.addArrangedSubview(versionCard)
    }

    private func configurePlayerNameCard() {
        playerNameCard.translatesAutoresizingMaskIntoConstraints = false
        playerNameCard.cardCornerRadius = DimensionalMetrics.CornerCurvature.moderate

        let iconView = UIImageView(image: UIImage(systemName: "person.fill"))
        iconView.tintColor = ChromaticPalette.amberSunset
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Player Name"
        titleLabel.font = TypographyAtelier.bodyTextFont
        titleLabel.textColor = ChromaticPalette.primaryTextLight
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let nameField = UITextField()
        nameField.text = PreferencesVault.sharedInstance.contestantMoniker
        nameField.font = TypographyAtelier.captionTextFont
        nameField.textColor = ChromaticPalette.secondaryTextLight
        nameField.textAlignment = .right
        nameField.tag = 100
        nameField.delegate = self
        nameField.returnKeyType = .done
        nameField.translatesAutoresizingMaskIntoConstraints = false

        playerNameCard.addSubview(iconView)
        playerNameCard.addSubview(titleLabel)
        playerNameCard.addSubview(nameField)

        NSLayoutConstraint.activate([
            playerNameCard.heightAnchor.constraint(equalToConstant: 60),

            iconView.leadingAnchor.constraint(equalTo: playerNameCard.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            iconView.centerYAnchor.constraint(equalTo: playerNameCard.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: DimensionalMetrics.Spacing.compact),
            titleLabel.centerYAnchor.constraint(equalTo: playerNameCard.centerYAnchor),

            nameField.trailingAnchor.constraint(equalTo: playerNameCard.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),
            nameField.centerYAnchor.constraint(equalTo: playerNameCard.centerYAnchor),
            nameField.widthAnchor.constraint(equalToConstant: 120)
        ])
    }

    private func configureSoundToggleCard() {
        soundToggleCard.translatesAutoresizingMaskIntoConstraints = false
        soundToggleCard.cardCornerRadius = DimensionalMetrics.CornerCurvature.moderate

        let iconView = UIImageView(image: UIImage(systemName: "speaker.wave.2.fill"))
        iconView.tintColor = ChromaticPalette.amberSunset
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Sound Effects"
        titleLabel.font = TypographyAtelier.bodyTextFont
        titleLabel.textColor = ChromaticPalette.primaryTextLight
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let toggle = UISwitch()
        toggle.onTintColor = ChromaticPalette.verdantCanopy
        toggle.tag = 101
        toggle.addTarget(self, action: #selector(handleSoundToggle(_:)), for: .valueChanged)
        toggle.translatesAutoresizingMaskIntoConstraints = false

        soundToggleCard.addSubview(iconView)
        soundToggleCard.addSubview(titleLabel)
        soundToggleCard.addSubview(toggle)

        NSLayoutConstraint.activate([
            soundToggleCard.heightAnchor.constraint(equalToConstant: 60),

            iconView.leadingAnchor.constraint(equalTo: soundToggleCard.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            iconView.centerYAnchor.constraint(equalTo: soundToggleCard.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: DimensionalMetrics.Spacing.compact),
            titleLabel.centerYAnchor.constraint(equalTo: soundToggleCard.centerYAnchor),

            toggle.trailingAnchor.constraint(equalTo: soundToggleCard.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),
            toggle.centerYAnchor.constraint(equalTo: soundToggleCard.centerYAnchor)
        ])
    }

    private func configureHapticToggleCard() {
        hapticToggleCard.translatesAutoresizingMaskIntoConstraints = false
        hapticToggleCard.cardCornerRadius = DimensionalMetrics.CornerCurvature.moderate

        let iconView = UIImageView(image: UIImage(systemName: "hand.tap.fill"))
        iconView.tintColor = ChromaticPalette.amberSunset
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Haptic Feedback"
        titleLabel.font = TypographyAtelier.bodyTextFont
        titleLabel.textColor = ChromaticPalette.primaryTextLight
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let toggle = UISwitch()
        toggle.onTintColor = ChromaticPalette.verdantCanopy
        toggle.tag = 102
        toggle.addTarget(self, action: #selector(handleHapticToggle(_:)), for: .valueChanged)
        toggle.translatesAutoresizingMaskIntoConstraints = false

        hapticToggleCard.addSubview(iconView)
        hapticToggleCard.addSubview(titleLabel)
        hapticToggleCard.addSubview(toggle)

        NSLayoutConstraint.activate([
            hapticToggleCard.heightAnchor.constraint(equalToConstant: 60),

            iconView.leadingAnchor.constraint(equalTo: hapticToggleCard.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            iconView.centerYAnchor.constraint(equalTo: hapticToggleCard.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: DimensionalMetrics.Spacing.compact),
            titleLabel.centerYAnchor.constraint(equalTo: hapticToggleCard.centerYAnchor),

            toggle.trailingAnchor.constraint(equalTo: hapticToggleCard.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),
            toggle.centerYAnchor.constraint(equalTo: hapticToggleCard.centerYAnchor)
        ])
    }

    private func configureRateAppCard() {
        rateAppCard.translatesAutoresizingMaskIntoConstraints = false
        rateAppCard.cardCornerRadius = DimensionalMetrics.CornerCurvature.moderate

        let iconView = UIImageView(image: UIImage(systemName: "star.fill"))
        iconView.tintColor = ChromaticPalette.goldenSavannah
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Rate App"
        titleLabel.font = TypographyAtelier.bodyTextFont
        titleLabel.textColor = ChromaticPalette.primaryTextLight
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = ChromaticPalette.stoneGray
        chevron.translatesAutoresizingMaskIntoConstraints = false

        rateAppCard.addSubview(iconView)
        rateAppCard.addSubview(titleLabel)
        rateAppCard.addSubview(chevron)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRateAppTap))
        rateAppCard.addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            rateAppCard.heightAnchor.constraint(equalToConstant: 60),

            iconView.leadingAnchor.constraint(equalTo: rateAppCard.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            iconView.centerYAnchor.constraint(equalTo: rateAppCard.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: DimensionalMetrics.Spacing.compact),
            titleLabel.centerYAnchor.constraint(equalTo: rateAppCard.centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: rateAppCard.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),
            chevron.centerYAnchor.constraint(equalTo: rateAppCard.centerYAnchor)
        ])
    }

    private func configureFeedbackCard() {
        feedbackCard.translatesAutoresizingMaskIntoConstraints = false
        feedbackCard.cardCornerRadius = DimensionalMetrics.CornerCurvature.moderate

        let iconView = UIImageView(image: UIImage(systemName: "envelope.fill"))
        iconView.tintColor = ChromaticPalette.amberSunset
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Send Feedback"
        titleLabel.font = TypographyAtelier.bodyTextFont
        titleLabel.textColor = ChromaticPalette.primaryTextLight
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = ChromaticPalette.stoneGray
        chevron.translatesAutoresizingMaskIntoConstraints = false

        feedbackCard.addSubview(iconView)
        feedbackCard.addSubview(titleLabel)
        feedbackCard.addSubview(chevron)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFeedbackTap))
        feedbackCard.addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            feedbackCard.heightAnchor.constraint(equalToConstant: 60),

            iconView.leadingAnchor.constraint(equalTo: feedbackCard.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            iconView.centerYAnchor.constraint(equalTo: feedbackCard.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: DimensionalMetrics.Spacing.compact),
            titleLabel.centerYAnchor.constraint(equalTo: feedbackCard.centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: feedbackCard.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),
            chevron.centerYAnchor.constraint(equalTo: feedbackCard.centerYAnchor)
        ])
    }

    private func configureResetDataCard() {
        resetDataCard.translatesAutoresizingMaskIntoConstraints = false
        resetDataCard.cardCornerRadius = DimensionalMetrics.CornerCurvature.moderate

        let iconView = UIImageView(image: UIImage(systemName: "trash.fill"))
        iconView.tintColor = ChromaticPalette.perilRed
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Reset All Data"
        titleLabel.font = TypographyAtelier.bodyTextFont
        titleLabel.textColor = ChromaticPalette.perilRed
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        resetDataCard.addSubview(iconView)
        resetDataCard.addSubview(titleLabel)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleResetDataTap))
        resetDataCard.addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            resetDataCard.heightAnchor.constraint(equalToConstant: 60),

            iconView.leadingAnchor.constraint(equalTo: resetDataCard.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            iconView.centerYAnchor.constraint(equalTo: resetDataCard.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: DimensionalMetrics.Spacing.compact),
            titleLabel.centerYAnchor.constraint(equalTo: resetDataCard.centerYAnchor)
        ])
    }

    private func configureVersionCard() {
        versionCard.translatesAutoresizingMaskIntoConstraints = false
        versionCard.cardCornerRadius = DimensionalMetrics.CornerCurvature.moderate
        versionCard.enableInnerGlow = false

        let titleLabel = UILabel()
        titleLabel.text = "Beast Blitz"
        titleLabel.font = TypographyAtelier.bodyTextFont
        titleLabel.textColor = ChromaticPalette.secondaryTextLight
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let versionLabel = UILabel()
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        versionLabel.text = "Version \(version)"
        versionLabel.font = TypographyAtelier.smallLabelFont
        versionLabel.textColor = ChromaticPalette.stoneGray
        versionLabel.textAlignment = .center
        versionLabel.translatesAutoresizingMaskIntoConstraints = false

        versionCard.addSubview(titleLabel)
        versionCard.addSubview(versionLabel)

        NSLayoutConstraint.activate([
            versionCard.heightAnchor.constraint(equalToConstant: 70),

            titleLabel.centerXAnchor.constraint(equalTo: versionCard.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: versionCard.topAnchor, constant: DimensionalMetrics.Spacing.moderate),

            versionLabel.centerXAnchor.constraint(equalTo: versionCard.centerXAnchor),
            versionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])
    }

    // MARK: - Layout
    private func applyLayoutConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: DimensionalMetrics.Spacing.moderate),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),
            navigationBar.heightAnchor.constraint(equalToConstant: 50),

            backButton.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),

            scrollableContent.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: DimensionalMetrics.Spacing.generous),
            scrollableContent.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollableContent.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollableContent.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollableContent.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollableContent.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            contentStackView.trailingAnchor.constraint(equalTo: scrollableContent.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),
            contentStackView.bottomAnchor.constraint(equalTo: scrollableContent.bottomAnchor, constant: -DimensionalMetrics.Spacing.voluminous),
            contentStackView.widthAnchor.constraint(equalTo: scrollableContent.widthAnchor, constant: -DimensionalMetrics.Spacing.moderate * 2)
        ])
    }

    // MARK: - Data Loading
    private func loadCurrentSettings() {
        let preferences = PreferencesVault.sharedInstance

        if let soundToggle = soundToggleCard.viewWithTag(101) as? UISwitch {
            soundToggle.isOn = preferences.isSoundEffectsEnabled
        }

        if let hapticToggle = hapticToggleCard.viewWithTag(102) as? UISwitch {
            hapticToggle.isOn = preferences.isHapticFeedbackEnabled
        }
    }

    // MARK: - Actions
    @objc private func handleBackTap() {
        dismiss(animated: true)
    }

    @objc private func handleSoundToggle(_ sender: UISwitch) {
        PreferencesVault.sharedInstance.isSoundEffectsEnabled = sender.isOn
    }

    @objc private func handleHapticToggle(_ sender: UISwitch) {
        PreferencesVault.sharedInstance.isHapticFeedbackEnabled = sender.isOn
    }

    @objc private func handleRateAppTap() {
        if let windowScene = view.window?.windowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    @objc private func handleFeedbackTap() {
        let feedbackController = FeedbackSubmissionViewController()
        feedbackController.modalPresentationStyle = .fullScreen
        feedbackController.modalTransitionStyle = .crossDissolve
        present(feedbackController, animated: true)
    }

    @objc private func handleResetDataTap() {
        let dialog = PrismaticDialog(configuration: .confirmation(
            title: "Reset All Data?",
            message: "This will delete all your scores and progress. This cannot be undone.",
            confirmText: "Reset",
            cancelText: "Cancel"
        ))

        dialog.primaryActionHandler = { [weak self] in
            TriumphChronicleVault.sharedInstance.obliterateAllRecords()
            let toast = EphemeralToastNotification(message: "All data has been reset")
            toast.displayInView(self?.view ?? UIView())
        }

        dialog.presentAnimated(in: view)
    }

    // MARK: - Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - UITextFieldDelegate
extension PreferencesHubViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 100 {
            let newName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Player"
            PreferencesVault.sharedInstance.contestantMoniker = newName.isEmpty ? "Player" : newName
        }
    }
}
