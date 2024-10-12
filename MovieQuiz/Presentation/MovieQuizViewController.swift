import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate  {
    
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    // переменная с индексом текущего вопроса, начальное значение 0 (так как индекс в массиве начинается с 0)
    private var currentQuestionIndex = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private let alertPresenter: AlertPresenterProtocol = AlertPresenter()
    
    private let statisticService: StatisticServiceProtocol = StatisticService()
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderWidth = 0
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        yesButton.isEnabled = true
    }
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        // метод красит рамку
        if isCorrect == true {
            correctAnswers += 1
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            imageView.layer.cornerRadius = 20
            yesButton.isEnabled = false
        }
        else {
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            imageView.layer.cornerRadius = 20
            yesButton.isEnabled = false
        }
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // слабая ссылка на self
            guard let self = self else { return } // разворачиваем слабую ссылку
            // код, который мы хотим вызвать через 1 секунду
            self.showNextQuestionOrResults()
        }
    }
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let message = correctAnswers == questionsAmount ?
            "Ваш результат: \(correctAnswers)/10 " :
            "Количество сыгранных квизов: \(statisticService.gamesCount)n" +
            "Рекорд: \(statisticService.bestGame.correct)/10 (\(statisticService.bestGame.date))n" +
            "Средняя точность: \(statisticService.totalAccuracy)"
           let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть ещё раз",
            completion: {[weak self] _ in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                guard let questionFactory = self.questionFactory else {
                    return
                }
                questionFactory.requestNextQuestion()
            }
           )
            alertPresenter.show(alertModel)

            imageView.layer.cornerRadius = 20
        }
        else {
            currentQuestionIndex += 1
            // идём в состояние "Вопрос показан"
            guard let questionFactory = questionFactory else {
                return
            }
            questionFactory.requestNextQuestion()
                imageView.layer.cornerRadius = 20
        }
    }
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает!!!
    private func show(quiz result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in // слабая ссылка на self
            guard let self = self else { return } 
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            guard let questionFactory = questionFactory else {
                return
            }
            questionFactory.requestNextQuestion()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion()
        
        alertPresenter.delegate = self
        
        var gameResult = GameResult(correct: <#T##Int#>, total: <#T##Int#>, date: <#T##Date#>)

        noButton.layer.cornerRadius = 15
        yesButton.layer.cornerRadius = 15
        noButton.clipsToBounds = true // разрешает обрезать вью по маске
        yesButton.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
    }
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}

extension MovieQuizViewController: AlertPresenterDelegate {
    func show(alertVC: UIAlertController) {
        present(alertVC, animated: true)
    }
    
    
}
