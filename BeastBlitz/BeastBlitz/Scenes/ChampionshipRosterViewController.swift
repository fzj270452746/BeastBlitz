//
//  ChampionshipRosterViewController.swift
//  BeastBlitz
//
//  Leaderboard display screen
//

import UIKit

final class ChampionshipRosterViewController: UIViewController {

    // MARK: - Visual Components
    private var gradientBackdropLayer: CAGradientLayer!

    private let navigationBar = UIView()
    private let backButton = CircularGlyphButton()
    private let titleLabel = UILabel()

    private let segmentedModeSelector = UISegmentedControl(items: ["Beginner", "Advanced"])
    private let rosterTableView = UITableView()

    private let emptyStateView = UIView()
    private let emptyStateIcon = UIImageView()
    private let emptyStateLabel = UILabel()

    // MARK: - Data
    private var currentRecords: [TriumphRecord] = []
    private var isShowingAdvancedMode: Bool = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        establishGradientBackdrop()
        constructVisualHierarchy()
        applyLayoutConstraints()
        loadLeaderboardData()
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
        configureModeSelector()
        configureRosterTable()
        configureEmptyState()
    }

    private func configureNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)

        backButton.glyphImage = UIImage(systemName: "chevron.left")
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(handleBackTap), for: .touchUpInside)
        navigationBar.addSubview(backButton)

        titleLabel.text = "Leaderboard"
        titleLabel.font = TypographyAtelier.cardTitleFont
        titleLabel.textColor = ChromaticPalette.primaryTextLight
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(titleLabel)
    }

    private func configureModeSelector() {
        segmentedModeSelector.selectedSegmentIndex = 0
        segmentedModeSelector.translatesAutoresizingMaskIntoConstraints = false
        segmentedModeSelector.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        segmentedModeSelector.selectedSegmentTintColor = ChromaticPalette.amberSunset
        segmentedModeSelector.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: TypographyAtelier.captionTextFont
        ], for: .normal)
        segmentedModeSelector.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: TypographyAtelier.captionTextFont
        ], for: .selected)
        segmentedModeSelector.addTarget(self, action: #selector(handleModeChange), for: .valueChanged)
        view.addSubview(segmentedModeSelector)
    }

    private func configureRosterTable() {
        rosterTableView.translatesAutoresizingMaskIntoConstraints = false
        rosterTableView.backgroundColor = .clear
        rosterTableView.separatorStyle = .none
        rosterTableView.delegate = self
        rosterTableView.dataSource = self
        rosterTableView.register(ChampionshipEntryCell.self, forCellReuseIdentifier: ChampionshipEntryCell.reuseIdentifier)
        rosterTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
        view.addSubview(rosterTableView)
    }

    private func configureEmptyState() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)

        emptyStateIcon.image = UIImage(systemName: "trophy")
        emptyStateIcon.tintColor = ChromaticPalette.stoneGray
        emptyStateIcon.contentMode = .scaleAspectFit
        emptyStateIcon.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(emptyStateIcon)

        emptyStateLabel.text = "No scores yet!\nBe the first to play."
        emptyStateLabel.font = TypographyAtelier.bodyTextFont
        emptyStateLabel.textColor = ChromaticPalette.secondaryTextLight
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(emptyStateLabel)
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

            segmentedModeSelector.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: DimensionalMetrics.Spacing.generous),
            segmentedModeSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DimensionalMetrics.Spacing.generous),
            segmentedModeSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DimensionalMetrics.Spacing.generous),
            segmentedModeSelector.heightAnchor.constraint(equalToConstant: 40),

            rosterTableView.topAnchor.constraint(equalTo: segmentedModeSelector.bottomAnchor, constant: DimensionalMetrics.Spacing.moderate),
            rosterTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            rosterTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),
            rosterTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: rosterTableView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: rosterTableView.centerYAnchor),

            emptyStateIcon.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateIcon.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateIcon.widthAnchor.constraint(equalToConstant: 64),
            emptyStateIcon.heightAnchor.constraint(equalToConstant: 64),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateIcon.bottomAnchor, constant: DimensionalMetrics.Spacing.moderate),
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }

    // MARK: - Data Loading
    private func loadLeaderboardData() {
        currentRecords = TriumphChronicleVault.sharedInstance.retrieveTriumphRecords(forAdvancedMode: isShowingAdvancedMode)
        rosterTableView.reloadData()
        updateEmptyStateVisibility()
    }

    private func updateEmptyStateVisibility() {
        emptyStateView.isHidden = !currentRecords.isEmpty
        rosterTableView.isHidden = currentRecords.isEmpty
    }

    // MARK: - Actions
    @objc private func handleBackTap() {
        dismiss(animated: true)
    }

    @objc private func handleModeChange() {
        isShowingAdvancedMode = segmentedModeSelector.selectedSegmentIndex == 1
        loadLeaderboardData()
    }

    // MARK: - Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - UITableViewDataSource
extension ChampionshipRosterViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentRecords.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChampionshipEntryCell.reuseIdentifier, for: indexPath) as! ChampionshipEntryCell
        let record = currentRecords[indexPath.row]
        cell.configureWithRecord(record, rank: indexPath.row + 1)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChampionshipRosterViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - Championship Entry Cell
final class ChampionshipEntryCell: UITableViewCell {

    static let reuseIdentifier = "ChampionshipEntryCell"

    private let containerCard = GlassomorphicCard()
    private let rankBadge = UILabel()
    private let playerNameLabel = UILabel()
    private let scoreLabel = UILabel()
    private let detailsLabel = UILabel()
    private let trophyIcon = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        establishCellHierarchy()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        establishCellHierarchy()
    }

    private func establishCellHierarchy() {
        backgroundColor = .clear
        selectionStyle = .none

        containerCard.translatesAutoresizingMaskIntoConstraints = false
        containerCard.cardCornerRadius = DimensionalMetrics.CornerCurvature.moderate
        contentView.addSubview(containerCard)

        rankBadge.font = TypographyAtelier.leaderboardRankFont
        rankBadge.textColor = ChromaticPalette.primaryTextLight
        rankBadge.textAlignment = .center
        rankBadge.translatesAutoresizingMaskIntoConstraints = false
        containerCard.addSubview(rankBadge)

        trophyIcon.contentMode = .scaleAspectFit
        trophyIcon.translatesAutoresizingMaskIntoConstraints = false
        trophyIcon.isHidden = true
        containerCard.addSubview(trophyIcon)

        playerNameLabel.font = TypographyAtelier.bodyTextFont
        playerNameLabel.textColor = ChromaticPalette.primaryTextLight
        playerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerCard.addSubview(playerNameLabel)

        detailsLabel.font = TypographyAtelier.smallLabelFont
        detailsLabel.textColor = ChromaticPalette.secondaryTextLight
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        containerCard.addSubview(detailsLabel)

        scoreLabel.font = TypographyAtelier.leaderboardScoreFont
        scoreLabel.textColor = ChromaticPalette.amberSunset
        scoreLabel.textAlignment = .right
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        containerCard.addSubview(scoreLabel)

        NSLayoutConstraint.activate([
            containerCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            rankBadge.leadingAnchor.constraint(equalTo: containerCard.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            rankBadge.centerYAnchor.constraint(equalTo: containerCard.centerYAnchor),
            rankBadge.widthAnchor.constraint(equalToConstant: 36),

            trophyIcon.leadingAnchor.constraint(equalTo: containerCard.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            trophyIcon.centerYAnchor.constraint(equalTo: containerCard.centerYAnchor),
            trophyIcon.widthAnchor.constraint(equalToConstant: 28),
            trophyIcon.heightAnchor.constraint(equalToConstant: 28),

            playerNameLabel.leadingAnchor.constraint(equalTo: rankBadge.trailingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            playerNameLabel.topAnchor.constraint(equalTo: containerCard.topAnchor, constant: DimensionalMetrics.Spacing.compact),

            detailsLabel.leadingAnchor.constraint(equalTo: playerNameLabel.leadingAnchor),
            detailsLabel.topAnchor.constraint(equalTo: playerNameLabel.bottomAnchor, constant: 2),

            scoreLabel.trailingAnchor.constraint(equalTo: containerCard.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),
            scoreLabel.centerYAnchor.constraint(equalTo: containerCard.centerYAnchor)
        ])
    }

    func configureWithRecord(_ record: TriumphRecord, rank: Int) {
        playerNameLabel.text = record.playerMoniker
        scoreLabel.text = "\(record.accumulatedPoints)"

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        detailsLabel.text = "\(record.roundsConquered) rounds • \(dateFormatter.string(from: record.competitionEpoch))"

        configureTrophyDisplay(forRank: rank)
    }

    private func configureTrophyDisplay(forRank rank: Int) {
        switch rank {
        case 1:
            rankBadge.isHidden = true
            trophyIcon.isHidden = false
            trophyIcon.image = UIImage(systemName: "trophy.fill")
            trophyIcon.tintColor = ChromaticPalette.goldenSavannah

        case 2:
            rankBadge.isHidden = true
            trophyIcon.isHidden = false
            trophyIcon.image = UIImage(systemName: "trophy.fill")
            trophyIcon.tintColor = ChromaticPalette.stoneGray

        case 3:
            rankBadge.isHidden = true
            trophyIcon.isHidden = false
            trophyIcon.image = UIImage(systemName: "trophy.fill")
            trophyIcon.tintColor = UIColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 1.0)

        default:
            rankBadge.isHidden = false
            trophyIcon.isHidden = true
            rankBadge.text = "#\(rank)"
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        rankBadge.isHidden = false
        trophyIcon.isHidden = true
    }
}
