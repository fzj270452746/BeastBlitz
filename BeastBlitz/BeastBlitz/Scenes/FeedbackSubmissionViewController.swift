//
//  FeedbackSubmissionViewController.swift
//  BeastBlitz
//
//  User feedback submission screen
//

import UIKit
import MessageUI

final class FeedbackSubmissionViewController: UIViewController {

    // MARK: - Visual Components
    private var gradientBackdropLayer: CAGradientLayer!

    private let navigationBar = UIView()
    private let backButton = CircularGlyphButton()
    private let titleLabel = UILabel()

    private let feedbackCard = GlassomorphicCard()
    private let feedbackTypeLabel = UILabel()
    private let feedbackTypeSegment = UISegmentedControl(items: ["Bug", "Feature", "Other"])
    private let messageTextView = UITextView()
    private let placeholderLabel = UILabel()
    private let submitButton = GlimmeringButton(labelText: "Submit Feedback", buttonStyle: .primary)

    private let characterCountLabel = UILabel()
    private let maxCharacterCount = 500

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        establishGradientBackdrop()
        constructVisualHierarchy()
        applyLayoutConstraints()
        setupKeyboardObservers()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientBackdropLayer.frame = view.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup
    private func establishGradientBackdrop() {
        gradientBackdropLayer = GradientBackdropFactory.fabricateJungleGradient(forBounds: view.bounds)
        view.layer.insertSublayer(gradientBackdropLayer, at: 0)
    }

    private func constructVisualHierarchy() {
        configureNavigationBar()
        configureFeedbackCard()
    }

    private func configureNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)

        backButton.glyphImage = UIImage(systemName: "chevron.left")
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(handleBackTap), for: .touchUpInside)
        navigationBar.addSubview(backButton)

        titleLabel.text = "Send Feedback"
        titleLabel.font = TypographyAtelier.cardTitleFont
        titleLabel.textColor = ChromaticPalette.primaryTextLight
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(titleLabel)
    }

    private func configureFeedbackCard() {
        feedbackCard.translatesAutoresizingMaskIntoConstraints = false
        feedbackCard.cardCornerRadius = DimensionalMetrics.CornerCurvature.substantial
        view.addSubview(feedbackCard)

        feedbackTypeLabel.text = "Feedback Type"
        feedbackTypeLabel.font = TypographyAtelier.captionTextFont
        feedbackTypeLabel.textColor = ChromaticPalette.secondaryTextLight
        feedbackTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        feedbackCard.addSubview(feedbackTypeLabel)

        feedbackTypeSegment.selectedSegmentIndex = 0
        feedbackTypeSegment.translatesAutoresizingMaskIntoConstraints = false
        feedbackTypeSegment.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        feedbackTypeSegment.selectedSegmentTintColor = ChromaticPalette.amberSunset
        feedbackTypeSegment.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: TypographyAtelier.captionTextFont
        ], for: .normal)
        feedbackTypeSegment.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: TypographyAtelier.captionTextFont
        ], for: .selected)
        feedbackCard.addSubview(feedbackTypeSegment)

        messageTextView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        messageTextView.textColor = ChromaticPalette.primaryTextLight
        messageTextView.font = TypographyAtelier.bodyTextFont
        messageTextView.layer.cornerRadius = DimensionalMetrics.CornerCurvature.moderate
        messageTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        messageTextView.delegate = self
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        feedbackCard.addSubview(messageTextView)

        placeholderLabel.text = "Describe your feedback here..."
        placeholderLabel.font = TypographyAtelier.bodyTextFont
        placeholderLabel.textColor = ChromaticPalette.stoneGray
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        feedbackCard.addSubview(placeholderLabel)

        characterCountLabel.text = "0/\(maxCharacterCount)"
        characterCountLabel.font = TypographyAtelier.smallLabelFont
        characterCountLabel.textColor = ChromaticPalette.stoneGray
        characterCountLabel.textAlignment = .right
        characterCountLabel.translatesAutoresizingMaskIntoConstraints = false
        feedbackCard.addSubview(characterCountLabel)

        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.addTarget(self, action: #selector(handleSubmitTap), for: .touchUpInside)
        view.addSubview(submitButton)
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

            feedbackCard.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: DimensionalMetrics.Spacing.generous),
            feedbackCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DimensionalMetrics.Spacing.moderate),
            feedbackCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DimensionalMetrics.Spacing.moderate),

            feedbackTypeLabel.topAnchor.constraint(equalTo: feedbackCard.topAnchor, constant: DimensionalMetrics.Spacing.substantial),
            feedbackTypeLabel.leadingAnchor.constraint(equalTo: feedbackCard.leadingAnchor, constant: DimensionalMetrics.Spacing.substantial),

            feedbackTypeSegment.topAnchor.constraint(equalTo: feedbackTypeLabel.bottomAnchor, constant: DimensionalMetrics.Spacing.diminutive),
            feedbackTypeSegment.leadingAnchor.constraint(equalTo: feedbackCard.leadingAnchor, constant: DimensionalMetrics.Spacing.substantial),
            feedbackTypeSegment.trailingAnchor.constraint(equalTo: feedbackCard.trailingAnchor, constant: -DimensionalMetrics.Spacing.substantial),
            feedbackTypeSegment.heightAnchor.constraint(equalToConstant: 36),

            messageTextView.topAnchor.constraint(equalTo: feedbackTypeSegment.bottomAnchor, constant: DimensionalMetrics.Spacing.substantial),
            messageTextView.leadingAnchor.constraint(equalTo: feedbackCard.leadingAnchor, constant: DimensionalMetrics.Spacing.substantial),
            messageTextView.trailingAnchor.constraint(equalTo: feedbackCard.trailingAnchor, constant: -DimensionalMetrics.Spacing.substantial),
            messageTextView.heightAnchor.constraint(equalToConstant: 180),

            placeholderLabel.topAnchor.constraint(equalTo: messageTextView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: messageTextView.leadingAnchor, constant: 16),

            characterCountLabel.topAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: DimensionalMetrics.Spacing.diminutive),
            characterCountLabel.trailingAnchor.constraint(equalTo: feedbackCard.trailingAnchor, constant: -DimensionalMetrics.Spacing.substantial),
            characterCountLabel.bottomAnchor.constraint(equalTo: feedbackCard.bottomAnchor, constant: -DimensionalMetrics.Spacing.substantial),

            submitButton.topAnchor.constraint(equalTo: feedbackCard.bottomAnchor, constant: DimensionalMetrics.Spacing.generous),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 200),
            submitButton.heightAnchor.constraint(equalToConstant: DimensionalMetrics.ButtonDimensions.standardHeight)
        ])
    }

    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Actions
    @objc private func handleBackTap() {
        dismiss(animated: true)
    }

    @objc private func handleSubmitTap() {
        let feedbackText = messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !feedbackText.isEmpty else {
            let toast = EphemeralToastNotification(message: "Please enter your feedback")
            toast.displayInView(view)
            return
        }

        let feedbackTypes = ["Bug Report", "Feature Request", "Other"]
        let selectedType = feedbackTypes[feedbackTypeSegment.selectedSegmentIndex]

        if MFMailComposeViewController.canSendMail() {
            sendEmailFeedback(type: selectedType, message: feedbackText)
        } else {
            showFeedbackConfirmation()
        }
    }

    private func sendEmailFeedback(type: String, message: String) {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setSubject("Beast Blitz Feedback: \(type)")
        mailComposer.setMessageBody(message, isHTML: false)

        present(mailComposer, animated: true)
    }

    private func showFeedbackConfirmation() {
        let dialog = PrismaticDialog(configuration: .alert(
            title: "Thank You!",
            message: "Your feedback has been recorded. We appreciate your input!",
            confirmText: "OK"
        ))

        dialog.primaryActionHandler = { [weak self] in
            self?.dismiss(animated: true)
        }

        dialog.presentAnimated(in: view)
    }

    // MARK: - Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - UITextViewDelegate
extension FeedbackSubmissionViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        characterCountLabel.text = "\(textView.text.count)/\(maxCharacterCount)"

        if textView.text.count > maxCharacterCount {
            characterCountLabel.textColor = ChromaticPalette.perilRed
        } else {
            characterCountLabel.textColor = ChromaticPalette.stoneGray
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= maxCharacterCount
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension FeedbackSubmissionViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) { [weak self] in
            if result == .sent {
                self?.showFeedbackConfirmation()
            }
        }
    }
}
