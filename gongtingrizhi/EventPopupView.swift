//
//  EventPopupView.swift
//  gongtingrizhi
//
//  Created by 朱荣 on 2026/1/10.
//

import SwiftUI

// ========================================
// MARK: - 事件弹窗视图
// ========================================
/// 职责：仅负责弹窗的内容展示和按钮交互
/// 动画管理：由 MainGameView 统一控制（弹入/弹出动画）
/// 按钮反馈：本地管理轻量级的点击反馈动画
struct EventPopupView: View {
    let event: GameEvent
    @ObservedObject var gameManager: GameManager
    let onDismiss: () -> Void           // 关闭弹窗的回调
    let onChoice: (EventOption) -> Void // 选择选项的回调
    
    @State private var buttonScale: [UUID: CGFloat] = [:]
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            headerBar
            
            // 事件描述
            descriptionSection
            
            // 选项按钮列表
            optionsSection
        }
        .frame(maxWidth: 320)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - 子视图
    
    /// 标题栏（带关闭按钮）
    private var headerBar: some View {
        HStack {
            Text(event.type == .critical ? "⚠️危急事件" : event.source.rawValue)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            // 关闭按钮（危急事件不显示）
            if event.type != .critical {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 32)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(headerColor)
    }
    
    /// 事件描述文字
    private var descriptionSection: some View {
        Text(event.description)
            .font(.system(size: 16))
            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
            .lineSpacing(6)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 22)
            .padding(.vertical, 32)
    }
    
    /// 选项按钮列表
    private var optionsSection: some View {
        VStack(spacing: 12) {
            ForEach(event.options) { option in
                optionButton(for: option)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    /// 单个选项按钮
    private func optionButton(for option: EventOption) -> some View {
        Button(action: {
            handleOptionTap(option)
        }) {
            HStack {
                Spacer()
                Text(option.text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                Spacer()
            }
            .padding(.vertical, 14)
            .background(Color(red: 0.96, green: 0.96, blue: 0.98))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(red: 0.90, green: 0.90, blue: 0.90), lineWidth: 1)
            )
            .scaleEffect(buttonScale[option.id] ?? 1.0)
        }
        .buttonStyle(.plain)
        .onAppear {
            if buttonScale[option.id] == nil {
                buttonScale[option.id] = 1.0
            }
        }
    }
    
    // MARK: - 交互逻辑
    
    /// 处理选项点击
    private func handleOptionTap(_ option: EventOption) {
        // 1. 按钮点击反馈动画
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            buttonScale[option.id] = 0.95
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7).delay(0.08)) {
            buttonScale[option.id] = 1.0
        }
        
        // 2. 选择选项后调用回调处理业务逻辑，然后关闭弹窗
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            onChoice(option)  // 处理属性变化等业务逻辑
        }
    }
    
    // MARK: - 辅助计算属性
    
    /// 标题栏颜色
    private var headerColor: Color {
        if event.type == .critical {
            return Color.red
        }
        let c = event.source.color
        return Color(red: c.red, green: c.green, blue: c.blue)
    }
}

// ========================================
// MARK: - 预览
// ========================================
#Preview {
    ZStack {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
        
        EventPopupView(
            event: GameEvent(
                title: "宫廷事件",
                type: .palace,
                description: "宫中御养的橘猫忽然不见了,宫人低声议论,说它昨夜还在御书房附近出没。今日一早,几位内侍在殿外候着,请示是否要继续寻找?",
                options: [
                    EventOption(text: "它自己会回来的", toastText: "皇帝命人备下鱼干,御猫当夜悄然现身", logText: nil),
                    EventOption(text: "所有人都去找", toastText: "宫中上下寻找御猫,最终还是找到了", logText: nil)
                ]
            ),
            gameManager: GameManager(),
            onDismiss: { print("关闭") },
            onChoice: { option in print("选择：\(option.text)") }
        )
    }
}
