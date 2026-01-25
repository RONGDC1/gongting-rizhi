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
            case .emperorConfirm: // 开局确认界面
                EmperorConfirmView(gameManager: gameManager)
            case .playing: // 主游戏界面（包含Tab导航）
                MainContainerView(gameManager: gameManager)
            case .ended: // 结局界面
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
