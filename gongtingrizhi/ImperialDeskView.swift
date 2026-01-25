//
//  ImperialDeskView.swift
//  gongtingrizhi
//
//  Created by 朱荣 on 2026/1/10.
//

import SwiftUI

// MARK: - 御桌视图（主界面）
struct ImperialDeskView: View {
    @ObservedObject var gameManager: GameManager
    @State private var showPopup = false
    @State private var selectedEventIndex: Int? = nil
    @State private var expandedEventId: UUID? = nil  // 当前展开的事件ID
    @Binding var isShowingEventDetail: Bool  // 是否显示事件详情（用于隐藏底部导航栏）
    
    var body: some View {
        ZStack {
            // 背景色
            Color(red: 0.95, green: 0.92, blue: 0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ========================================
                // MARK: - 顶部状态栏（年月 + 结束本月按钮）
                // ========================================
                topStatusHeader
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                
                // ========================================
                // MARK: - 主内容区（可滚动）
                // ========================================
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // 皇帝信息卡片
                        if let emperor = gameManager.emperor {
                            emperorInfoCard(emperor: emperor)
                        }
                        
                        // 本月事件列表
                        monthlyEventsList
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 80)  // 为底部Tab留出空间
                }
            }
            
            // ========================================
            // MARK: - 事件详情弹窗（用于危急事件和系统事件）
            // ========================================
            if let event = gameManager.currentEvent, (event.type == .critical || event.isSystemEvent) {
                eventDetailPopup(event: event)
            }
            
            // Toast 提示
            if let toast = gameManager.toastMessage {
                toastView(toast: toast)
            }
        }
    }
    
    // MARK: - 顶部状态栏
    
    private var topStatusHeader: some View {
        HStack {
            // 年月显示（如：景和元年·正月(1/12)）
            Text(gameManager.getMonthDisplayText())
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(red: 0.55, green: 0.50, blue: 0.45))
            
            Spacer()
            
            // 结束本月按钮
            Button(action: {
                if gameManager.toastMessage == nil {
                    gameManager.endCurrentMonth()
                }
            }) {
                Text("结束本月")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.55, green: 0.50, blue: 0.45))
                    .opacity(gameManager.toastMessage == nil ? 1.0 : 0.5)
            }
            .disabled(gameManager.toastMessage != nil)
        }
        .padding(.horizontal, 30)
    }
    
    // MARK: - 皇帝信息卡片
    
    private func emperorInfoCard(emperor: Emperor) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // 姓名和年龄（特质标签放在年龄右侧，一行显示完整）
            HStack(spacing: 8) {
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
                
                // 皇帝特质标签（放在年龄右侧，去掉「」符号，一行显示完整）
                if !emperor.traits.isEmpty {
                    ForEach(emperor.traits, id: \.self) { trait in
                        Text(trait.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 0.55, green: 0.45, blue: 0.35))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(red: 0.96, green: 0.95, blue: 0.93))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
            }
            
            // 六维属性（体力替换心情位置）
            let attrs = emperor.attributes
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    AttributeBar(label: "体力", value: attrs.stamina / 100.0, color: Color(red: 0.85, green: 0.45, blue: 0.35))
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
    
    // MARK: - 本月事件列表
    
    private var monthlyEventsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 如果展开事件详情，显示详情视图；否则显示事件列表
            if let expandedId = expandedEventId, let expandedEvent = gameManager.getMonthlyEvents().first(where: { $0.id == expandedId }) {
                // 整个列表区域变成事件详情视图
                EventDetailFullView(
                    event: expandedEvent,
                    eventId: expandedId,  // 传递事件ID用于检测事件变化
                    gameManager: gameManager,
                    onDismiss: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            expandedEventId = nil
                            gameManager.currentEvent = nil
                            isShowingEventDetail = false
                        }
                    },
                    onNextEvent: {
                        handleNextEventInDetail()
                    }
                )
            } else {
                // 事件列表区域（固定位置，参考设计稿）
                VStack(alignment: .leading, spacing: 0) {
                    // 标题："本月事件"（居中显示在分隔条内）
                    Text("本月事件")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.50, green: 0.40, blue: 0.30))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.96, green: 0.94, blue: 0.90))  // 略深米色分隔条
                    
                    // 事件卡片列表（固定位置，垂直排列）
                    let monthlyEvents = gameManager.getMonthlyEvents()
                    if monthlyEvents.isEmpty {
                        // 空状态：显示空白区域
                        Spacer()
                            .frame(height: 200)  // 固定高度，保持列表区域大小
                    } else {
                        // 事件卡片列表（垂直排列，固定间距）
                        VStack(spacing: 12) {  // 卡片之间的固定垂直间距
                            ForEach(monthlyEvents) { event in
                                EventCard(
                                    event: event,
                                    gameManager: gameManager,
                                    isProcessed: event.isProcessed,
                                    onTap: {
                                        // 已处理的事件不可点击
                                        guard !event.isProcessed else { return }
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            expandedEventId = event.id
                                            gameManager.selectEvent(event)
                                            isShowingEventDetail = true
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 12)  // 左右边距
                        .padding(.vertical, 16)  // 上下内边距
                    }
                }
                .background(Color.white.opacity(0.75))  // 列表区域背景
                .cornerRadius(12)
                .frame(minHeight: 300, maxHeight: 500)  // 固定列表区域大小（参考设计稿）
            }
        }
    }
    
    /// 处理详情视图中的"下一件"按钮
    private func handleNextEventInDetail() {
        let monthlyEvents = gameManager.getMonthlyEvents()
        guard let currentId = expandedEventId,
              let currentIndex = monthlyEvents.firstIndex(where: { $0.id == currentId }) else {
            // 没有更多事件，返回列表
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                expandedEventId = nil
                gameManager.currentEvent = nil
                isShowingEventDetail = false
            }
            return
        }
        
        let nextIndex = currentIndex + 1
        if nextIndex < monthlyEvents.count {
            // 显示下一个未处理的事件
            let nextEvent = monthlyEvents[nextIndex]
            // 如果下一个事件已处理，跳过它
            if nextEvent.isProcessed {
                // 查找下一个未处理的事件
                if let nextUnprocessedIndex = monthlyEvents[nextIndex...].firstIndex(where: { !$0.isProcessed }) {
                    let nextUnprocessedEvent = monthlyEvents[nextUnprocessedIndex]
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        expandedEventId = nextUnprocessedEvent.id
                        gameManager.selectEvent(nextUnprocessedEvent)
                    }
                } else {
                    // 没有更多未处理的事件，返回列表
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        expandedEventId = nil
                        gameManager.currentEvent = nil
                        isShowingEventDetail = false
                    }
                }
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    expandedEventId = nextEvent.id
                    gameManager.selectEvent(nextEvent)
                }
            }
        } else {
            // 没有更多事件，返回列表
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                expandedEventId = nil
                gameManager.currentEvent = nil
                isShowingEventDetail = false
            }
        }
    }
    
    // MARK: - 事件详情弹窗
    
    private func eventDetailPopup(event: GameEvent) -> some View {
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
    
    // MARK: - Toast视图
    
    private func toastView(toast: ToastMessage) -> some View {
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
        // 处理事件选择后关闭弹窗
        gameManager.handleEventChoice(option: option)
        dismissPopup()
    }
}

// MARK: - 事件卡片组件（参考设计稿1:1还原）

struct EventCard: View {
    let event: GameEvent
    @ObservedObject var gameManager: GameManager
    let isProcessed: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 8) {
                // 左侧：类型标签（【类别】格式）
                Text("[\(event.source.categoryName)]")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(red: 0.64, green: 0.4, blue: 0.23))
                
                // 中间：事件描述（一行展示，超出用...截断）
                Text(getEventSummary())
                    .font(.system(size: 14))
                    .foregroundColor(isProcessed ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.2, green: 0.2, blue: 0.2))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.98, green: 0.96, blue: 0.94))  // 略浅于主背景色的卡片背景
            .cornerRadius(8)  // 圆角矩形
        }
        .buttonStyle(.plain)
        .disabled(isProcessed)  // 已处理的事件不可点击
    }
    
    private func getEventSummary() -> String {
        // 从描述中提取内容，去掉所有【来源】标签（如【户部】、【内廷】等）
        var summary = event.description
        
        // 去掉描述中可能存在的【来源】标签
        summary = summary.replacingOccurrences(of: "\\[.*?\\]", with: "", options: .regularExpression)
        
        // 去掉换行符和多余空格
        summary = summary.replacingOccurrences(of: "\n", with: " ")
        summary = summary.trimmingCharacters(in: .whitespaces)
        
        // 如果为空，使用标题
        if summary.isEmpty {
            summary = event.title
        }
        
        return summary
    }
}

// MARK: - 事件详情完整视图（整个列表区域变成详情视图）

struct EventDetailFullView: View {
    let event: GameEvent
    let eventId: UUID  // 事件ID，用于检测事件变化
    @ObservedObject var gameManager: GameManager
    let onDismiss: () -> Void
    let onNextEvent: () -> Void
    @State private var selectedOption: EventOption? = nil
    
    // 从gameManager获取最新的事件数据
    private var currentEvent: GameEvent? {
        gameManager.getMonthlyEvents().first(where: { $0.id == eventId })
    }
    
    var body: some View {
        // 使用当前事件数据（如果存在），否则使用传入的event
        let displayEvent = currentEvent ?? event
        
        VStack(spacing: 0) {
            // 事件详情卡片（占据整个列表区域，高度根据选项数量自动调整）
            VStack(alignment: .leading, spacing: 16) {
                // 事件详情标题
                Text("事件详情")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.45, green: 0.35, blue: 0.25))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 16)
                
                // 事件标题（【类型】请奏）
                Text("[\(displayEvent.source.categoryName)]\(displayEvent.title)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                    .padding(.horizontal, 16)
                
                // 事件描述（去掉描述中的【来源】标签）
                ScrollView {
                    Text(cleanEventDescription(event: displayEvent))
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                }
                .frame(maxHeight: displayEvent.options.count >= 3 ? 200 : 300)  // 三个选项时缩短高度
                
                // 反馈文案（如果已选择选项）- 显示在卡片内，参考设计稿样式
                if let option = selectedOption {
                    HStack {
                        Text(option.toastText)
                            .font(.system(size: 13))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                        Spacer()
                    }
                    .background(Color(red: 0.95, green: 0.98, blue: 0.95))  // 浅绿色背景，参考设计稿
                    .cornerRadius(6)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                
                Spacer()  // 填充空间，将按钮推到底部
            }
            .frame(minHeight: displayEvent.options.count >= 3 ? 300 : 400)  // 三个选项时缩短最小高度
            .background(Color(red: 0.98, green: 0.95, blue: 0.90))  // 浅橙色背景，参考设计稿
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.9, green: 0.75, blue: 0.6), lineWidth: 1)  // 深橙色边框
            )
            
            // 操作选项放在底部（在卡片外部）
            if selectedOption == nil {
                // 选项按钮列表（未选择时显示）
                VStack(spacing: 12) {
                    ForEach(displayEvent.options) { option in
                        Button(action: {
                            selectedOption = option
                            gameManager.handleEventChoice(option: option)
                        }) {
                            Text(option.text)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(option.text.contains("采纳") ? Color.green : Color.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            } else {
                // 操作按钮：休息片刻 / 下一件（已选择后显示，位置调换）
                HStack(spacing: 12) {
                    Button(action: onDismiss) {
                        Text("休息片刻")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        // 点击下一件时，重置选择状态
                        selectedOption = nil
                        onNextEvent()
                    }) {
                        Text("下一件")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .onChange(of: eventId) { oldValue, newValue in
            // 当事件ID变化时（点击了下一件），重置选择状态
            selectedOption = nil
        }
    }
    
    private func cleanEventDescription(event: GameEvent) -> String {
        // 去掉描述中可能存在的【来源】标签（如【户部】、【内廷】等）
        var description = event.description
        description = description.replacingOccurrences(of: "\\[.*?\\]", with: "", options: .regularExpression)
        return description.trimmingCharacters(in: .whitespaces)
    }
}

#Preview {
    ImperialDeskView(gameManager: {
        let manager = GameManager()
        manager.startNewGame()
        manager.confirmEmperorAndStart()
        return manager
    }(), isShowingEventDetail: .constant(false))
}
