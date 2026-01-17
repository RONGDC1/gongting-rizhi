//
//  EmperorConfirmView.swift
//  gongtingrizhi
//
//  Created by 朱荣 on 2026/1/10.
//

import SwiftUI

struct EmperorConfirmView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        ZStack {
            // 背景
            Color(red: 0.93, green: 0.9, blue: 0.82)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // 固定文案展示
                VStack(spacing: 16) {
                    Text("人生已经开始，")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.64, green: 0.4, blue: 0.23))
                    
                    Text("你无法选择出身、性格与局势。")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.64, green: 0.4, blue: 0.23))
                    
                    Text("你能选择的，")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.64, green: 0.4, blue: 0.23))
                    
                    Text("只有在这一刻如何判断，")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.64, green: 0.4, blue: 0.23))
                    
                    Text("以及判断之后，")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.64, green: 0.4, blue: 0.23))
                    
                    Text("愿意承担什么。")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.64, green: 0.4, blue: 0.23))
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                
                Spacer()
                
                // 承此天命按钮
                Button(action: {
                    gameManager.confirmEmperorAndStart()
                }) {
                    Text("承此天命")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 1, green: 0.99, blue: 0.9))
                        .frame(width: 223)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.64, green: 0.4, blue: 0.23))
                        .cornerRadius(223/2)
                }
                .padding(.bottom, 48)
            }
        }
    }
}

#Preview {
    EmperorConfirmView(gameManager: {
        let manager = GameManager()
        manager.startNewGame()
        return manager
    }())
}
