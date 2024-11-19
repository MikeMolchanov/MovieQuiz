//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Михаил on 18.11.2024.
//

import UIKit

final class MovieQuizPresenter {
    
    private var currentQuestionIndex: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    let questionsAmount: Int = 10
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var correctAnswers: Int = 0
    
        
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            let text = "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!" // ОШИБКА 1: `correctAnswers` не определено
                
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
                viewController?.show(result: viewModel) // ОШИБКА 2: `show(quiz:)` не определён
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion() // ОШИБКА 3: `questionFactory` не определено
        }
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
            
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func yesButtonClicked() {
            didAnswer(isYes: true)
    }
        
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
        
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
            
        let givenAnswer = isYes
            
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
        
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
        
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
        
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)" // ОШИБКА: `currentQuestionIndex` и `questionsAmount` неопределены
        )
    }
}
