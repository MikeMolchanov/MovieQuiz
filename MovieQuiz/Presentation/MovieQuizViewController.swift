import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate  {
    
    private let presenter = MovieQuizPresenter()
    private var correctAnswers = 0
    
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private let alertPresenter: AlertPresenterProtocol = AlertPresenter()
    
    private let statisticService: StatisticServiceProtocol = StatisticService()
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] _ in 
                guard let self = self else { return }
                
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                
                self.questionFactory?.requestNextQuestion()
        }
            
        alertPresenter.show(model)
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
    func showAnswerResult(isCorrect: Bool) {
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
        if presenter.isLastQuestion() {
            let currentDate = Date()
            let gameResult = GameResult(correct: correctAnswers, total: presenter.questionsAmount, date: currentDate.dateTimeString)
            statisticService.store(my: gameResult)
            let message = "Ваш результат: \(correctAnswers)/10 \n" +
            "Количество сыгранных квизов: \(statisticService.gamesCount)\n" +
            "Рекорд: \(statisticService.bestGame.correct)/10 (\(statisticService.bestGame.date))\n" +
            "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
           let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть ещё раз",
            completion: {[weak self] _ in
                guard let self = self else { return }
                presenter.resetQuestionIndex() 
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
            presenter.switchToNextQuestion()
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
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in 
            guard let self = self else { return } 
            presenter.resetQuestionIndex()
            self.correctAnswers = 0
            guard let questionFactory = questionFactory else {
                return
            }
            questionFactory.requestNextQuestion()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
            presenter.currentQuestion = currentQuestion
            presenter.yesButtonClicked()
    }
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        presenter.viewController = self
        questionFactory.delegate = self //?
        self.questionFactory = questionFactory //?
        
        questionFactory.loadData()
        
        alertPresenter.delegate = self //?
        
        showLoadingIndicator()

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
        let viewModel = presenter.convert(model: question)
        
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
