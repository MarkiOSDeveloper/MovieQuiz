import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
   
    
    
    
 
    
    // MARK: - IB Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    // MARK: - Public Properties
    // для состояния "Вопрос показан"
    struct ViewModel {
        let image: UIImage
        let qustion: String
        let questionNumber: String
    }
    // MARK: - Private Properties
    // переменная с индексом текущего вопроса, начальное значение 0
    // (по этому индексу будем искать вопрос в массиве, где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex = 0
    
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    //Кол-во вопросов Квиза
    private let questionsAmount: Int = 10
    //Фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    //Вопрос который видит пользователь
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Initializers
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        let questionFactory = QuestionFactory()
               questionFactory.setup(delegate: self)
               self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
        //questionFactory = QuestionFactory(delegate: self)
        
        //if let firstQuestion = questionFactory.requestNextQuestion() {
            //currentQuestion = firstQuestion
            //let viewModel = convert(model: firstQuestion)
            //show(quiz: viewModel)
        }
    
    // MARK: - QuestionFactoryDelegate

func didReceiveNextQuestion(question: QuizQuestion?) {
        // проверка, что вопрос не nil
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async {[weak self] in
            self?.show(quiz: viewModel)
        }
    }
    // MARK: - IB Actions

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        sender.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            sender.isEnabled = true
        }
           // код, который мы хотим вызвать через 1 секунду
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false // 2
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        sender.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            sender.isEnabled = true
        }
    }
    // MARK: - Public Methods
    // MARK: - Private Methods
   
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel){
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        //Счетчик правельных ответов
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true // 1
        imageView.layer.borderWidth = 8 // 2
        imageView.layer.borderColor = isCorrect ? UIColor.yp1Green.cgColor : UIColor.yp1Red.cgColor // 3
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in //Слабая ссылка на self
            guard let self = self else {return} // Разворачиваем слабую Ссылку
           // код, который мы хотим вызвать через 1 секунду

           self.imageView.layer.borderColor = UIColor.clear.cgColor
           self.showNextQuestionOrResults()
        }
    }
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = "Ваш результат: \(correctAnswers)/10" // 1
                    let viewModel = QuizResultsViewModel( // 2
                        title: "Этот раунд окончен!",
                        text: text,
                        buttonText: "Сыграть ещё раз")
                    show(quiz: viewModel) // 3
        } else {
            currentQuestionIndex += 1
            //if let nextQuestion = questionFactory.requestNextQuestion(){
                //currentQuestion = nextQuestion
                //let viewModel = convert(model: nextQuestion)
                //show(quiz: viewModel)
            questionFactory.requestNextQuestion()
            }
        }
    
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in //Слабая ссылка на self
            guard let self = self else { return } //Разворачиваем слабую ссылку
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            //if let firstQuestion = self.questionFactory.requestNextQuestion() {
                //self.currentQuestion = firstQuestion
                //let viewModel = self.convert(model: firstQuestion)
//self.show(quiz: viewModel)
            self.questionFactory.requestNextQuestion()
            
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}
/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
