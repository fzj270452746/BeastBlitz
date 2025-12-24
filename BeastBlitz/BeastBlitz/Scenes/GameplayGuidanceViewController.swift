//
//  GameplayGuidanceViewController.swift
//  BeastBlitz
//
//  How to play instructions screen
//

import UIKit

final class GameplayGuidanceViewController: UIViewController {

    // MARK: - Visual Components
    private var gradientBackdropLayer: CAGradientLayer!

    private let navigationBar = UIView()
    private let backButton = CircularGlyphButton()
    private let titleLabel = UILabel()

    private let scrollableContent = UIScrollView()
    private let contentStackView = UIStackView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        establishGradientBackdrop()
        constructVisualHierarchy()
        applyLayoutConstraints()
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
        populateInstructions()
    }

    private func configureNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)

        backButton.glyphImage = UIImage(systemName: "chevron.left")
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(handleBackTap), for: .touchUpInside)
        navigationBar.addSubview(backButton)

        titleLabel.text = "How to Play"
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
        contentStackView.spacing = DimensionalMetrics.Spacing.generous
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollableContent.addSubview(contentStackView)
    }

    private func populateInstructions() {
        let instructions: [(String, String, String)] = [
            ("1", "Read the Challenge", "Each round presents a challenge asking you to find specific animals. Read it carefully!"),
            ("2", "Select Animals", "Tap on all animals that match the challenge description. You can select multiple animals."),
            ("3", "Beat the Clock", "Submit your answer before time runs out! Beginner mode gives you 5 seconds, Advanced gives you 10 seconds."),
            ("4", "Build Combos", "Get 3 or more correct answers in a row to activate combo multipliers and boost your score!"),
            ("5", "Climb the Leaderboard", "Each correct round earns points. Try to beat your high score and dominate the leaderboard!")
        ]

        for (step, title, description) in instructions {
            let stepCard = createInstructionCard(step: step, title: title, description: description)
            contentStackView.addArrangedSubview(stepCard)
        }

        let gameModeSection = createGameModesSection()
        contentStackView.addArrangedSubview(gameModeSection)

        let tipsSection = createTipsSection()
        contentStackView.addArrangedSubview(tipsSection)
    }

    private func createInstructionCard(step: String, title: String, description: String) -> UIView {
        let card = GlassomorphicCard()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.cardCornerRadius = DimensionalMetrics.CornerCurvature.moderate

        let stepBadge = UIView()
        stepBadge.backgroundColor = ChromaticPalette.amberSunset
        stepBadge.layer.cornerRadius = 16
        stepBadge.translatesAutoresizingMaskIntoConstraints = false

        let stepLabel = UILabel()
        stepLabel.text = step
        stepLabel.font = TypographyAtelier.buttonLabelFont
        stepLabel.textColor = .white
        stepLabel.textAlignment = .center
        stepLabel.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = TypographyAtelier.bodyTextFont
        titleLabel.textColor = ChromaticPalette.primaryTextLight
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = TypographyAtelier.captionTextFont
        descLabel.textColor = ChromaticPalette.secondaryTextLight
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        stepBadge.addSubview(stepLabel)
        card.addSubview(stepBadge)
        card.addSubview(titleLabel)
        card.addSubview(descLabel)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),

            stepBadge.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            stepBadge.topAnchor.constraint(equalTo: card.topAnchor, constant: DimensionalMetrics.Spacing.moderate),
            stepBadge.widthAnchor.constraint(equalToConstant: 32),
            stepBadge.heightAnchor.constraint(equalToConstant: 32),

            stepLabel.centerXAnchor.constraint(equalTo: stepBadge.centerXAnchor),
            stepLabel.centerYAnchor.constraint(equalTo: stepBadge.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: stepBadge.trailingAnchor, constant: DimensionalMetrics.Spacing.compact),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: DimensionalMetrics.Spacing.moderate),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),

            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DimensionalMetrics.Spacing.diminutive),
            descLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),
            descLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -DimensionalMetrics.Spacing.moderate)
        ])

        return card
    }

    private func createGameModesSection() -> UIView {
        let sectionCard = GlassomorphicCard()
        sectionCard.translatesAutoresizingMaskIntoConstraints = false
        sectionCard.cardCornerRadius = DimensionalMetrics.CornerCurvature.moderate

        let sectionTitle = UILabel()
        sectionTitle.text = "Game Modes"
        sectionTitle.font = TypographyAtelier.cardTitleFont
        sectionTitle.textColor = ChromaticPalette.amberSunset
        sectionTitle.translatesAutoresizingMaskIntoConstraints = false

        let beginnerStack = createModeInfo(
            icon: "leaf.fill",
            iconColor: ChromaticPalette.triumphGreen,
            title: "Beginner",
            details: "4×5 Grid • 5s Timer • 10 pts/round"
        )

        let advancedStack = createModeInfo(
            icon: "flame.fill",
            iconColor: ChromaticPalette.coralDawn,
            title: "Advanced",
            details: "6×6 Grid • 10s Timer • 20 pts/round"
        )

        sectionCard.addSubview(sectionTitle)
        sectionCard.addSubview(beginnerStack)
        sectionCard.addSubview(advancedStack)

        NSLayoutConstraint.activate([
            sectionCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 140),

            sectionTitle.topAnchor.constraint(equalTo: sectionCard.topAnchor, constant: DimensionalMetrics.Spacing.moderate),
            sectionTitle.leadingAnchor.constraint(equalTo: sectionCard.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),

            beginnerStack.topAnchor.constraint(equalTo: sectionTitle.bottomAnchor, constant: DimensionalMetrics.Spacing.moderate),
            beginnerStack.leadingAnchor.constraint(equalTo: sectionCard.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            beginnerStack.trailingAnchor.constraint(equalTo: sectionCard.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),

            advancedStack.topAnchor.constraint(equalTo: beginnerStack.bottomAnchor, constant: DimensionalMetrics.Spacing.compact),
            advancedStack.leadingAnchor.constraint(equalTo: sectionCard.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            advancedStack.trailingAnchor.constraint(equalTo: sectionCard.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),
            advancedStack.bottomAnchor.constraint(equalTo: sectionCard.bottomAnchor, constant: -DimensionalMetrics.Spacing.moderate)
        ])

        return sectionCard
    }

    private func createModeInfo(icon: String, iconColor: UIColor, title: String, details: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = iconColor
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = TypographyAtelier.bodyTextFont
        titleLabel.textColor = ChromaticPalette.primaryTextLight
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let detailsLabel = UILabel()
        detailsLabel.text = details
        detailsLabel.font = TypographyAtelier.smallLabelFont
        detailsLabel.textColor = ChromaticPalette.secondaryTextLight
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(iconView)
        container.addSubview(titleLabel)
        container.addSubview(detailsLabel)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 32),

            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: DimensionalMetrics.Spacing.compact),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            detailsLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            detailsLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }

    private func createTipsSection() -> UIView {
        let card = GlassomorphicCard()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.cardCornerRadius = DimensionalMetrics.CornerCurvature.moderate

        let iconView = UIImageView(image: UIImage(systemName: "lightbulb.fill"))
        iconView.tintColor = ChromaticPalette.goldenSavannah
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Pro Tips"
        titleLabel.font = TypographyAtelier.cardTitleFont
        titleLabel.textColor = ChromaticPalette.amberSunset
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let tipsText = """
        • Learn animal traits: herbivores, carnivores, habitats
        • Don't rush! Make sure you select ALL matching animals
        • Missing an animal or selecting a wrong one ends the game
        • Combo streaks significantly boost your score
        • Practice in Beginner mode before tackling Advanced
        """

        let tipsLabel = UILabel()
        tipsLabel.text = tipsText
        tipsLabel.font = TypographyAtelier.captionTextFont
        tipsLabel.textColor = ChromaticPalette.secondaryTextLight
        tipsLabel.numberOfLines = 0
        tipsLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iconView)
        card.addSubview(titleLabel)
        card.addSubview(tipsLabel)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: card.topAnchor, constant: DimensionalMetrics.Spacing.moderate),
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: DimensionalMetrics.Spacing.compact),

            tipsLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: DimensionalMetrics.Spacing.moderate),
            tipsLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            tipsLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),
            tipsLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -DimensionalMetrics.Spacing.moderate)
        ])

        return card
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

    // MARK: - Actions
    @objc private func handleBackTap() {
        dismiss(animated: true)
    }

    // MARK: - Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
