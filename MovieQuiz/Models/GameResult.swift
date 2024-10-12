//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Михаил on 06.10.2024.
//

import Foundation
struct GameResult {
    let correct: Int
    let total: Int //количество вопросов квиза
    let date: Date
    
    func isBetterThan(another:GameResult) {
        if correct > another.correct {
            StatisticService.bestGame.correct = correct
            StatisticService.bestGame.date = Date()
        }
    }
}
