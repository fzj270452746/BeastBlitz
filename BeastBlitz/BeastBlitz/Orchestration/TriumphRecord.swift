//
//  TriumphRecord.swift
//  BeastBlitz
//
//  Score and leaderboard persistence model
//

import Foundation

struct TriumphRecord: Codable, Comparable {
    let accumulatedPoints: Int
    let competitionEpoch: Date
    let playerMoniker: String
    let wasAdvancedChallenge: Bool
    let roundsConquered: Int
    let maximumComboStreak: Int

    static func < (lhs: TriumphRecord, rhs: TriumphRecord) -> Bool {
        return lhs.accumulatedPoints > rhs.accumulatedPoints
    }
}

final class TriumphChronicleVault {

    static let sharedInstance = TriumphChronicleVault()

    private let persistenceKeyElementary = "ElementaryTriumphRecords"
    private let persistenceKeyAdvanced = "AdvancedTriumphRecords"
    private let maximumRecordsRetained = 10

    private init() {}

    func archiveNewTriumph(_ record: TriumphRecord) {
        var existingRecords = retrieveTriumphRecords(forAdvancedMode: record.wasAdvancedChallenge)
        existingRecords.append(record)
        existingRecords.sort()

        if existingRecords.count > maximumRecordsRetained {
            existingRecords = Array(existingRecords.prefix(maximumRecordsRetained))
        }

        let storageKey = record.wasAdvancedChallenge ? persistenceKeyAdvanced : persistenceKeyElementary

        if let encodedData = try? JSONEncoder().encode(existingRecords) {
            UserDefaults.standard.set(encodedData, forKey: storageKey)
        }
    }

    func retrieveTriumphRecords(forAdvancedMode isAdvanced: Bool) -> [TriumphRecord] {
        let storageKey = isAdvanced ? persistenceKeyAdvanced : persistenceKeyElementary

        guard let storedData = UserDefaults.standard.data(forKey: storageKey),
              let decodedRecords = try? JSONDecoder().decode([TriumphRecord].self, from: storedData) else {
            return []
        }

        return decodedRecords.sorted()
    }

    func retrievePinnacleScore(forAdvancedMode isAdvanced: Bool) -> Int {
        let records = retrieveTriumphRecords(forAdvancedMode: isAdvanced)
        return records.first?.accumulatedPoints ?? 0
    }

    func obliterateAllRecords() {
        UserDefaults.standard.removeObject(forKey: persistenceKeyElementary)
        UserDefaults.standard.removeObject(forKey: persistenceKeyAdvanced)
    }
}
