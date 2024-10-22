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
            let correct: Int = storage.integer(forKey: Keys.correct.rawValue)
            let total: Int = storage.integer(forKey: "total")
            let date: Date = storage.object(forKey: "date") as? Date ?? Date()
                    
            return GameResult(correct: correct, total: total, date: date.dateTimeString)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: "total")
            storage.set(newValue.date, forKey: "date") 
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
            return Double(storage.integer(forKey: "correctAnswers")) * 100 / Double(gamesCount) 
        }
    }
    
    func store(my: GameResult) {
        
        gamesCount += 1
        storage.set( my.correct , forKey: "correctAnswers")
        
        my.isBetterThan(another: bestGame, statisticServiceInstance: self)
    }
}


