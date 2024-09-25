//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Михаил on 21.09.2024.
//

import UIKit

class AlertPresenter: UIViewController, AlertPresenterProtocol  {
    private var questionFactory: QuestionFactoryProtocol?
    func show(quiz result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in // слабая ссылка на self
            guard let self = self else { return } // разворачиваем слабую ссылку
            MovieQuizViewController.currentQuestionIndex = 0
            MovieQuizViewController.correctAnswers = 0
            guard let questionFactory = questionFactory else {
                return
            }
            questionFactory.requestNextQuestion()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}
