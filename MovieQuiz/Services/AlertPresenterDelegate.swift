//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Михаил on 21.09.2024.
//

import Foundation

protocol AlertPresenterDelegate: AnyObject {
    func show(quiz result: AlertModel)
}
