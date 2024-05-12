//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Марк on 12.05.2024.
//

import Foundation
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
