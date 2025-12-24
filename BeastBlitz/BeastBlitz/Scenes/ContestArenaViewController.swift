//
//  ContestArenaViewController.swift
//  BeastBlitz
//
//  Main gameplay screen with grid and timer
//

import UIKit

final class ContestArenaViewController: UIViewController {

    // MARK: - Properties
    private let difficultyTier: ContestDifficultyTier
    private var gameOrchestrator: ContestOrchestrator!

    // MARK: - Visual Components
    private var gradientBackdropLayer: CAGradientLayer!

    private let headerContainerView = UIView()
    private let dismissButton = CircularGlyphButton()
    private let scoreDisplayLabel = UILabel()
    private let scoreValueLabel = UILabel()

    private let timerContainerView = UIView()
    private let circularTimerView = CircularProgressIndicator()

    private let riddleDisplayCard = GlassomorphicCard()
    private let riddleTextLabel = UILabel()

    private var specimenCollectionView: UICollectionView!
    private let submitAnswerButton = GlimmeringButton(labelText: "Submit", buttonStyle: .primary)

    private let comboDisplayLabel = UILabel()
    private let comboStreakLabel = UILabel()

    // MARK: - State
    private var currentGridSpecimens: [WildernessSpecimen] = []
    private var selectedCellIndices: Set<Int> = []

    // MARK: - Initialization
    init(difficultyTier: ContestDifficultyTier) {
        self.difficultyTier = difficultyTier
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.difficultyTier = .noviceTier
        super.init(coder: coder)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        establishGradientBackdrop()
        constructVisualHierarchy()
        applyLayoutConstraints()
        initializeGameOrchestrator()
    }

    // MARK: - Setup
    private func establishGradientBackdrop() {
        gradientBackdropLayer = GradientBackdropFactory.fabricateJungleGradient(forBounds: view.bounds)
        view.layer.insertSublayer(gradientBackdropLayer, at: 0)
    }

    private func constructVisualHierarchy() {
        configureHeaderSection()
        configureTimerSection()
        configureRiddleDisplay()
        configureSpecimenGrid()
        configureSubmitButton()
        configureComboDisplay()
    }

    private func configureHeaderSection() {
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerContainerView)

        dismissButton.glyphImage = UIImage(systemName: "xmark")
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.addTarget(self, action: #selector(handleDismissTap), for: .touchUpInside)
        headerContainerView.addSubview(dismissButton)

        scoreDisplayLabel.text = "SCORE"
        scoreDisplayLabel.font = TypographyAtelier.smallLabelFont
        scoreDisplayLabel.textColor = ChromaticPalette.secondaryTextLight
        scoreDisplayLabel.textAlignment = .right
        scoreDisplayLabel.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.addSubview(scoreDisplayLabel)

        scoreValueLabel.text = "0"
        scoreValueLabel.font = TypographyAtelier.cardTitleFont
        scoreValueLabel.textColor = ChromaticPalette.amberSunset
        scoreValueLabel.textAlignment = .right
        scoreValueLabel.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.addSubview(scoreValueLabel)
    }

    private func configureTimerSection() {
        timerContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timerContainerView)

        circularTimerView.translatesAutoresizingMaskIntoConstraints = false
        circularTimerView.trackWidth = 6
        timerContainerView.addSubview(circularTimerView)
    }

    private func configureRiddleDisplay() {
        riddleDisplayCard.translatesAutoresizingMaskIntoConstraints = false
        riddleDisplayCard.cardCornerRadius = DimensionalMetrics.CornerCurvature.pronounced
        view.addSubview(riddleDisplayCard)

        riddleTextLabel.text = "Loading..."
        riddleTextLabel.font = TypographyAtelier.riddleTextFont
        riddleTextLabel.textColor = ChromaticPalette.primaryTextLight
        riddleTextLabel.textAlignment = .center
        riddleTextLabel.numberOfLines = 0
        riddleTextLabel.translatesAutoresizingMaskIntoConstraints = false

        // Add label directly to view, positioned over the card
        view.addSubview(riddleTextLabel)
    }

    private func configureSpecimenGrid() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 4
        flowLayout.minimumLineSpacing = 4

        specimenCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        specimenCollectionView.translatesAutoresizingMaskIntoConstraints = false
        specimenCollectionView.backgroundColor = .clear
        specimenCollectionView.delegate = self
        specimenCollectionView.dataSource = self
        specimenCollectionView.register(SpecimenGridCell.self, forCellWithReuseIdentifier: SpecimenGridCell.reuseIdentifier)
        specimenCollectionView.isScrollEnabled = false
        view.addSubview(specimenCollectionView)
    }

    private func configureSubmitButton() {
        submitAnswerButton.translatesAutoresizingMaskIntoConstraints = false
        submitAnswerButton.addTarget(self, action: #selector(handleSubmitTap), for: .touchUpInside)
        view.addSubview(submitAnswerButton)
    }

    private func configureComboDisplay() {
        comboDisplayLabel.text = "COMBO"
        comboDisplayLabel.font = TypographyAtelier.smallLabelFont
        comboDisplayLabel.textColor = ChromaticPalette.secondaryTextLight
        comboDisplayLabel.textAlignment = .center
        comboDisplayLabel.alpha = 0
        comboDisplayLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(comboDisplayLabel)

        comboStreakLabel.text = "x3"
        comboStreakLabel.font = TypographyAtelier.comboTextFont
        comboStreakLabel.textColor = ChromaticPalette.triumphGreen
        comboStreakLabel.textAlignment = .center
        comboStreakLabel.alpha = 0
        comboStreakLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(comboStreakLabel)
    }

    // MARK: - Layout Constraints
    private var gridHeightConstraint: NSLayoutConstraint?
    private var hasAppliedInitialLayout = false

    private func applyLayoutConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // Header - compact
            headerContainerView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: DimensionalMetrics.Spacing.diminutive),
            headerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            headerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),
            headerContainerView.heightAnchor.constraint(equalToConstant: 44),

            dismissButton.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            dismissButton.centerYAnchor.constraint(equalTo: headerContainerView.centerYAnchor),
            dismissButton.widthAnchor.constraint(equalToConstant: 40),
            dismissButton.heightAnchor.constraint(equalToConstant: 40),

            scoreValueLabel.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            scoreValueLabel.centerYAnchor.constraint(equalTo: headerContainerView.centerYAnchor),

            scoreDisplayLabel.trailingAnchor.constraint(equalTo: scoreValueLabel.leadingAnchor, constant: -8),
            scoreDisplayLabel.centerYAnchor.constraint(equalTo: headerContainerView.centerYAnchor),

            // Timer - inline with header for space saving
            timerContainerView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: DimensionalMetrics.Spacing.diminutive),
            timerContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerContainerView.widthAnchor.constraint(equalToConstant: 70),
            timerContainerView.heightAnchor.constraint(equalToConstant: 70),

            circularTimerView.centerXAnchor.constraint(equalTo: timerContainerView.centerXAnchor),
            circularTimerView.centerYAnchor.constraint(equalTo: timerContainerView.centerYAnchor),
            circularTimerView.widthAnchor.constraint(equalToConstant: 60),
            circularTimerView.heightAnchor.constraint(equalToConstant: 60),

            // Riddle card - compact
            riddleDisplayCard.topAnchor.constraint(equalTo: timerContainerView.bottomAnchor, constant: DimensionalMetrics.Spacing.diminutive),
            riddleDisplayCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            riddleDisplayCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),

            riddleTextLabel.topAnchor.constraint(equalTo: riddleDisplayCard.topAnchor, constant: DimensionalMetrics.Spacing.compact),
            riddleTextLabel.leadingAnchor.constraint(equalTo: riddleDisplayCard.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            riddleTextLabel.trailingAnchor.constraint(equalTo: riddleDisplayCard.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),
            riddleTextLabel.bottomAnchor.constraint(equalTo: riddleDisplayCard.bottomAnchor, constant: -DimensionalMetrics.Spacing.compact),

            // Grid
            specimenCollectionView.topAnchor.constraint(equalTo: riddleDisplayCard.bottomAnchor, constant: DimensionalMetrics.Spacing.diminutive),
            specimenCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DimensionalMetrics.Spacing.diminutive),
            specimenCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DimensionalMetrics.Spacing.diminutive),

            // Submit button - anchored to bottom
            submitAnswerButton.topAnchor.constraint(equalTo: specimenCollectionView.bottomAnchor, constant: DimensionalMetrics.Spacing.diminutive),
            submitAnswerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitAnswerButton.widthAnchor.constraint(equalToConstant: 160),
            submitAnswerButton.heightAnchor.constraint(equalToConstant: 44),
            submitAnswerButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -DimensionalMetrics.Spacing.diminutive),

            // Combo labels
            comboDisplayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            comboDisplayLabel.bottomAnchor.constraint(equalTo: comboStreakLabel.topAnchor, constant: -4),

            comboStreakLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            comboStreakLabel.centerYAnchor.constraint(equalTo: specimenCollectionView.centerYAnchor)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientBackdropLayer.frame = view.bounds

        // Only recalculate grid when bounds actually change
        if !hasAppliedInitialLayout || gridHeightConstraint == nil {
            hasAppliedInitialLayout = true
            updateGridHeightConstraint()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.updateGridHeightConstraint()
            self.specimenCollectionView.collectionViewLayout.invalidateLayout()
        }
    }

    private func updateGridHeightConstraint() {
        // Remove existing constraint
        gridHeightConstraint?.isActive = false

        let safeInsets = view.safeAreaInsets
        let availableHeight = view.bounds.height - safeInsets.top - safeInsets.bottom
        let availableWidth = view.bounds.width - DimensionalMetrics.Spacing.diminutive * 2

        // Calculate fixed heights: header(44) + timer(70) + riddle(~50) + button(44) + spacing(8*5)
        let fixedHeight: CGFloat = 44 + 70 + 50 + 44 + (DimensionalMetrics.Spacing.diminutive * 5)
        let maxGridHeight = availableHeight - fixedHeight

        let columns = difficultyTier.gridColumnQuantity
        let rows = difficultyTier.gridRowQuantity
        let spacing: CGFloat = 3

        // Calculate cell size from width
        let cellSizeFromWidth = (availableWidth - CGFloat(columns - 1) * spacing) / CGFloat(columns)

        // Calculate cell size from height
        let cellSizeFromHeight = (maxGridHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows)

        // Use the smaller to ensure fit
        let cellSize = floor(min(cellSizeFromWidth, cellSizeFromHeight))
        let gridHeight = cellSize * CGFloat(rows) + CGFloat(rows - 1) * spacing

        gridHeightConstraint = specimenCollectionView.heightAnchor.constraint(equalToConstant: gridHeight)
        gridHeightConstraint?.isActive = true

        // Update flow layout spacing
        if let flowLayout = specimenCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = spacing
            flowLayout.minimumLineSpacing = spacing
        }
    }

    // MARK: - Game Initialization
    private func initializeGameOrchestrator() {
        gameOrchestrator = ContestOrchestrator.fabricateNewOrchestrator()
        gameOrchestrator.contestDelegate = self
        gameOrchestrator.initializeNewContest(difficultyTier: difficultyTier)
    }

    // MARK: - Actions
    @objc private func handleDismissTap() {
        let dialog = PrismaticDialog(configuration: .confirmation(
            title: "Quit Game?",
            message: "Your progress will be lost.",
            confirmText: "Quit",
            cancelText: "Continue"
        ))
        dialog.primaryActionHandler = { [weak self] in
            self?.gameOrchestrator.terminateActiveContest()
            self?.dismiss(animated: true)
        }
        dialog.presentAnimated(in: view)
    }

    @objc private func handleSubmitTap() {
        let selectedSpecimens = selectedCellIndices.compactMap { index -> WildernessSpecimen? in
            guard index < currentGridSpecimens.count else { return nil }
            return currentGridSpecimens[index]
        }

        guard !selectedSpecimens.isEmpty else {
            let toast = EphemeralToastNotification(message: "Select at least one animal!")
            toast.displayInView(view)
            return
        }

        gameOrchestrator.submitPlayerSelections(selectedSpecimens)
    }

    // MARK: - UI Updates
    private func refreshScoreDisplay(score: Int) {
        UIView.animate(withDuration: 0.2) {
            self.scoreValueLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            self.scoreValueLabel.text = "\(score)"
            UIView.animate(withDuration: 0.2) {
                self.scoreValueLabel.transform = .identity
            }
        }
    }

    private func refreshTimerDisplay(seconds: TimeInterval) {
        let displaySeconds = Int(ceil(seconds))
        circularTimerView.displayedTimeText = "\(displaySeconds)"

        let progress = seconds / difficultyTier.countdownDurationSeconds
        circularTimerView.currentProgressValue = CGFloat(progress)
        circularTimerView.updateProgressPresentation(animated: true, duration: 0.1)

        if seconds <= 3 && seconds > 0 {
            circularTimerView.commenceWarningPulsation()
        }
    }

    private func displayComboAnimation(multiplier: Int) {
        comboStreakLabel.text = "x\(multiplier)"

        UIView.animate(withDuration: 0.3, animations: {
            self.comboDisplayLabel.alpha = 1
            self.comboStreakLabel.alpha = 1
            self.comboStreakLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0.5) {
                self.comboStreakLabel.transform = .identity
            } completion: { _ in
                UIView.animate(withDuration: 0.3, delay: 0.3) {
                    self.comboDisplayLabel.alpha = 0
                    self.comboStreakLabel.alpha = 0
                }
            }
        }

        performSuccessHaptic()
    }

    private func performSuccessHaptic() {
        guard PreferencesVault.sharedInstance.isHapticFeedbackEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func performFailureHaptic() {
        guard PreferencesVault.sharedInstance.isHapticFeedbackEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    // MARK: - Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - UICollectionViewDataSource
extension ContestArenaViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentGridSpecimens.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpecimenGridCell.reuseIdentifier, for: indexPath) as! SpecimenGridCell

        let specimen = currentGridSpecimens[indexPath.item]
        cell.configureWithSpecimen(specimen)

        cell.selectionToggleHandler = { [weak self] _, isSelected in
            if isSelected {
                self?.selectedCellIndices.insert(indexPath.item)
            } else {
                self?.selectedCellIndices.remove(indexPath.item)
            }
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ContestArenaViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns = difficultyTier.gridColumnQuantity
        let rows = difficultyTier.gridRowQuantity
        let spacing: CGFloat = 3

        let availableWidth = collectionView.bounds.width - CGFloat(columns - 1) * spacing
        let cellSizeFromWidth = availableWidth / CGFloat(columns)

        // Also consider height constraint
        let availableGridHeight = collectionView.bounds.height
        let cellSizeFromHeight = (availableGridHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows)

        let cellSize = floor(min(cellSizeFromWidth, cellSizeFromHeight))
        return CGSize(width: cellSize, height: cellSize)
    }
}

// MARK: - ContestOrchestratorDelegate
extension ContestArenaViewController: ContestOrchestratorDelegate {

    func orchestratorDidUpdateScore(_ newScore: Int) {
        refreshScoreDisplay(score: newScore)
    }

    func orchestratorDidUpdateComboStreak(_ streak: Int) {
        // Handled by combo animation trigger
    }

    func orchestratorDidUpdateTimeRemaining(_ seconds: TimeInterval) {
        refreshTimerDisplay(seconds: seconds)
    }

    func orchestratorDidGenerateNewRiddle(_ riddle: ChallengeRiddle) {
        riddleTextLabel.text = riddle.interrogativePhrase

        UIView.animate(withDuration: 0.3) {
            self.riddleDisplayCard.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.riddleDisplayCard.transform = .identity
            }
        }
    }

    func orchestratorDidRefreshGridSpecimens(_ specimens: [WildernessSpecimen]) {
        currentGridSpecimens = specimens
        selectedCellIndices.removeAll()
        specimenCollectionView.reloadData()

        circularTimerView.ceaseWarningPulsation()
    }

    func orchestratorDidCompleteRound(wasSuccessful: Bool, correctSpecimens: [WildernessSpecimen]) {
        let correctIdentifiers = Set(correctSpecimens.map { $0.appellationIdentifier })

        for (index, specimen) in currentGridSpecimens.enumerated() {
            guard let cell = specimenCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SpecimenGridCell else { continue }

            let isCorrectSpecimen = correctIdentifiers.contains(specimen.appellationIdentifier)
            let wasSelected = selectedCellIndices.contains(index)

            if wasSelected && isCorrectSpecimen {
                cell.displayCorrectFeedback()
            } else if wasSelected && !isCorrectSpecimen {
                cell.displayIncorrectFeedback()
            } else if !wasSelected && isCorrectSpecimen {
                cell.displayMissedCorrectFeedback()
            }
        }

        if wasSuccessful {
            performSuccessHaptic()
        } else {
            performFailureHaptic()
        }
    }

    func orchestratorDidTerminateContest(finalScore: Int, roundsCompleted: Int, isHighScore: Bool) {
        let dialogConfig = PrismaticDialog.DialogConfiguration.gameOver(score: finalScore, isHighScore: isHighScore)
        let dialog = PrismaticDialog(configuration: dialogConfig)

        dialog.primaryActionHandler = { [weak self] in
            self?.initializeGameOrchestrator()
        }

        dialog.secondaryActionHandler = { [weak self] in
            self?.dismiss(animated: true)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dialog.presentAnimated(in: self.view)
        }
    }

    func orchestratorDidTriggerComboAnimation(multiplier: Int) {
        displayComboAnimation(multiplier: multiplier)
    }
}
