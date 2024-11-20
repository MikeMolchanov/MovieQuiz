//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Михаил on 18.11.2024.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var currentQuestionIndex: Int = 0
    private let statisticService: StatisticServiceProtocol!
    private weak var viewController: MovieQuizViewController?
    private var questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    
    var questionFactory: QuestionFactoryProtocol?
    
    var correctAnswers: Int = 0
    
    
    init(viewController: MovieQuizViewController, correctAnswers: Int, questionsAmount: Int, currentDate: Date) {
        self.viewController = viewController

        statisticService = StatisticService()
        
        self.correctAnswers = correctAnswers
        self.questionsAmount = questionsAmount
        self.currentDate = currentDate
        self.gameResult = GameResult(correct: correctAnswers, total: questionsAmount, date: currentDate.dateTimeString)

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
            viewController.showLoadingIndicator()
        }
    
    var gameResult: GameResult
    
    var currentDate = Date()
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
               questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
                viewController?.showNetworkError(message: message)
    }
    
    func makeResultsMessage() -> String {
            statisticService.store(my: gameResult)
            
            let bestGame = statisticService.bestGame
            
            let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
            let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
            + " (\(bestGame.date))"
            let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            let resultMessage = [
                currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
            ].joined(separator: "\n")
            
            return resultMessage
        }
//    func showNextQuestionOrResults() {
//        if self.isLastQuestion() {
//            let message = "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
//                
//            let viewModel = AlertModel(
//                title: "Этот раунд окончен!",
//                message: message,
//                buttonText: "Сыграть ещё раз",
//                completion: {[weak self] _ in
//                    guard let self = self else { return }
//                    self.restartGame()
//                    
//                    guard let questionFactory = self.questionFactory else {
//                        return
//                    }
//                    questionFactory.requestNextQuestion()
//                }
//               )
//                viewController?.show(quiz: viewModel) // ОШИБКА 2: `show(quiz:)` не определён
//        } else {
//            self.switchToNextQuestion()
//            questionFactory?.requestNextQuestion() // ОШИБКА 3: `questionFactory` не определено
//        }
//    }
    
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
    
//    func showAnswerResult(isCorrect: Bool) {
//        didAnswer(isCorrectAnswer: isCorrect)
//            
//        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
//            
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
//            guard let self = self else { return }
//            self.showNextQuestionOrResults()
//        }
//    }
    
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
            
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
            }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)

        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    private func proceedToNextQuestionOrResults() {
            if self.isLastQuestion() {
                let text = correctAnswers == self.questionsAmount ?
                "Поздравляем, вы ответили на 10 из 10!" :
                "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"

                let viewModel = AlertModel(
                    title: "Этот раунд окончен!",
                    message: makeResultsMessage(),
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
                    viewController?.show(quiz: viewModel)
            } else {
                self.switchToNextQuestion()
                questionFactory?.requestNextQuestion()
            }
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
        questionFactory?.requestNextQuestion()
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

