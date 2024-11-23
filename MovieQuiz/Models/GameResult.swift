//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Михаил on 06.10.2024.
//

import Foundation
struct GameResult {
    var correct: Int
    var total: Int //количество вопросов квиза
    var date: String
    
    func isBetterThan(another:GameResult)-> Bool {
        if self.correct > another.correct {
            return true
        }
        return false
    }
}
