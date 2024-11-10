//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Михаил on 11.09.2024.
//

import Foundation
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)  
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
}
