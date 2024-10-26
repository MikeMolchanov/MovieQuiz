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
        case total
        case date
        case correctAnswers
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
            let total: Int = storage.integer(forKey: Keys.total.rawValue)
            let date: Date = storage.object(forKey: Keys.total.rawValue) as? Date ?? Date()
                    
            return GameResult(correct: correct, total: total, date: date.dateTimeString)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.total.rawValue)
        }
    }
    
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            guard gamesCount > 0 else {
                return 0
            }
            return Double(storage.integer(forKey: Keys.correctAnswers.rawValue)) * 100 / (Double(gamesCount) * 10)
        }
    }
    
    func store(my: GameResult) {
        
        gamesCount += 1
        storage.set( my.correct + storage.integer(forKey: Keys.correctAnswers.rawValue) , forKey: Keys.correctAnswers.rawValue)
        
        
        my.isBetterThan(another: bestGame, statisticServiceInstance: self)
    }
}


