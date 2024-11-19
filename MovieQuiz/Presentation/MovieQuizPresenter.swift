//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Михаил on 18.11.2024.
//

import UIKit

final class MovieQuizPresenter {
    
    private var currentQuestionIndex: Int = 0
    private let statisticService: StatisticServiceProtocol = StatisticService()
    var questionFactory: QuestionFactoryProtocol?
    let questionsAmount: Int = 10
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var correctAnswers: Int = 0
    
        
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            let message = "Ваш результат: \(correctAnswers)/10 \n" +
            "Количество сыгранных квизов: \(statisticService.gamesCount)\n" +
            "Рекорд: \(statisticService.bestGame.correct)/10 (\(statisticService.bestGame.date))\n" +
            "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%" // ОШИБКА 1: `correctAnswers` не определено
                
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: message,
                buttonText: "Сыграть ещё раз",
                completion: {[weak self] _ in
                    guard let self = self else { return }
                    self.restartGame()
                    
                    guard let questionFactory = self.questionFactory else {
                        return
                    }
                    questionFactory.requestNextQuestion()
                }
               )
                viewController?.show(quiz: viewModel) // ОШИБКА 2: `show(quiz:)` не определён
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
            self?.viewController?.show(step: viewModel)
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
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer == true {
            correctAnswers += 1}
    }
        
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
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
