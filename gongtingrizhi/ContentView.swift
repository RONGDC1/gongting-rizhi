//
//  ContentView.swift
//  gongtingrizhi
//
//  Created by 朱荣 on 2026/1/10.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameManager = GameManager()
    
    var body: some View {
        Group {
            switch gameManager.gameState {
            case .emperorConfirm:
                EmperorConfirmView(gameManager: gameManager)
            case .playing:
                MainGameView(gameManager: gameManager)
            case .ended:
                EndingView(gameManager: gameManager)
            }
        }
        .onAppear {
            if gameManager.emperor == nil {
                gameManager.startNewGame()
            }
        }
    }
}

#Preview {
    ContentView()
}
