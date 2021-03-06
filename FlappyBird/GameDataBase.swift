//
//  GameModel.swift
//  FlappyBird
//
//  Created by Gabriela Zorzo on 03/09/21.
//

import Foundation

class GameDataBase {
    private let userDefaults = UserDefaults.standard
    static var standard = GameDataBase()
    
    private let highScoreKey: String = "score"
    
    private init() {}
    
    func getHighScore() -> Int {
        let highScore = userDefaults.integer(forKey: highScoreKey)
        return highScore
    }
    
    func setHighScore(newHighScore: Int) {
        let currentHighScore = getHighScore()
        if newHighScore > currentHighScore {
            userDefaults.setValue(newHighScore, forKey: highScoreKey)
        }
    }
}
