//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Михаил on 21.09.2024.
//

import Foundation
protocol AlertPresenterProtocol: AnyObject {
    var delegate: AlertPresenterDelegate? {get set}
    
    func show(_ result: AlertModel)
}
