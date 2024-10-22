//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Михаил on 21.09.2024.
//

import UIKit

class AlertPresenter: AlertPresenterProtocol  {
    
    weak var delegate: AlertPresenterDelegate?
    
    private var questionFactory: QuestionFactoryProtocol?
    func show(_ model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: model.buttonText,
                style: .default,
                handler: model.completion
            )
        )
        
        delegate?.show(alertVC: alert)
    }
}
