//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Михаил on 06.10.2024.
//

import Foundation
// Расширяем при объявлении
final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
    }
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            var correct: Int = storage.integer(forKey: Keys.correct.rawValue)
            var total: Int = storage.integer(forKey: "total")
            var date: Date = storage.object(forKey: "date") as? Date ?? Date()
            var bestGame = GameResult(correct: correct, total: total, date: date)
        }
        set {
            var correct: Void = storage.set(newValue, forKey: Keys.correct.rawValue)
            var total: Void = storage.set(newValue, forKey: "total")
            var date: Date = storage.set(newValue, forKey: "date") as? Date ?? Date()
            var bestGame = GameResult(correct: correct, total: total, date: date)
        }
    }
    
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: "correctAnswers")
        }
    }
    
    var totalAccuracy: Double {
        get {
            guard gamesCount > 0 else {
                return 0
            }
            return Double(storage.integer(forKey: "correctAnswers")) * 100 / Double(gamesCount) * 10
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        
        gamesCount += 1
        storage.set( count , forKey: "correctAnswers")
        
        GameResult.isBetterThan(bestGame)
    }
}


