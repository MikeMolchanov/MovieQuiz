//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Михаил on 07.09.2024.
//

import Foundation
struct QuizQuestion {
    let image: Data
    // строка с вопросом о рейтинге фильма
    let text: String
    // булевое значение (true, false), правильный ответ на вопрос
    let correctAnswer: Bool
}
