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
            // 背景色（类似羊皮纸）
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.95, green: 0.92, blue: 0.85), Color(red: 0.98, green: 0.96, blue: 0.92)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // 标题
                    VStack(spacing: 8) {
                        Text("👑")
                            .font(.system(size: 40))
                        Text("创建角色")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.15))
                    }
                    .padding(.top, 40)
                    
                    if let emperor = gameManager.emperor {
                        // 皇帝信息卡片
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 16) {
                                InfoRow(label: "姓名", value: emperor.name)
                                InfoRow(label: "年龄", value: "\(emperor.age)岁")
                                InfoRow(label: "属性", value: "宅心仁厚")  // 固定属性文案
                                InfoRow(label: "年号", value: emperor.reignTitle)
                                InfoRow(
                                    label: "王朝",
                                    value: emperor.dynastyStatus.rawValue,
                                    isUnstable: emperor.dynastyStatus == .unstable
                                )
                            }
                            
                            // 换一换按钮
                            Button(action: {
                                gameManager.regenerateEmperor()
                            }) {
                                Text("换一换")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(red: 0.7, green: 0.5, blue: 0.3))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(red: 0.7, green: 0.5, blue: 0.3).opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 20)
                        
                        // 开始游戏按钮
                        Button(action: {
                            gameManager.confirmEmperorAndStart()
                        }) {
                            Text("开始游戏")
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
                        .padding(.top, 10)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var isUnstable: Bool = false
    
    var body: some View {
        HStack {
            Text(label + "：")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isUnstable ? .red : .primary)
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
