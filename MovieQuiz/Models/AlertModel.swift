//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Михаил on 19.09.2024.
//

import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    var completion: (UIAlertAction)-> Void
    init(title: String, message: String, buttonText: String, completion: @escaping (UIAlertAction) -> Void) {
        self.title = title
        self.message = message
        self.buttonText = buttonText
        self.completion = completion
    }
}
