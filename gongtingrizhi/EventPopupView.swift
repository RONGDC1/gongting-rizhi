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
/// 说明：显示游戏事件的弹窗内容（不包含蒙层）
/// ⚠️ 重要：蒙层由 MainGameView 统一管理，这里只负责弹窗内容
struct EventPopupView: View {
    let event: GameEvent
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        // ⚠️ 所有弹窗样式在这里统一管理，MainGameView 只负责蒙层
        VStack(spacing: 0) {
            // 标题栏（蓝色横幅，左侧标题，右侧关闭按钮）
            HStack {
                Text(event.type == .critical ? "危急事件" : event.source.rawValue)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // 关闭按钮（X）- 危急事件不显示
                if event.type != .critical {
                    Button(action: {
                        gameManager.closeEventPopup()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 32)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                event.type == .critical
                ? Color.red
                : Color(red: event.source.color.red, green: event.source.color.green, blue: event.source.color.blue)
            )
            
            // 事件描述文字
            Text(event.description)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 22)
                .padding(.vertical, 32)
            
            // 选项按钮列表（灰色背景按钮）
            VStack(spacing: 12) {
                ForEach(event.options) { option in
                    Button(action: {
                        gameManager.handleEventChoice(option: option)
                    }) {
                        HStack {
                            Spacer()
                            Text(option.text)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .background(Color(red: 0.96, green: 0.96, blue: 0.98))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(red: 0.90, green: 0.90, blue: 0.90), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: 320)  // 弹窗最大宽度
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

// ========================================
// MARK: - 预览
// ========================================
#Preview {
    ZStack {
        // 预览时手动添加蒙层背景
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
            gameManager: GameManager()
        )
    }
}
