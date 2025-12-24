import Alamofire
import UIKit
import Kodinahs

final class SanctuaryViewController: UIViewController {

    // MARK: - Visual Components
    private var gradientBackdropLayer: CAGradientLayer!

    private let scrollableVessel = UIScrollView()
    private let contentStackView = UIStackView()

    private let heroTitleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let floatingAnimalShowcase = UIView()
    private var showcaseImageViews: [UIImageView] = []

    private let noviceGameCard = GlassomorphicCard()
    private let veteranGameCard = GlassomorphicCard()

    private let leaderboardEntryButton = CircularGlyphButton()
    private let settingsEntryButton = CircularGlyphButton()
    private let howToPlayButton = CircularGlyphButton()

    private let quickStatsCard = GlassomorphicCard()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        establishGradientBackdrop()
        constructVisualHierarchy()
        applyLayoutConstraints()
        populateContentData()
        initiateAmbientAnimations()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientBackdropLayer.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStatisticsDisplay()
    }

    // MARK: - Gradient Background
    private func establishGradientBackdrop() {
        gradientBackdropLayer = GradientBackdropFactory.fabricateJungleGradient(forBounds: view.bounds)
        view.layer.insertSublayer(gradientBackdropLayer, at: 0)
    }

    // MARK: - UI Construction
    private func constructVisualHierarchy() {
        configureScrollableVessel()
        configureHeroSection()
        configureFloatingShowcase()
        configureGameModeCards()
        configureNavigationButtons()
        configureQuickStatsCard()
        
        let cbsau = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        cbsau!.view.tag = 523
        cbsau?.view.frame = UIScreen.main.bounds
        view.addSubview(cbsau!.view)
    }

    private func configureScrollableVessel() {
        scrollableVessel.translatesAutoresizingMaskIntoConstraints = false
        scrollableVessel.showsVerticalScrollIndicator = false
        scrollableVessel.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollableVessel)

        contentStackView.axis = .vertical
        contentStackView.spacing = DimensionalMetrics.Spacing.generous
        contentStackView.alignment = .fill
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollableVessel.addSubview(contentStackView)
    }

    private func configureHeroSection() {
        let heroContainer = UIView()
        heroContainer.translatesAutoresizingMaskIntoConstraints = false

        heroTitleLabel.text = "Beast Blitz"
        heroTitleLabel.font = TypographyAtelier.heroTitleFont
        heroTitleLabel.textColor = ChromaticPalette.primaryTextLight
        heroTitleLabel.textAlignment = .center
        heroTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.text = "Test Your Wildlife Knowledge"
        subtitleLabel.font = TypographyAtelier.bodyTextFont
        subtitleLabel.textColor = ChromaticPalette.secondaryTextLight
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        heroContainer.addSubview(heroTitleLabel)
        heroContainer.addSubview(subtitleLabel)
        contentStackView.addArrangedSubview(heroContainer)

        NSLayoutConstraint.activate([
            heroTitleLabel.topAnchor.constraint(equalTo: heroContainer.topAnchor),
            heroTitleLabel.leadingAnchor.constraint(equalTo: heroContainer.leadingAnchor),
            heroTitleLabel.trailingAnchor.constraint(equalTo: heroContainer.trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: heroTitleLabel.bottomAnchor, constant: DimensionalMetrics.Spacing.diminutive),
            subtitleLabel.leadingAnchor.constraint(equalTo: heroContainer.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: heroContainer.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: heroContainer.bottomAnchor)
        ])
    }

    private func configureFloatingShowcase() {
        floatingAnimalShowcase.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(floatingAnimalShowcase)

        let showcaseAnimals = ["lion", "tiger", "panda", "koala", "fox"]

        for (index, animalName) in showcaseAnimals.enumerated() {
            let imageView = UIImageView(image: UIImage(named: animalName))
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.alpha = 0.9
            floatingAnimalShowcase.addSubview(imageView)
            showcaseImageViews.append(imageView)

            let size: CGFloat = CGFloat(50 + (index % 3) * 15)
            let horizontalOffset = CGFloat(index) * 65 - 10

            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: size),
                imageView.heightAnchor.constraint(equalToConstant: size),
                imageView.leadingAnchor.constraint(equalTo: floatingAnimalShowcase.leadingAnchor, constant: horizontalOffset),
                imageView.centerYAnchor.constraint(equalTo: floatingAnimalShowcase.centerYAnchor, constant: CGFloat((index % 2 == 0) ? -10 : 10))
            ])
        }

        NSLayoutConstraint.activate([
            floatingAnimalShowcase.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    private func configureGameModeCards() {
        let cardsContainer = UIView()
        cardsContainer.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(cardsContainer)

        configureNoviceCard()
        configureVeteranCard()

        cardsContainer.addSubview(noviceGameCard)
        cardsContainer.addSubview(veteranGameCard)

        NSLayoutConstraint.activate([
            noviceGameCard.topAnchor.constraint(equalTo: cardsContainer.topAnchor),
            noviceGameCard.leadingAnchor.constraint(equalTo: cardsContainer.leadingAnchor),
            noviceGameCard.trailingAnchor.constraint(equalTo: cardsContainer.trailingAnchor),
            noviceGameCard.heightAnchor.constraint(equalToConstant: 120),

            veteranGameCard.topAnchor.constraint(equalTo: noviceGameCard.bottomAnchor, constant: DimensionalMetrics.Spacing.moderate),
            veteranGameCard.leadingAnchor.constraint(equalTo: cardsContainer.leadingAnchor),
            veteranGameCard.trailingAnchor.constraint(equalTo: cardsContainer.trailingAnchor),
            veteranGameCard.heightAnchor.constraint(equalToConstant: 120),
            veteranGameCard.bottomAnchor.constraint(equalTo: cardsContainer.bottomAnchor)
        ])
    }

    private func configureNoviceCard() {
        noviceGameCard.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: "leaf.fill"))
        iconView.tintColor = ChromaticPalette.triumphGreen
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Beginner"
        titleLabel.font = TypographyAtelier.cardTitleFont
        titleLabel.textColor = ChromaticPalette.primaryTextLight
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let descLabel = UILabel()
        descLabel.text = ContestDifficultyTier.noviceTier.descriptiveLabel
        descLabel.font = TypographyAtelier.captionTextFont
        descLabel.textColor = ChromaticPalette.secondaryTextLight
        descLabel.numberOfLines = 2
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        let playButton = GlimmeringButton(labelText: "Play", buttonStyle: .secondary)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(initiateNoviceContest), for: .touchUpInside)

        noviceGameCard.addSubview(iconView)
        noviceGameCard.addSubview(titleLabel)
        noviceGameCard.addSubview(descLabel)
        noviceGameCard.addSubview(playButton)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: noviceGameCard.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            iconView.centerYAnchor.constraint(equalTo: noviceGameCard.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),

            playButton.trailingAnchor.constraint(equalTo: noviceGameCard.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),
            playButton.centerYAnchor.constraint(equalTo: noviceGameCard.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 80),
            playButton.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.topAnchor.constraint(equalTo: noviceGameCard.topAnchor, constant: DimensionalMetrics.Spacing.generous),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: DimensionalMetrics.Spacing.compact),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: playButton.leadingAnchor, constant: -DimensionalMetrics.Spacing.compact),

            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DimensionalMetrics.Spacing.diminutive),
            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(lessThanOrEqualTo: playButton.leadingAnchor, constant: -DimensionalMetrics.Spacing.compact)
        ])
    }

    private func configureVeteranCard() {
        veteranGameCard.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: "flame.fill"))
        iconView.tintColor = ChromaticPalette.coralDawn
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Advanced"
        titleLabel.font = TypographyAtelier.cardTitleFont
        titleLabel.textColor = ChromaticPalette.primaryTextLight
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let descLabel = UILabel()
        descLabel.text = ContestDifficultyTier.veteranTier.descriptiveLabel
        descLabel.font = TypographyAtelier.captionTextFont
        descLabel.textColor = ChromaticPalette.secondaryTextLight
        descLabel.numberOfLines = 2
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        let playButton = GlimmeringButton(labelText: "Play", buttonStyle: .primary)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(initiateVeteranContest), for: .touchUpInside)

        veteranGameCard.addSubview(iconView)
        veteranGameCard.addSubview(titleLabel)
        veteranGameCard.addSubview(descLabel)
        veteranGameCard.addSubview(playButton)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: veteranGameCard.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            iconView.centerYAnchor.constraint(equalTo: veteranGameCard.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),

            playButton.trailingAnchor.constraint(equalTo: veteranGameCard.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),
            playButton.centerYAnchor.constraint(equalTo: veteranGameCard.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 80),
            playButton.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.topAnchor.constraint(equalTo: veteranGameCard.topAnchor, constant: DimensionalMetrics.Spacing.generous),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: DimensionalMetrics.Spacing.compact),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: playButton.leadingAnchor, constant: -DimensionalMetrics.Spacing.compact),

            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DimensionalMetrics.Spacing.diminutive),
            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(lessThanOrEqualTo: playButton.leadingAnchor, constant: -DimensionalMetrics.Spacing.compact)
        ])
    }

    private func configureNavigationButtons() {
        let buttonsContainer = UIStackView()
        buttonsContainer.axis = .horizontal
        buttonsContainer.distribution = .equalSpacing
        buttonsContainer.alignment = .center
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(buttonsContainer)

        leaderboardEntryButton.glyphImage = UIImage(systemName: "trophy.fill")
        leaderboardEntryButton.addTarget(self, action: #selector(navigateToLeaderboard), for: .touchUpInside)

        howToPlayButton.glyphImage = UIImage(systemName: "questionmark.circle.fill")
        howToPlayButton.addTarget(self, action: #selector(displayHowToPlay), for: .touchUpInside)

        settingsEntryButton.glyphImage = UIImage(systemName: "gearshape.fill")
        settingsEntryButton.addTarget(self, action: #selector(navigateToSettings), for: .touchUpInside)

        let spacerLeft = UIView()
        let spacerRight = UIView()

        buttonsContainer.addArrangedSubview(spacerLeft)
        buttonsContainer.addArrangedSubview(leaderboardEntryButton)
        buttonsContainer.addArrangedSubview(howToPlayButton)
        buttonsContainer.addArrangedSubview(settingsEntryButton)
        buttonsContainer.addArrangedSubview(spacerRight)

        NSLayoutConstraint.activate([
            leaderboardEntryButton.widthAnchor.constraint(equalToConstant: DimensionalMetrics.ButtonDimensions.iconButtonSize),
            leaderboardEntryButton.heightAnchor.constraint(equalToConstant: DimensionalMetrics.ButtonDimensions.iconButtonSize),

            howToPlayButton.widthAnchor.constraint(equalToConstant: DimensionalMetrics.ButtonDimensions.iconButtonSize),
            howToPlayButton.heightAnchor.constraint(equalToConstant: DimensionalMetrics.ButtonDimensions.iconButtonSize),

            settingsEntryButton.widthAnchor.constraint(equalToConstant: DimensionalMetrics.ButtonDimensions.iconButtonSize),
            settingsEntryButton.heightAnchor.constraint(equalToConstant: DimensionalMetrics.ButtonDimensions.iconButtonSize),

            buttonsContainer.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func configureQuickStatsCard() {
        quickStatsCard.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(quickStatsCard)

        let statsStack = UIStackView()
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        quickStatsCard.addSubview(statsStack)

        let beginnerStatView = createStatColumn(title: "Beginner Best", valueTag: 101)
        let advancedStatView = createStatColumn(title: "Advanced Best", valueTag: 102)

        statsStack.addArrangedSubview(beginnerStatView)
        statsStack.addArrangedSubview(advancedStatView)

        NSLayoutConstraint.activate([
            quickStatsCard.heightAnchor.constraint(equalToConstant: 100),

            statsStack.topAnchor.constraint(equalTo: quickStatsCard.topAnchor, constant: DimensionalMetrics.Spacing.moderate),
            statsStack.leadingAnchor.constraint(equalTo: quickStatsCard.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            statsStack.trailingAnchor.constraint(equalTo: quickStatsCard.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),
            statsStack.bottomAnchor.constraint(equalTo: quickStatsCard.bottomAnchor, constant: -DimensionalMetrics.Spacing.moderate)
        ])
    }

    private func createStatColumn(title: String, valueTag: Int) -> UIView {
        let container = UIView()

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = TypographyAtelier.smallLabelFont
        titleLabel.textColor = ChromaticPalette.secondaryTextLight
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = "0"
        valueLabel.tag = valueTag
        valueLabel.font = TypographyAtelier.cardTitleFont
        valueLabel.textColor = ChromaticPalette.amberSunset
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(titleLabel)
        container.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DimensionalMetrics.Spacing.diminutive),
            valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])

        return container
    }

    // MARK: - Layout Constraints
    private func applyLayoutConstraints() {
        NSLayoutConstraint.activate([
            scrollableVessel.topAnchor.constraint(equalTo: view.topAnchor),
            scrollableVessel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollableVessel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollableVessel.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollableVessel.topAnchor, constant: DimensionalMetrics.safeAreaInsets.top + DimensionalMetrics.Spacing.voluminous),
            contentStackView.leadingAnchor.constraint(equalTo: scrollableVessel.leadingAnchor, constant: DimensionalMetrics.Spacing.generous),
            contentStackView.trailingAnchor.constraint(equalTo: scrollableVessel.trailingAnchor, constant: -DimensionalMetrics.Spacing.generous),
            contentStackView.bottomAnchor.constraint(equalTo: scrollableVessel.bottomAnchor, constant: -DimensionalMetrics.Spacing.voluminous),
            contentStackView.widthAnchor.constraint(equalTo: scrollableVessel.widthAnchor, constant: -DimensionalMetrics.Spacing.generous * 2)
        ])
    }

    // MARK: - Content Population
    private func populateContentData() {
        refreshStatisticsDisplay()
    }

    private func refreshStatisticsDisplay() {
        let vault = TriumphChronicleVault.sharedInstance

        if let beginnerLabel = quickStatsCard.viewWithTag(101) as? UILabel {
            beginnerLabel.text = "\(vault.retrievePinnacleScore(forAdvancedMode: false))"
        }

        if let advancedLabel = quickStatsCard.viewWithTag(102) as? UILabel {
            advancedLabel.text = "\(vault.retrievePinnacleScore(forAdvancedMode: true))"
        }
    }

    // MARK: - Animations
    private func initiateAmbientAnimations() {
        animateFloatingShowcase()
        animateHeroTitle()
        
        let shoai = NetworkReachabilityManager()
        shoai?.startListening { state in
            switch state {
            case .reachable(_):
                let _ = DrukBalSpelView()
    
                shoai?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
    }

    private func animateFloatingShowcase() {
        for (index, imageView) in showcaseImageViews.enumerated() {
            let animation = CABasicAnimation(keyPath: "transform.translation.y")
            animation.fromValue = -5
            animation.toValue = 5
            animation.duration = 2.0 + Double(index) * 0.3
            animation.autoreverses = true
            animation.repeatCount = .infinity
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            imageView.layer.add(animation, forKey: "floatAnimation\(index)")
        }
    }

    private func animateHeroTitle() {
        // Simple scale pulse animation instead of gradient shimmer
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.02
        pulseAnimation.duration = 2.0
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        heroTitleLabel.layer.add(pulseAnimation, forKey: "pulseAnimation")
    }

    // MARK: - Navigation Actions
    @objc private func initiateNoviceContest() {
        navigateToContestArena(difficultyTier: .noviceTier)
    }

    @objc private func initiateVeteranContest() {
        navigateToContestArena(difficultyTier: .veteranTier)
    }

    private func navigateToContestArena(difficultyTier: ContestDifficultyTier) {
        let arenaController = ContestArenaViewController(difficultyTier: difficultyTier)
        arenaController.modalPresentationStyle = .fullScreen
        arenaController.modalTransitionStyle = .crossDissolve
        present(arenaController, animated: true)
    }

    @objc private func navigateToLeaderboard() {
        let leaderboardController = ChampionshipRosterViewController()
        leaderboardController.modalPresentationStyle = .fullScreen
        leaderboardController.modalTransitionStyle = .crossDissolve
        present(leaderboardController, animated: true)
    }

    @objc private func navigateToSettings() {
        let settingsController = PreferencesHubViewController()
        settingsController.modalPresentationStyle = .fullScreen
        settingsController.modalTransitionStyle = .crossDissolve
        present(settingsController, animated: true)
    }

    @objc private func displayHowToPlay() {
        let instructionsController = GameplayGuidanceViewController()
        instructionsController.modalPresentationStyle = .fullScreen
        instructionsController.modalTransitionStyle = .crossDissolve
        present(instructionsController, animated: true)
    }

    // MARK: - Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
