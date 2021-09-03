//
//  GameModel.swift
//  FlappyBird
//
//  Created by Gabriela Zorzo on 03/09/21.
//

import Foundation

class GameModel: ObservableObject {
    @Published var highScore : Int = 0 {
        didSet {
            saveScore()
        }
    }
    
    let scoreKey: String = "score"
    
    init() {
        getScore()
    }
    
    func getScore() {
        guard
            let data = UserDefaults.standard.data(forKey: scoreKey),
            let savedScore = try? JSONDecoder().decode(Int.self, from: data)
        else { return }
        
        self.highScore = savedScore
    }
    
    func updateScore(newScore: Int) {
        if newScore > highScore {
            highScore = newScore
        }
    }
    
    func saveScore() {
        if let encodedData = try? JSONEncoder().encode(highScore) {
            UserDefaults.standard.set(encodedData, forKey: scoreKey)
            
        }
    }
}
