//
//  ContestOrchestrator.swift
//  BeastBlitz
//
//  Central game state management and logic coordination
//

import Foundation

protocol ContestOrchestratorDelegate: AnyObject {
    func orchestratorDidUpdateScore(_ newScore: Int)
    func orchestratorDidUpdateComboStreak(_ streak: Int)
    func orchestratorDidUpdateTimeRemaining(_ seconds: TimeInterval)
    func orchestratorDidGenerateNewRiddle(_ riddle: ChallengeRiddle)
    func orchestratorDidRefreshGridSpecimens(_ specimens: [WildernessSpecimen])
    func orchestratorDidCompleteRound(wasSuccessful: Bool, correctSpecimens: [WildernessSpecimen])
    func orchestratorDidTerminateContest(finalScore: Int, roundsCompleted: Int, isHighScore: Bool)
    func orchestratorDidTriggerComboAnimation(multiplier: Int)
}

final class ContestOrchestrator {

    // MARK: - Singleton
    private init() {}

    // MARK: - State
    weak var contestDelegate: ContestOrchestratorDelegate?

    private(set) var currentDifficultyTier: ContestDifficultyTier = .noviceTier
    private(set) var accumulatedScore: Int = 0
    private(set) var consecutiveSuccessStreak: Int = 0
    private(set) var completedRoundsCount: Int = 0
    private(set) var maximumComboAchieved: Int = 0

    private(set) var currentGridSpecimens: [WildernessSpecimen] = []
    private(set) var activeRiddle: ChallengeRiddle?

    private var countdownTimer: Timer?
    private var remainingTimeSeconds: TimeInterval = 0

    private(set) var isContestActive: Bool = false

    // MARK: - Contest Lifecycle
    func initializeNewContest(difficultyTier: ContestDifficultyTier) {
        currentDifficultyTier = difficultyTier
        accumulatedScore = 0
        consecutiveSuccessStreak = 0
        completedRoundsCount = 0
        maximumComboAchieved = 0
        isContestActive = true

        commenceNextRound()
    }

    func commenceNextRound() {
        guard isContestActive else { return }

        populateGridWithRandomSpecimens()
        generateNewRiddleForCurrentGrid()
        initiateCountdownSequence()
    }

    func terminateActiveContest() {
        isContestActive = false
        countdownTimer?.invalidate()
        countdownTimer = nil

        let isHighScore = checkAndRecordHighScore()

        contestDelegate?.orchestratorDidTerminateContest(
            finalScore: accumulatedScore,
            roundsCompleted: completedRoundsCount,
            isHighScore: isHighScore
        )
    }

    // MARK: - Grid Population
    private func populateGridWithRandomSpecimens() {
        let totalCells = currentDifficultyTier.totalCellCount
        let repository = SpecimenCatalogueRepository.sharedInstance

        currentGridSpecimens = (0..<totalCells).map { _ in
            repository.retrieveRandomizedSpecimen()
        }

        contestDelegate?.orchestratorDidRefreshGridSpecimens(currentGridSpecimens)
    }

    // MARK: - Riddle Generation
    private func generateNewRiddleForCurrentGrid() {
        let isAdvanced = currentDifficultyTier == .veteranTier
        let riddle = RiddleOrchestrationEngine.sharedInstance.generateRiddle(
            forDifficulty: isAdvanced,
            withSpecimens: currentGridSpecimens
        )

        activeRiddle = riddle
        contestDelegate?.orchestratorDidGenerateNewRiddle(riddle)
    }

    // MARK: - Timer Management
    private func initiateCountdownSequence() {
        countdownTimer?.invalidate()

        remainingTimeSeconds = currentDifficultyTier.countdownDurationSeconds
        contestDelegate?.orchestratorDidUpdateTimeRemaining(remainingTimeSeconds)

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.processTimerTick()
        }
    }

    private func processTimerTick() {
        remainingTimeSeconds -= 0.1

        if remainingTimeSeconds <= 0 {
            remainingTimeSeconds = 0
            handleTimeExpiration()
        }

        contestDelegate?.orchestratorDidUpdateTimeRemaining(remainingTimeSeconds)
    }

    private func handleTimeExpiration() {
        countdownTimer?.invalidate()
        countdownTimer = nil

        consecutiveSuccessStreak = 0

        if let riddle = activeRiddle {
            contestDelegate?.orchestratorDidCompleteRound(
                wasSuccessful: false,
                correctSpecimens: riddle.validResponseSpecimens
            )
        }

        terminateActiveContest()
    }

    // MARK: - Answer Validation
    func submitPlayerSelections(_ selectedSpecimens: [WildernessSpecimen]) {
        guard let riddle = activeRiddle, isContestActive else { return }

        countdownTimer?.invalidate()
        countdownTimer = nil

        let correctSet = Set(riddle.validResponseSpecimens.map { $0.appellationIdentifier })
        let selectedSet = Set(selectedSpecimens.map { $0.appellationIdentifier })

        let isCorrectAnswer = correctSet == selectedSet

        if isCorrectAnswer {
            processSuccessfulRound()
        } else {
            processFailedRound(correctSpecimens: riddle.validResponseSpecimens)
        }
    }

    private func processSuccessfulRound() {
        completedRoundsCount += 1
        consecutiveSuccessStreak += 1

        var roundPoints = currentDifficultyTier.pointsPerVictoriousRound

        if consecutiveSuccessStreak >= currentDifficultyTier.comboActivationThreshold {
            let comboMultiplier = min(consecutiveSuccessStreak - currentDifficultyTier.comboActivationThreshold + 2, 5)
            roundPoints = roundPoints * comboMultiplier / 2

            if consecutiveSuccessStreak > maximumComboAchieved {
                maximumComboAchieved = consecutiveSuccessStreak
            }

            contestDelegate?.orchestratorDidTriggerComboAnimation(multiplier: comboMultiplier)
        }

        accumulatedScore += roundPoints

        contestDelegate?.orchestratorDidUpdateScore(accumulatedScore)
        contestDelegate?.orchestratorDidUpdateComboStreak(consecutiveSuccessStreak)
        contestDelegate?.orchestratorDidCompleteRound(
            wasSuccessful: true,
            correctSpecimens: activeRiddle?.validResponseSpecimens ?? []
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.commenceNextRound()
        }
    }

    private func processFailedRound(correctSpecimens: [WildernessSpecimen]) {
        consecutiveSuccessStreak = 0

        contestDelegate?.orchestratorDidUpdateComboStreak(0)
        contestDelegate?.orchestratorDidCompleteRound(
            wasSuccessful: false,
            correctSpecimens: correctSpecimens
        )

        terminateActiveContest()
    }

    // MARK: - Score Management
    private func checkAndRecordHighScore() -> Bool {
        let vault = TriumphChronicleVault.sharedInstance
        let currentHighScore = vault.retrievePinnacleScore(forAdvancedMode: currentDifficultyTier == .veteranTier)
        let isHighScore = accumulatedScore > currentHighScore

        let record = TriumphRecord(
            accumulatedPoints: accumulatedScore,
            competitionEpoch: Date(),
            playerMoniker: PreferencesVault.sharedInstance.contestantMoniker,
            wasAdvancedChallenge: currentDifficultyTier == .veteranTier,
            roundsConquered: completedRoundsCount,
            maximumComboStreak: maximumComboAchieved
        )

        vault.archiveNewTriumph(record)

        return isHighScore
    }

    // MARK: - Factory Method
    static func fabricateNewOrchestrator() -> ContestOrchestrator {
        return ContestOrchestrator()
    }
}
