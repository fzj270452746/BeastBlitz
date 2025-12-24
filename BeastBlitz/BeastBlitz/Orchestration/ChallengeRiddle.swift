//
//  ChallengeRiddle.swift
//  BeastBlitz
//
//  Challenge prompts and question generation system
//

import Foundation

struct ChallengeRiddle {
    let interrogativePhrase: String
    let validResponseSpecimens: [WildernessSpecimen]
    let riddleDifficultyTier: RiddleComplexity

    enum RiddleComplexity: Int {
        case elementaryLevel = 1
        case intermediateLevel = 2
        case advancedLevel = 3
    }
}

protocol RiddleFabricationProtocol {
    func synthesizeRiddle(forSpecimensOnGrid specimens: [WildernessSpecimen], maxSelections: Int) -> ChallengeRiddle
}

final class ElementaryRiddleFabricator: RiddleFabricationProtocol {

    private let riddleTemplates: [(String, (WildernessSpecimen) -> Bool)] = [
        ("Find herbivores (plant eaters)", { $0.nourishmentPreference == .herbivorousDiet }),
        ("Find carnivores (meat eaters)", { $0.nourishmentPreference == .carnivorousDiet }),
        ("Find omnivores (eat both)", { $0.nourishmentPreference == .omnivorousDiet }),
        ("Find forest animals", { $0.habitatDomain == .woodlandTerritory }),
        ("Find savannah animals", { $0.habitatDomain == .savannahExpanse }),
        ("Find domestic animals", { $0.habitatDomain == .domesticatedRealm }),
        ("Find large animals", { $0.physicalDimension == .colossalStature }),
        ("Find small animals", { $0.physicalDimension == .diminutiveStature }),
        ("Find fast animals", { $0.mobilityCharacteristic == .swiftSprinting }),
        ("Find slow animals", { $0.mobilityCharacteristic == .sluggishMovement }),
        ("Find climbing animals", { $0.mobilityCharacteristic == .arborealClimbing }),
        ("Find spotted animals", { $0.exhibitsSpottedMarkings }),
        ("Find striped animals", { $0.exhibitsStripedMarkings }),
        ("Find animals with tails", { $0.manifestsTailAppendage }),
        ("Find furry animals", { $0.possessesFurCoating })
    ]

    func synthesizeRiddle(forSpecimensOnGrid specimens: [WildernessSpecimen], maxSelections: Int) -> ChallengeRiddle {
        let shuffledTemplates = riddleTemplates.shuffled()

        for (phrase, predicate) in shuffledTemplates {
            let matchingSpecimens = specimens.filter(predicate)
            // Must have at least 1 match, not all specimens, and within max limit
            if matchingSpecimens.count >= 1 &&
               matchingSpecimens.count < specimens.count &&
               matchingSpecimens.count <= maxSelections {
                return ChallengeRiddle(
                    interrogativePhrase: phrase,
                    validResponseSpecimens: matchingSpecimens,
                    riddleDifficultyTier: .elementaryLevel
                )
            }
        }

        // Fallback: find a specific animal by name
        let randomSpecimen = specimens.randomElement()!
        return ChallengeRiddle(
            interrogativePhrase: "Find the \(randomSpecimen.appellationIdentifier)",
            validResponseSpecimens: specimens.filter { $0 == randomSpecimen },
            riddleDifficultyTier: .elementaryLevel
        )
    }
}

final class AdvancedRiddleFabricator: RiddleFabricationProtocol {

    private let complexRiddleTemplates: [(String, (WildernessSpecimen) -> Bool)] = [
        ("Find large herbivores", { $0.physicalDimension == .colossalStature && $0.nourishmentPreference == .herbivorousDiet }),
        ("Find small carnivores", { $0.physicalDimension == .diminutiveStature && $0.nourishmentPreference == .carnivorousDiet }),
        ("Find fast forest animals", { $0.mobilityCharacteristic == .swiftSprinting && $0.habitatDomain == .woodlandTerritory }),
        ("Find slow or climbing animals", { $0.mobilityCharacteristic == .sluggishMovement || $0.mobilityCharacteristic == .arborealClimbing }),
        ("Find domestic omnivores", { $0.habitatDomain == .domesticatedRealm && $0.nourishmentPreference == .omnivorousDiet }),
        ("Find wild predators", { $0.nourishmentPreference == .carnivorousDiet && $0.habitatDomain != .domesticatedRealm }),
        ("Find medium-sized animals", { $0.physicalDimension == .intermediateStature }),
        ("Find arctic animals", { $0.habitatDomain == .arcticTundra }),
        ("Find savannah predators", { $0.habitatDomain == .savannahExpanse && $0.nourishmentPreference == .carnivorousDiet }),
        ("Find animals that climb trees", { $0.mobilityCharacteristic == .arborealClimbing }),
        ("Find large wild animals", { $0.physicalDimension == .colossalStature && $0.habitatDomain != .domesticatedRealm }),
        ("Find small domestic animals", { $0.physicalDimension == .diminutiveStature && $0.habitatDomain == .domesticatedRealm }),
        ("Find forest herbivores", { $0.habitatDomain == .woodlandTerritory && $0.nourishmentPreference == .herbivorousDiet }),
        ("Find fast carnivores", { $0.mobilityCharacteristic == .swiftSprinting && $0.nourishmentPreference == .carnivorousDiet })
    ]

    func synthesizeRiddle(forSpecimensOnGrid specimens: [WildernessSpecimen], maxSelections: Int) -> ChallengeRiddle {
        let shuffledTemplates = complexRiddleTemplates.shuffled()

        for (phrase, predicate) in shuffledTemplates {
            let matchingSpecimens = specimens.filter(predicate)
            // Must have at least 1 match, not all specimens, and within max limit
            if matchingSpecimens.count >= 1 &&
               matchingSpecimens.count < specimens.count &&
               matchingSpecimens.count <= maxSelections {
                return ChallengeRiddle(
                    interrogativePhrase: phrase,
                    validResponseSpecimens: matchingSpecimens,
                    riddleDifficultyTier: .advancedLevel
                )
            }
        }

        // Fallback to elementary fabricator with same max limit
        let elementaryFabricator = ElementaryRiddleFabricator()
        let fallbackRiddle = elementaryFabricator.synthesizeRiddle(forSpecimensOnGrid: specimens, maxSelections: maxSelections)
        return ChallengeRiddle(
            interrogativePhrase: fallbackRiddle.interrogativePhrase,
            validResponseSpecimens: fallbackRiddle.validResponseSpecimens,
            riddleDifficultyTier: .advancedLevel
        )
    }
}

final class RiddleOrchestrationEngine {

    static let sharedInstance = RiddleOrchestrationEngine()

    // Maximum selections per difficulty level
    static let beginnerMaxSelections = 5
    static let advancedMaxSelections = 8

    private let elementaryFabricator: RiddleFabricationProtocol
    private let advancedFabricator: RiddleFabricationProtocol

    private init() {
        elementaryFabricator = ElementaryRiddleFabricator()
        advancedFabricator = AdvancedRiddleFabricator()
    }

    func generateRiddle(forDifficulty isAdvanced: Bool, withSpecimens specimens: [WildernessSpecimen]) -> ChallengeRiddle {
        if isAdvanced {
            return advancedFabricator.synthesizeRiddle(forSpecimensOnGrid: specimens, maxSelections: Self.advancedMaxSelections)
        } else {
            return elementaryFabricator.synthesizeRiddle(forSpecimensOnGrid: specimens, maxSelections: Self.beginnerMaxSelections)
        }
    }
}
