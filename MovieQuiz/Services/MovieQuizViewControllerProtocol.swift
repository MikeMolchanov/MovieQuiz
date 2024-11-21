//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Михаил on 21.11.2024.
//

import Foundation
protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(step: QuizStepViewModel)
    func show(quiz result: AlertModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}
