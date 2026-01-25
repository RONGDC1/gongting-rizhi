//
//  EmperorConfirmView.swift
//  gongtingrizhi
//
//  Created by 朱荣 on 2026/1/10.
//

import SwiftUI

struct EmperorConfirmView: View {
    @ObservedObject var gameManager: GameManager
    @State private var showText = Array(repeating: false, count: 6)
    @State private var showButton = false

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.96, blue: 0.92)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                TextArea(showText: $showText, onAllTextShown: {
                    showButton = true // 文字全显示后，触发按钮显示
                })
                Spacer()
                ButtonArea(showButton: $showButton, action: {
                    gameManager.confirmEmperorAndStart()
                })
            }
        }
    }
    
    // 文字区域子View（逐行显示）
    struct TextArea: View {
        @Binding var showText: [Bool]
        var onAllTextShown: () -> Void
        private let textList = [
            "今日你是皇帝了，",
            "你站在权力的中央，",
            "四面都是目光，",
            "等你开口，",
            "殿里站满等答案的人，",
            "一切由你做主。"
        ]
        
        var body: some View {
            VStack(spacing: 16) {
                ForEach(0..<6) { index in
                    Text(textList[index])
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .opacity(showText[index] ? 1 : 0) // 控制文字透明度，显示时为1，隐藏时为0
                        .offset(y: showText[index] ? 0 : 5) // 控制文字初始位置，未显示时上移5px
                    // 控制文字淡入和上移动画：
                    //.easeOut(duration: 0.5) 表示动画持续时间为0.5秒，且动画以渐慢的方式结束
                    //.delay(Double(index) * 0.5) 表示每行文字延迟出现
                        .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.5), value: showText[index])
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .onAppear {
                // 逐行显示文字
                for index in 0..<6 {
                    // 延迟显示文字
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                        showText[index] = true
                    }
                }
                // 文字全部显示后，延迟x秒显示按钮
                // 这里的延迟时间x秒可根据需求调整，以控制文字全部显示到按钮出现之间的间隔
                DispatchQueue.main.asyncAfter(deadline: .now() + 6 * 0.8 + 1) {
                    onAllTextShown()
                }
            }
        }
    }
    
    // 按钮区域子View（文字显示完后再出现）
    struct ButtonArea: View {
        @Binding var showButton: Bool
        var action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text("承此天命")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 1, green: 0.99, blue: 0.9))
                    .frame(width: 223)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.64, green: 0.4, blue: 0.23))
                    .cornerRadius(223/2)
            }
            // 按钮动效：从下往上滑入+淡入
            .opacity(showButton ? 1 : 0)
            .offset(y: showButton ? 0 : 50)
            .animation(.easeOut(duration: 0.6), value: showButton)
            .padding(.bottom, 48)
        }
    }
}

#Preview {
    let manager = GameManager()
    manager.startNewGame()
    return EmperorConfirmView(gameManager: manager)
}
