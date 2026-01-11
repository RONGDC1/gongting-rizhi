//
//  EndingView.swift
//  gongtingrizhi
//
//  Created by 朱荣 on 2026/1/10.
//

import SwiftUI

struct EndingView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        ZStack {
            // 背景色
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.95, green: 0.92, blue: 0.85), Color(red: 0.98, green: 0.96, blue: 0.92)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if gameManager.showingLogsView {
                // 日志查看模式
                LogsViewMode(gameManager: gameManager)
            } else {
                // 结局页模式
                EndingContentView(gameManager: gameManager)
            }
        }
    }
}

// MARK: - 结局内容视图
struct EndingContentView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // 结局标题
                Text("游戏结束")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top, 60)
                
                // 结局类型显示
                if let endingType = gameManager.endingType {
                    VStack(spacing: 16) {
                        Text(endingType == .abdication ? "👑" : "⚔️")
                            .font(.system(size: 80))
                        
                        Text(endingType.rawValue)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(endingType == .abdication ? .primary : .red)
                    }
                    .padding(.vertical, 20)
                }
                
                // 结束语
                Text("日志落笔于此。有些事被郑重记下，有些，只在风过的瞬间悄悄发生...")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 50)
                    .padding(.bottom, 20)
                
                // 操作按钮
                VStack(spacing: 16) {
                    // 翻看日志按钮
                    Button(action: {
                        gameManager.showLogsView()
                    }) {
                        Text("翻看日志")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(red: 0.7, green: 0.5, blue: 0.3), Color(red: 0.8, green: 0.6, blue: 0.4)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                    }
                    
                    // 重开一局按钮
                    Button(action: {
                        gameManager.restart()
                    }) {
                        Text("重新开始")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(red: 0.7, green: 0.5, blue: 0.3), Color(red: 0.8, green: 0.6, blue: 0.4)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - 日志查看模式
struct LogsViewMode: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航
            HStack {
                Button(action: {
                    gameManager.hideLogsView()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("宫廷日志")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 占位，保持居中
                Color.clear
                    .frame(width: 30)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))
            
            // 日志列表
            ScrollView {
                VStack(spacing: 12) {
                    if gameManager.logs.isEmpty {
                        VStack(spacing: 16) {
                            Text("📜")
                                .font(.system(size: 60))
                            Text("暂无日志记录")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else {
                        ForEach(gameManager.logs) { log in
                            LogRowView(log: log)
                                .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            
            // 底部按钮
            Button(action: {
                gameManager.restart()
            }) {
                Text("重开一局")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.7, green: 0.5, blue: 0.3), Color(red: 0.8, green: 0.6, blue: 0.4)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    EndingView(gameManager: {
        let manager = GameManager()
        manager.startNewGame()
        manager.endingType = .abdication
        return manager
    }())
}
