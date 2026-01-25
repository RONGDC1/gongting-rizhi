//
//  MainGameView.swift
//  gongtingrizhi
//
//  Created by 朱荣 on 2026/1/10.
//

import SwiftUI

struct MainGameView: View {
    @ObservedObject var gameManager: GameManager
    @State private var showPopup = false
    
    var body: some View {
        ZStack {
            // 背景色
            Color(red: 0.95, green: 0.92, blue: 0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部状态栏
                topStatusHeader
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if let emperor = gameManager.emperor {
                            emperorInfoCard(emperor: emperor)
                        }
                        // 世界侧写已移除
                        tasksGrid
                    }
                    .padding(.horizontal, 16)
                }
                
                Spacer()
                
                // 底部按钮
                bottomTimeButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            
            // 事件弹窗（统一管理所有动画）
            if let event = gameManager.currentEvent {
                ZStack {
                    // 蒙层
                    Color.black.opacity(showPopup ? 0.4 : 0)
                        .ignoresSafeArea()
                        .onTapGesture {
                            if event.type != .critical {
                                dismissPopup()
                            }
                        }
                    
                    // 弹窗内容
                    EventPopupView(
                        event: event,
                        gameManager: gameManager,
                        onDismiss: dismissPopup,
                        onChoice: handleEventChoice
                    )
                    .scaleEffect(showPopup ? 1.0 : 0.8)
                    .opacity(showPopup ? 1.0 : 0.0)
                }
                .zIndex(1000)
                .task(id: event.id) {
                    showPopup = false
                    try? await Task.sleep(nanoseconds: 1_000_000)
                    withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7)) {
                        showPopup = true
                    }
                }
            }
            
            // Toast 提示
            if let toast = gameManager.toastMessage {
                VStack {
                    Spacer()
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
                        .padding(.horizontal, 20)
                    Spacer()
                }
                .allowsHitTesting(false)
            }
        }
    }
    
    // MARK: - 弹窗动画控制
    
    private func dismissPopup() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            showPopup = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            gameManager.currentEvent = nil
        }
    }
    
    private func handleEventChoice(_ option: EventOption) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            showPopup = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            gameManager.handleEventChoice(option: option)
            gameManager.currentEvent = nil
        }
    }
    
    // MARK: - 顶部状态栏
    
    private var topStatusHeader: some View {
        HStack {
            Text("\(gameManager.getReignTitleDisplay())·\(gameManager.getSeasonDescription())")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(red: 0.55, green: 0.50, blue: 0.45))
            
            Spacer()
            
            Button(action: {
                if gameManager.toastMessage == nil {
                    gameManager.abdicate()
                }
            }) {
                Text("结束")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.55, green: 0.50, blue: 0.45))
                    .opacity(gameManager.toastMessage == nil ? 1.0 : 0.5)
            }
            .disabled(gameManager.toastMessage != nil)
        }
        .padding(.horizontal, 30)
    }
    
    // MARK: - 底部按钮
    
    private var bottomTimeButton: some View {
        Button(action: {
            if gameManager.toastMessage == nil {
                // 使用新的月份系统：结束本月
                gameManager.endCurrentMonth()
            }
        }) {
            Text("下一年")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 223)
                .padding(.vertical, 16)
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
                .cornerRadius(223/2)
                .opacity(gameManager.toastMessage == nil ? 1.0 : 0.5)
        }
        .disabled(gameManager.toastMessage != nil)
    }
    
    // MARK: - 人物信息卡片
    
    private func emperorInfoCard(emperor: Emperor) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // 姓名和年龄
            HStack(spacing: 8) {
                Text("👑")
                    .font(.system(size: 20))
                
                Text(emperor.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.45, green: 0.35, blue: 0.25))
                
                Text("|")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(Color(red: 0.70, green: 0.65, blue: 0.60))
                    .padding(.horizontal, 4)
                
                Text("\(emperor.age)岁")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.60, green: 0.55, blue: 0.50))
                
                Spacer()
                
                Text(gameManager.getTimeStatusText())
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(red: 0.60, green: 0.55, blue: 0.50))
            }
            
            // 四类属性标签
            HStack(spacing: 4) {
                StatusBadge(
                    icon: "🏛️",
                    title: emperor.nationalStatus.rawValue,
                    bgColor: Color(red: 0.96, green: 0.95, blue: 0.93),
                    isHorizontal: true
                )
                
                StatusBadge(
                    icon: "💰",
                    title: emperor.resourceStatus.rawValue,
                    bgColor: Color(red: 0.96, green: 0.95, blue: 0.93),
                    isHorizontal: true
                )
                
                StatusBadge(
                    icon: "💘",
                    title: emperor.courtStatus.rawValue,
                    bgColor: Color(red: 0.96, green: 0.95, blue: 0.93),
                    isHorizontal: false
                )
                
                StatusBadge(
                    icon: "👦🏻👧🏻",
                    title: emperor.heirStatus.rawValue,
                    bgColor: Color(red: 0.96, green: 0.95, blue: 0.93),
                    isHorizontal: false
                )
            }
            
            // 六维属性
            let attrs = emperor.attributes
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    AttributeBar(label: "心情", value: attrs.mood, color: Color(red: 0.55, green: 0.65, blue: 0.35))
                    AttributeBar(label: "才智", value: attrs.intelligence, color: Color(red: 0.35, green: 0.55, blue: 0.75))
                    AttributeBar(label: "魅力", value: attrs.charm, color: Color(red: 0.85, green: 0.45, blue: 0.55))
                }
                
                HStack(spacing: 10) {
                    AttributeBar(label: "声望", value: attrs.reputation, color: Color(red: 0.55, green: 0.40, blue: 0.60))
                    AttributeBar(label: "民心", value: attrs.popularity, color: Color(red: 0.75, green: 0.45, blue: 0.35))
                    AttributeBar(label: "道德", value: attrs.morality, color: Color(red: 0.40, green: 0.65, blue: 0.55))
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.75))
        .cornerRadius(12)
    }
    
    // MARK: - 世界侧写模块（已移除，保留空视图用于兼容）
    
    private var worldNarrativeCard: some View {
        EmptyView()  // 世界侧写功能已移除
    }
    
    // MARK: - 事务卡片区
    
    private var tasksGrid: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                TaskCard(
                    title: "前朝政务",
                    count: gameManager.getEventPoolCount(for: .frontCourt),
                    accentColor: Color(red: 0.64, green: 0.4, blue: 0.23),
                    gameManager: gameManager
                )
                
                TaskCard(
                    title: "宫廷人事",
                    count: gameManager.getEventPoolCount(for: .courtPersonnel),
                    accentColor: Color(red: 0.64, green: 0.4, blue: 0.23),
                    gameManager: gameManager
                )
            }
            
            HStack(spacing: 8) {
                TaskCard(
                    title: "后宫事务",
                    count: gameManager.getEventPoolCount(for: .harem),
                    accentColor: Color(red: 0.64, green: 0.4, blue: 0.23),
                    gameManager: gameManager
                )
                
                TaskCard(
                    title: "世情风向",
                    count: gameManager.getEventPoolCount(for: .publicOpinion),
                    accentColor: Color(red: 0.64, green: 0.4, blue: 0.23),
                    gameManager: gameManager
                )
            }
        }
    }
}

// MARK: - 状态标签

struct StatusBadge: View {
    let icon: String
    let title: String
    let bgColor: Color
    let isHorizontal: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Text(icon)
                .font(.system(size: isHorizontal ? 14 : 12))
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(red: 0.45, green: 0.35, blue: 0.25))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 36)
        .padding(.horizontal, isHorizontal ? 0 : 8)
        .background(bgColor)
        .cornerRadius(6)
    }
}

// MARK: - 属性条

struct AttributeBar: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 0.50, green: 0.45, blue: 0.40))
                
                Spacer()
                
                Text("\(Int(value * 100))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 0.50, green: 0.45, blue: 0.40))
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.5), value: value)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.2))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geometry.size.width * value, height: 6)
                        .animation(.easeInOut(duration: 0.6), value: value)
                }
            }
            .frame(height: 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(Color.white.opacity(0.2))
        .cornerRadius(6)
    }
}

// MARK: - 事务卡片

struct TaskCard: View {
    let title: String
    let count: Int
    let accentColor: Color
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(red: 0.50, green: 0.40, blue: 0.30))
            
            HStack(alignment: .bottom) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(count)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(accentColor)
                    
                    Text("/ 件")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.60, green: 0.55, blue: 0.50))
                }
                
                Spacer()
                
                Button(action: {
                    if count > 0 && gameManager.toastMessage == nil {
                        triggerEvent()
                    }
                }) {
                    Text(buttonText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isButtonEnabled ? buttonTextColor : buttonTextColor.opacity(0.4))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(buttonBackgroundColor.opacity(isButtonEnabled ? 1.0 : 0.5))
                        .cornerRadius(6)
                }
                .disabled(!isButtonEnabled)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.75))
        .cornerRadius(12)
    }
    
    // MARK: - 辅助属性
    
    private var isButtonEnabled: Bool {
        count > 0 && gameManager.toastMessage == nil
    }
    
    private var buttonText: String {
        switch title {
        case "前朝政务": return "批阅"
        case "宫廷人事": return "召见"
        case "后宫事务": return "处置"
        case "世情风向": return "了解"
        default: return "处理"
        }
    }
    
    private var buttonTextColor: Color {
        switch title {
        case "前朝政务": return Color(red: 0.2, green: 0.5, blue: 0.8)
        case "宫廷人事": return Color(red: 0.79, green: 0.59, blue: 0.15)
        case "后宫事务": return Color(red: 0.85, green: 0.35, blue: 0.55)
        case "世情风向": return Color(red: 0.35, green: 0.7, blue: 0.45)
        default: return accentColor
        }
    }
    
    private var buttonBackgroundColor: Color {
        switch title {
        case "前朝政务": return Color(red: 0.89, green: 0.92, blue: 0.94)
        case "宫廷人事": return Color(red: 0.97, green: 0.94, blue: 0.87)
        case "后宫事务": return Color(red: 0.97, green: 0.91, blue: 0.91)
        case "世情风向": return Color(red: 0.91, green: 0.95, blue: 0.9)
        default: return accentColor.opacity(0.12)
        }
    }
    
    private var eventSource: EventSource {
        switch title {
        case "前朝政务": return .frontCourt
        case "宫廷人事": return .courtPersonnel
        case "后宫事务": return .harem
        case "世情风向": return .publicOpinion
        default: return .frontCourt
        }
    }
    
    private func triggerEvent() {
        gameManager.triggerNextEventForSource(eventSource)
    }
}

// MARK: - 预览

#Preview {
    let manager = GameManager()
    manager.startNewGame()
    manager.confirmEmperorAndStart()
    return MainGameView(gameManager: manager)
}

