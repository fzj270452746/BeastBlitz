//
//  WildernessSpecimen.swift
//  BeastBlitz
//
//  Core animal model with biological traits
//

import UIKit

enum NourishmentHabit: String, CaseIterable, Codable {
    case herbivorousDiet = "herbivore"
    case carnivorousDiet = "carnivore"
    case omnivorousDiet = "omnivore"
}

enum NaturalDwelling: String, CaseIterable, Codable {
    case woodlandTerritory = "forest"
    case savannahExpanse = "savannah"
    case arcticTundra = "arctic"
    case domesticatedRealm = "domestic"
    case alpineHighlands = "mountain"
}

enum LocomotionPattern: String, CaseIterable, Codable {
    case terrestrialMobility = "walks"
    case arborealClimbing = "climbs"
    case sluggishMovement = "slow"
    case swiftSprinting = "fast"
}

enum CorporealMagnitude: String, CaseIterable, Codable {
    case diminutiveStature = "small"
    case intermediateStature = "medium"
    case colossalStature = "large"
}

struct WildernessSpecimen: Equatable, Codable {
    let appellationIdentifier: String
    let visualAssetName: String
    let nourishmentPreference: NourishmentHabit
    let habitatDomain: NaturalDwelling
    let mobilityCharacteristic: LocomotionPattern
    let physicalDimension: CorporealMagnitude
    let possessesFurCoating: Bool
    let exhibitsStripedMarkings: Bool
    let exhibitsSpottedMarkings: Bool
    let manifestsTailAppendage: Bool

    static func == (lhs: WildernessSpecimen, rhs: WildernessSpecimen) -> Bool {
        return lhs.appellationIdentifier == rhs.appellationIdentifier
    }
}

final class SpecimenCatalogueRepository {

    static let sharedInstance = SpecimenCatalogueRepository()

    private(set) var availableSpecimens: [WildernessSpecimen] = []

    private init() {
        initializeSpecimenRegistry()
    }

    private func initializeSpecimenRegistry() {
        availableSpecimens = [
            WildernessSpecimen(
                appellationIdentifier: "Bear",
                visualAssetName: "bear",
                nourishmentPreference: .omnivorousDiet,
                habitatDomain: .woodlandTerritory,
                mobilityCharacteristic: .terrestrialMobility,
                physicalDimension: .colossalStature,
                possessesFurCoating: true,
                exhibitsStripedMarkings: false,
                exhibitsSpottedMarkings: false,
                manifestsTailAppendage: true
            ),
            WildernessSpecimen(
                appellationIdentifier: "Cat",
                visualAssetName: "cat",
                nourishmentPreference: .carnivorousDiet,
                habitatDomain: .domesticatedRealm,
                mobilityCharacteristic: .swiftSprinting,
                physicalDimension: .diminutiveStature,
                possessesFurCoating: true,
                exhibitsStripedMarkings: false,
                exhibitsSpottedMarkings: false,
                manifestsTailAppendage: true
            ),
            WildernessSpecimen(
                appellationIdentifier: "Cow",
                visualAssetName: "cow",
                nourishmentPreference: .herbivorousDiet,
                habitatDomain: .domesticatedRealm,
                mobilityCharacteristic: .terrestrialMobility,
                physicalDimension: .colossalStature,
                possessesFurCoating: true,
                exhibitsStripedMarkings: false,
                exhibitsSpottedMarkings: true,
                manifestsTailAppendage: true
            ),
            WildernessSpecimen(
                appellationIdentifier: "Dog",
                visualAssetName: "dog",
                nourishmentPreference: .omnivorousDiet,
                habitatDomain: .domesticatedRealm,
                mobilityCharacteristic: .swiftSprinting,
                physicalDimension: .intermediateStature,
                possessesFurCoating: true,
                exhibitsStripedMarkings: false,
                exhibitsSpottedMarkings: false,
                manifestsTailAppendage: true
            ),
            WildernessSpecimen(
                appellationIdentifier: "Elk",
                visualAssetName: "elk",
                nourishmentPreference: .herbivorousDiet,
                habitatDomain: .woodlandTerritory,
                mobilityCharacteristic: .swiftSprinting,
                physicalDimension: .colossalStature,
                possessesFurCoating: true,
                exhibitsStripedMarkings: false,
                exhibitsSpottedMarkings: false,
                manifestsTailAppendage: true
            ),
            WildernessSpecimen(
                appellationIdentifier: "Fox",
                visualAssetName: "fox",
                nourishmentPreference: .omnivorousDiet,
                habitatDomain: .woodlandTerritory,
                mobilityCharacteristic: .swiftSprinting,
                physicalDimension: .diminutiveStature,
                possessesFurCoating: true,
                exhibitsStripedMarkings: false,
                exhibitsSpottedMarkings: false,
                manifestsTailAppendage: true
            ),
            WildernessSpecimen(
                appellationIdentifier: "Giraffe",
                visualAssetName: "giraffe",
                nourishmentPreference: .herbivorousDiet,
                habitatDomain: .savannahExpanse,
                mobilityCharacteristic: .terrestrialMobility,
                physicalDimension: .colossalStature,
                possessesFurCoating: true,
                exhibitsStripedMarkings: false,
                exhibitsSpottedMarkings: true,
                manifestsTailAppendage: true
            ),
            WildernessSpecimen(
                appellationIdentifier: "Koala",
                visualAssetName: "koala",
                nourishmentPreference: .herbivorousDiet,
                habitatDomain: .woodlandTerritory,
                mobilityCharacteristic: .arborealClimbing,
                physicalDimension: .diminutiveStature,
                possessesFurCoating: true,
                exhibitsStripedMarkings: false,
                exhibitsSpottedMarkings: false,
                manifestsTailAppendage: false
            ),
            WildernessSpecimen(
                appellationIdentifier: "Lion",
                visualAssetName: "lion",
                nourishmentPreference: .carnivorousDiet,
                habitatDomain: .savannahExpanse,
                mobilityCharacteristic: .swiftSprinting,
                physicalDimension: .colossalStature,
                possessesFurCoating: true,
                exhibitsStripedMarkings: false,
                exhibitsSpottedMarkings: false,
                manifestsTailAppendage: true
            ),
            WildernessSpecimen(
                appellationIdentifier: "Monkey",
                visualAssetName: "monkey",
                nourishmentPreference: .omnivorousDiet,
                habitatDomain: .woodlandTerritory,
                mobilityCharacteristic: .arborealClimbing,
                physicalDimension: .diminutiveStature,
                possessesFurCoating: true,
                exhibitsStripedMarkings: false,
                exhibitsSpottedMarkings: false,
                manifestsTailAppendage: true
            ),
            WildernessSpecimen(
                appellationIdentifier: "Panda",
                visualAssetName: "panda",
                nourishmentPreference: .herbivorousDiet,
                habitatDomain: .woodlandTerritory,
                mobilityCharacteristic: .sluggishMovement,
                physicalDimension: .colossalStature,
                possessesFurCoating: true,
                exhibitsStripedMarkings: false,
                exhibitsSpottedMarkings: false,
                manifestsTailAppendage: true
            ),
            WildernessSpecimen(
                appellationIdentifier: "Polar Bear",
                visualAssetName: "polar bear",
                nourishmentPreference: .carnivorousDiet,
                habitatDomain: .arcticTundra,
                mobilityCharacteristic: .terrestrialMobility,
                physicalDimension: .colossalStature,
                possessesFurCoating: true,
                exhibitsStripedMarkings: false,
                exhibitsSpottedMarkings: false,
                manifestsTailAppendage: true
            ),
            WildernessSpecimen(
                appellationIdentifier: "Rabbit",
                visualAssetName: "rabbit",
                nourishmentPreference: .herbivorousDiet,
                habitatDomain: .domesticatedRealm,
                mobilityCharacteristic: .swiftSprinting,
                physicalDimension: .diminutiveStature,
                possessesFurCoating: true,
                exhibitsStripedMarkings: false,
                exhibitsSpottedMarkings: false,
                manifestsTailAppendage: true
            ),
            WildernessSpecimen(
                appellationIdentifier: "Sloth",
                visualAssetName: "sloth",
                nourishmentPreference: .herbivorousDiet,
                habitatDomain: .woodlandTerritory,
                mobilityCharacteristic: .sluggishMovement,
                physicalDimension: .intermediateStature,
                possessesFurCoating: true,
                exhibitsStripedMarkings: false,
                exhibitsSpottedMarkings: false,
                manifestsTailAppendage: true
            ),
            WildernessSpecimen(
                appellationIdentifier: "Tiger",
                visualAssetName: "tiger",
                nourishmentPreference: .carnivorousDiet,
                habitatDomain: .woodlandTerritory,
                mobilityCharacteristic: .swiftSprinting,
                physicalDimension: .colossalStature,
                possessesFurCoating: true,
                exhibitsStripedMarkings: true,
                exhibitsSpottedMarkings: false,
                manifestsTailAppendage: true
            )
        ]
    }

    func retrieveRandomizedSpecimen() -> WildernessSpecimen {
        return availableSpecimens.randomElement()!
    }

    func retrieveSpecimensByAttribute(_ filtrationClosure: (WildernessSpecimen) -> Bool) -> [WildernessSpecimen] {
        return availableSpecimens.filter(filtrationClosure)
    }
}
