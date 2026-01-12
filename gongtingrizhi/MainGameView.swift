//
//  MainGameView.swift
//  gongtingrizhi
//
//  Created by 朱荣 on 2026/1/10.
//

import SwiftUI

// ========================================
// MARK: - 主游戏视图（测试版）
// ========================================
struct MainGameView: View {
    @ObservedObject var gameManager: GameManager

    var body: some View {
        ZStack {
            // 背景渐变色
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.95, green: 0.92, blue: 0.85),
                                            Color(red: 0.98, green: 0.96, blue: 0.92)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                // 年份与季节显示
                Text("第\(gameManager.currentYear)年 · \(gameManager.currentSeason.rawValue)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(.vertical, 12)

                ScrollView {
                    VStack(spacing: 20) {
                        if let emperor = gameManager.emperor {
                            EmperorCardView(
                                emperor: emperor,
                                currentYear: gameManager.currentYear,
                                currentSeason: gameManager.currentSeason
                            )
                            .padding(.horizontal, 20)
                        }

                        logsSection
                    }
                }

                nextRoundButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            
            // ⚠️ 事件弹窗
            if let event = gameManager.currentEvent {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {}
                    
                    EventPopupView(event: event, gameManager: gameManager)
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.25), value: event.id)
            }
            
            // ⚠️ Toast 消息提示（最终版）
            if let toast = gameManager.toastMessage {
                VStack {
                    Text(toast.text)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.7, green: 0.5, blue: 0.3),
                                    Color(red: 0.8, green: 0.6, blue: 0.4)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                    Spacer()
                }
            }
        }
    }

    // ========================================
    // MARK: - 顶部导航栏
    // ========================================
    private var topBar: some View {
        HStack {
            Text("首页")
                .font(.system(size: 18, weight: .semibold))
            Spacer()
            if gameManager.currentYear >= 3 {
                Button(action: { gameManager.abdicate() }) {
                    Text("退位")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.1))
    }

    // ========================================
    // MARK: - 记事簿日志模块
    // ========================================
    private var logsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("记事簿")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)

            if gameManager.logs.isEmpty {
                VStack(spacing: 16) {
                    Text("📜").font(.system(size: 60))
                    Text("暂无日志记录")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
                .padding(.bottom, 20)
            } else {
                ForEach(gameManager.logs) { log in
                    LogRowView(log: log)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
        }
        .padding(.top, 8)
    }

    // ========================================
    // MARK: - 下个回合按钮
    // ========================================
    private var nextRoundButton: some View {
        Button(action: { gameManager.nextRound() }) {
            Text("下个回合")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(red: 0.7, green: 0.5, blue: 0.3),
                                                    Color(red: 0.8, green: 0.6, blue: 0.4)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
        }
    }
}

// ========================================
// MARK: - 皇帝卡片视图
// ========================================
struct EmperorCardView: View {
    let emperor: Emperor
    let currentYear: Int
    let currentSeason: Season

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("👑").font(.system(size: 24))
                Text(emperor.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            }

            Text(emperor.title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)

            Divider()

            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    AttributeItem(label: "年龄", value: "\(emperor.age)")
                    AttributeItem(label: "能力", value: "30")
                    AttributeItem(label: "道德", value: "100")
                    AttributeItem(label: "武力", value: "20")
                }
                HStack(spacing: 20) {
                    AttributeItem(label: "智慧", value: "70")
                    AttributeItem(label: "魅力", value: "70")
                    AttributeItem(label: "民心", value: "高")
                    AttributeItem(label: "国库", value: "富裕")
                }
            }

            Divider()

            HStack {
                Text("王朝")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Spacer()
                Text(emperor.dynastyStatus.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(emperor.dynastyStatus == .unstable ? .red : .primary)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// ========================================
// MARK: - 属性网格项
// ========================================
struct AttributeItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// ========================================
// MARK: - 日志行视图
// ========================================
struct LogRowView: View {
    let log: GameLog

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(log.season.rawValue) · 第\(log.year)年")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)

                Text(log.content)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// ========================================
// MARK: - Toast 消息视图
// ========================================
struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.7, green: 0.5, blue: 0.3),
                        Color(red: 0.8, green: 0.6, blue: 0.4)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 20)
    }
}

// ========================================
// MARK: - 预览
// ========================================
#Preview {
    MainGameView(gameManager: {
        let manager = GameManager()
        manager.startNewGame()
        manager.confirmEmperorAndStart()
        return manager
    }())
}
