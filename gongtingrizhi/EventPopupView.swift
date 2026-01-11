//
//  EventPopupView.swift
//  gongtingrizhi
//
//  Created by 朱荣 on 2026/1/10.
//

import SwiftUI

struct EventPopupView: View {
    let event: GameEvent
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    // 点击背景不关闭弹窗
                }
            
            // 弹窗内容
            VStack(spacing: 0) {
                // 关闭按钮（右上角）
                HStack {
                    Spacer()
                    Button(action: {
                        // 事件弹窗不提供关闭按钮，必须做出选择
                        // 但如果需要，可以在这里添加关闭逻辑
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 30, height: 3)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .opacity(0)  // 暂时隐藏关闭按钮
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
                
                // 事件标题
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
                    .padding(.top, 8)
                
                // 弹窗主体
                VStack(alignment: .leading, spacing: 12) {
                    // 事件描述
                    ScrollView {
                        Text(event.description)
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                            .lineSpacing(8)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxHeight: 150)
                    
                    // 选项按钮
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
                }
                .padding(24)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: 340)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 24)
        }
        .zIndex(1000)
    }
}

#Preview {
    EventPopupView(
        event: GameEvent(
            title: "⛲️宫廷",
            type: .palace,
            description: "宫中御养的橘猫忽然不见了，宫人低声议论，说它昨夜还在御书房附近出没。今日一早，几位内侍在殿外候着，请示是否要继续寻找？",
            options: [
                EventOption(text: "它自己会回来的", toastText: "皇帝命人备下鱼干，御猫当夜悄然现身", logText: nil),
                EventOption(text: "所有人都去找", toastText: "宫中上下寻找御猫，最终还是找到了", logText: nil)
            ]
        ),
        gameManager: GameManager()
    )
}
