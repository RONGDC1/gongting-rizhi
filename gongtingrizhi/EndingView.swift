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
            
            // 结局页模式
            EndingContentView(gameManager: gameManager)
        }
    }
}

// MARK: - 结局内容视图
struct EndingContentView: View {
    @ObservedObject var gameManager: GameManager
    
    // MARK: - 生成结局文案
    private func generateEndingSummary() -> String {
        guard let emperor = gameManager.emperor,
              let endingType = gameManager.endingType else {
            return "在你的时代，没有发生足以改变世界的事。人们记得战争、饥荒与盛世，却很少记得，平稳度过的岁月。或许，被忽略，本身也是一种结果。"
        }
        
        let attrs = emperor.attributes
        
        switch endingType {
        case .naturalEnd:
            return generateNaturalEndText(attrs: attrs)
            
        case .collapse:
            return generateCollapseText(reason: gameManager.collapseReason, attrs: attrs)
            
        case .sudden:
            return generateSuddenText(reason: gameManager.suddenReason)
            
        case .abdication:
            return generateAbdicationText(attrs: attrs)
        }
    }
    
    // MARK: - 自然终点文案（皇帝身份 + 幽默 + 自我感悟）
    private func generateNaturalEndText(attrs: EmperorAttributes) -> String {
        let texts = [
            """
            年轻时，你以为掌控天下就是掌控一切。
            后来才明白，真正难掌控的，是自己心里的急躁和不安。
            如今，你坐在曾经令你紧张的宝座上，微微一笑。
            原来，权势也不过是提醒自己：喝水、按时休息罢了。
            """
        ]
        return texts.randomElement() ?? texts[0]
    }

    
    // MARK: - 状态坍塌文案（单条展示版：每种条件只对应一条）
    private func generateCollapseText(reason: CollapseReason?, attrs: EmperorAttributes) -> String {

        // 没有明确原因时的兜底文案
        guard let reason = reason else {
            return "一切都失衡了。\n像一座倾斜的宫殿。\n你只能站在废墟上叹息。"
        }

        switch reason {

        // —— 心情过低 ——
        case .mood:
            return "你不再笑。\n宫里的人也跟着收声。\n日子像被折了一角。"
            
        // —— 才智过低 ——
        case .intelligence:
            return "你听得很认真，\n却一句也没听懂。\n权力悄悄流逝，\n无人再向你请示。"

        // —— 魅力过低 ——
        case .charm:
            return "镜中人变得陌生。\n宫里再无人注目。\n连脚步声都显得多余。"

        // —— 声望过低 ——
        case .reputation:
            return "街巷不再提你名字，\n旧功也被风吹薄，\n仿佛你从未存在。"
            
        // —— 民心过低 ——
        case .popularity:
            return "告示被撕成碎纸，\n市井里骂你的话换了新花样，\n护卫比从前多了一倍，\n终于听见王朝的裂声。"
            
        // —— 道德过低 ——
        case .morality:
            return "人心渐远。\n无人再为你辩护。\n你走进自己造的寒冬。"
        }
    }


    
    // MARK: - 突发终结文案（生动三行版）
    private func generateSuddenText(reason: SuddenReason?) -> String {
        guard let reason = reason else {
            return ["一切结束得很快。", "快到来不及反应。", "你只能站在废墟上叹息。"].joined(separator: "\n")
        }
        
        func randomLine(_ lines: [String]) -> String {
            return lines.randomElement() ?? lines[0]
        }
        
        switch reason {
        case .assassination:
            return randomLine([
                "宫人尖叫，却无法阻止。\n瞬间，权力化作空白。\n连呼吸都变得沉重。",
                "那天，你从宝座上倒下。\n火烛摇曳，影子拉长。\n再也没人听到你的声音。",
            ])
            
        case .rebellion:
            return randomLine([
                "城破的那天，火光映红宫殿。\n宫门轰然打开，尖叫四起。\n你连衣冠都没整理，王朝就此倾覆。",
                "火光和烟尘吞噬宫墙，你被迫退入书房。\n手中未完的奏折被风吹得卷曲破碎。\n天亮后再也不见你的身影。",
            ])
        }
    }

    // MARK: - 退位文案
    private func generateAbdicationText(attrs: EmperorAttributes) -> String {
        
        func randomLine(_ lines: [String]) -> String {
            return lines.randomElement() ?? lines[0]
        }
        
        if attrs.morality > 0.7 {
            let texts = [
                """
                脱下龙袍的那天，你深吸一口气。
                宫殿依旧庄严，你已不属于这里。
                昔日的权力像烟雾般散去。
                终于，心中有了一丝轻松。
                """
            ]
            return randomLine(texts)
            
        } else if attrs.popularity < 0.3 {
            let texts = [
                """
                退位诏书悄然下达。
                朝堂没有掌声，也没有叹息。
                你低头，缓缓离开。
                城门之外，阳光洒落，照在无人注意的地面上。
                """
            ]
            return randomLine(texts)
            
        } else {
            let texts = [
                """
                你终于退位了。
                位子空了，总有人会坐上去。
                风还是吹，日子照常流过。
                你微微耸肩，笑了笑。
                """
            ]
            return randomLine(texts)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 30) {
                    // 结局类型标识（简化显示）
                    if let endingType = gameManager.endingType {
                        VStack(spacing: 20) {
                            Text(getEndingEmoji(endingType))
                                .font(.system(size: 58))
                            
                            Text(endingType.rawValue)
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color(red: 0.50, green: 0.40, blue: 0.30))
                        }
                        .padding(.top, 90)
                        .padding(.bottom, 20)
                    }
                    
                    // 结局文案
                    Text(generateEndingSummary())
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))// 固定深灰色
                        .multilineTextAlignment(.center)
                        .lineSpacing(12)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    
                    // 记忆片段（去重）
                    if !uniqueMemoryFragments.isEmpty {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("记忆片段")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0.50, green: 0.40, blue: 0.30))
                                .padding(.horizontal, 20)
                            
                            ForEach(uniqueMemoryFragments) { fragment in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(fragment.speaker)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    Text(fragment.content)
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))// 固定深灰色
                                        .lineSpacing(6)
                                }
                                .padding(20)
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal, 16)
            }
            
            Spacer()
            
            // 重新开始按钮
            Button(action: {
                gameManager.restart()
            }) {
                Text("重新开始")
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
                    .cornerRadius(99)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 48)
        }
    }
    
    // MARK: - 获取结局emoji
    private func getEndingEmoji(_ type: EndingType) -> String {
        switch type {
        case .naturalEnd: return "🕰️"
        case .collapse: return "⚖️"
        case .sudden: return "⚔️"
        case .abdication: return "👑"
        }
    }
    
    // MARK: - 去重记忆片段
    private var uniqueMemoryFragments: [MemoryFragment] {
        var seen: Set<String> = []
        return gameManager.memoryFragments.filter { fragment in
            let key = "\(fragment.speaker)|\(fragment.content)"
            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }
    }
}

#Preview {
    let manager = GameManager()
    manager.startNewGame()
    manager.endingType = .abdication
    manager.gameState = .ended
    return EndingView(gameManager: manager)
}
