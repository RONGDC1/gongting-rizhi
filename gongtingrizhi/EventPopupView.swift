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
            // 事件标题标签
            Text(event.type.rawValue)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    event.type == .critical
                    ? Color.red
                    : Color(red: 0.7, green: 0.5, blue: 0.3)
                )
                .cornerRadius(20)
                .padding(.top, 28)  // ✅ 标题到顶部：28pt
            
            // 事件描述文字（不用 ScrollView，自适应高度）
            Text(event.description)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
                .padding(.top, 28)  // ✅ 标题到内容：28pt
            
            // 选项按钮列表
            VStack(spacing: 12) {
                ForEach(event.options) { option in
                    Button(action: {
                        gameManager.handleEventChoice(option: option)
                    }) {
                        HStack {
                            Spacer()
                            Text(option.text)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .background(
                            event.type == .critical
                            ? LinearGradient(
                                gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.7, green: 0.5, blue: 0.3), Color(red: 0.8, green: 0.6, blue: 0.4)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)      // ✅ 内容到选项：32pt
            .padding(.bottom, 22)   // 底部边距：22pt
        }
        .frame(maxWidth: 320)  // 弹窗最大宽度
        .background(Color.white)
        .cornerRadius(20)
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
