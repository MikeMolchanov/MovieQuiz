//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Михаил on 06.10.2024.
//

import Foundation
protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(my: GameResult)
}
