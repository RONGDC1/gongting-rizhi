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
            """,
            """
            宫殿里依旧金碧辉煌，而你早已学会轻松对待一切。
            当年的雄心壮志，有些实现了，有些也没什么大不了。
            年岁让你看透了名利，也让你和自己和解。
            你耸耸肩，觉得这样的人生，也不错。
            """,
            """
            多少年过去，你终于不用为臣子脸色烦恼，也不必追逐边疆风云。
            宫里的繁华早已成了往事笑谈。
            年轻时的你狂热而焦虑，现在的你轻松而自在。
            最重要的是，你学会了和自己相处。
            """
        ]
        return texts.randomElement() ?? texts[0]
    }

    
    // MARK: - 状态坍塌文案（情绪化三行版）
    private func generateCollapseText(reason: CollapseReason?, attrs: EmperorAttributes) -> String {
        guard let reason = reason else {
            return ["一切都失衡了。", "像一座倾斜的宫殿。", "你只能站在废墟上叹息。"].joined(separator: "\n")
        }
        
        let isHigh = getAttributeValue(reason: reason, attrs: attrs) > 0.9
        
        func randomLine(_ lines: [String]) -> String {
            return lines.randomElement() ?? lines[0]
        }
        
        switch reason {
        case .mood:
            if isHigh {
                return randomLine([
                    "你笑得太厉害了。\n宫人退得远远的。\n连自己也笑不出来了。",
                    "笑声填满大殿。\n没人敢靠近你。\n孤独悄悄爬上心头。",
                    "你笑到头晕。\n宫人躲在角落。\n自己却觉得空落落。"
                ])
            } else {
                return randomLine([
                    "你不再笑。\n连风也在远离你。\n宫里只剩沉默。",
                    "你的眉眼紧绷。\n宫殿回声空荡。\n连自己也害怕凝视。",
                    "沉默弥漫。\n没人找你。\n你开始怀疑存在感。"
                ])
            }
            
        case .intelligence:
            if isHigh {
                return randomLine([
                    "你看透一切。\n身边却空无一人。\n聪明让你孤单成王。",
                    "洞察万物，却无人陪伴。\n宫里只有回声。\n你的智慧成了牢笼。",
                    "你读懂所有心思。\n无人再说真话。\n聪明让你寒心。"
                ])
            } else {
                return randomLine([
                    "朝堂上的事，你不再问。\n权力悄悄流逝。\n你也不再追问。",
                    "事务复杂如迷雾。\n你困惑退场。\n没人理会你的迟疑。",
                    "你渐渐懈怠。\n朝臣不再依赖。\n空虚在胸口蔓延。"
                ])
            }
            
        case .charm:
            if isHigh {
                return randomLine([
                    "众人仰慕你。\n他们的目光像刀。\n你开始怀念被忽略的日子。",
                    "魅力让你高不可攀。\n人们退避三舍。\n孤独如影随形。",
                    "所有人都望向你。\n却没有人真正靠近。\n笑声掩盖真实。"
                ])
            } else {
                return randomLine([
                    "镜子里的你陌生。\n宫里没人理会。\n连回声都冷淡。",
                    "你不再整理仪容。\n宫殿里空旷回响。\n孤独悄悄填满每个角落。",
                    "魅力消散。\n人们无视你。\n你只能与自己对话。"
                ])
            }
            
        case .reputation:
            if isHigh {
                return randomLine([
                    "天下人都在谈你。\n你听着却像陌生人。\n荣耀让你心虚。",
                    "声名极盛。\n每句赞美都让你心颤。\n你开始怀疑真实。",
                    "人们高声传颂你的名。\n你却听得疲惫。\n名望也让你孤单。"
                ])
            } else {
                return randomLine([
                    "街巷无人提你。\n宫殿空空如也。\n仿佛你从未存在。",
                    "无人关心你的名字。\n沉默像阴影。\n你感到心空。",
                    "声望崩塌。\n回忆也苍白。\n你像幽灵般漂浮。"
                ])
            }
            
        case .popularity:
            if isHigh {
                return randomLine([
                    "百姓奉你为神。\n神明也会疲惫。\n你渴望真正被看见。",
                    "人们高声呼喊你的名。\n你却感到孤独。\n光环无法温暖心。",
                    "民众簇拥。\n你被抬高。\n孤单从未离开。"
                ])
            } else {
                return randomLine([
                    "城门外人群沉默。\n没有掌声也没有哭泣。\n心里有一丝空洞。",
                    "人们的目光都移开。\n你独自站着。\n空气里弥漫冷漠。",
                    "无人关注。\n宫里回声稀薄。\n孤独如影随形。"
                ])
            }
            
        case .morality:
            if isHigh {
                return randomLine([
                    "你从未做错事。\n完美也让人疲惫。\n一切都让你孤单。",
                    "正直如山。\n却无法得到温暖。\n孤独如影随行。",
                    "你的原则无人挑战。\n可心灵依旧空旷。\n完美也是牢笼。"
                ])
            } else {
                return randomLine([
                    "人们欲言又止。\n你的行为无人承认。\n心中留下裂痕。",
                    "道德崩塌。\n没人会原谅。\n孤独如寒风。",
                    "你越走越偏。\n人心疏远。\n空虚填满胸口。"
                ])
            }
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
                "血染宫墙，冷得让人麻木。\n月色很美，连风都停了。\n天亮，再也看不到。",
                "宫人尖叫，却无法阻止。\n瞬间，权力化作空白。\n连呼吸都变得沉重。",
                "那天，你从宝座上倒下。\n火烛摇曳，影子拉长。\n再也没人听到你的声音。",
                "刺客出现得太快。\n一切计划都化为尘埃。\n只剩心跳的余韵。"
            ])
            
        case .rebellion:
            return randomLine([
                "城破的那天，火光映红宫殿。\n你连衣冠都没整理。\n王朝倾覆，如一阵风。",
                "兵临城下，你依旧坐在书桌前。\n手里的笔停在半页。\n外面的喧嚣与你无关。",
                "宫门轰然打开，尖叫四起。\n你本能想逃，却发现无路可走。\n权力在瞬间消散。",
                "火光与烟尘笼罩宫殿。\n你发现自己已无力挽回。\n只剩无声的结局。"
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
                宫殿依旧庄严，可你不再属于它。
                昔日的权力像烟雾般散去。
                你走到窗前，看着外面的天空。
                终于，心中有了一丝轻松。
                """,
                """
                你低声说，够了。
                朝堂安静，仿佛从未喧嚣。
                臣子们面面相觑，没人敢发出声音。
                你笑了笑，笑得很淡。
                离开，不是失败，而是一种选择。
                """
            ]
            return randomLine(texts)
            
        } else if attrs.popularity < 0.3 {
            let texts = [
                """
                你走了。
                宫殿沉默，街巷冷清。
                没有人叫住你，也没有人送行。
                只是风吹过空旷的院落。
                孤独像影子，静静跟随你。
                """,
                """
                退位诏书悄然下达。
                朝堂没有掌声，也没有叹息。
                你低头，缓缓离开。
                城门之外，阳光洒落，照在无人注意的地面上。
                一切如你所料，静默无声。
                """
            ]
            return randomLine(texts)
            
        } else {
            let texts = [
                """
                你终于决定退位。
                位子空了，总有人会坐上去。
                风还是吹，日子照常流过。
                你微微耸肩，笑了笑。
                自由，原来是一种奇怪的轻松感。
                """,
                """
                “是时候了。”你低声说。
                宫墙之外仍是天空，云还是云。
                历史会记得，也会遗忘。
                你慢慢走出宫殿，风轻轻吹过肩膀。
                余光中，仿佛有自己未来的影子。
                """
            ]
            return randomLine(texts)
        }
    }

    
    // MARK: - 获取属性值
    private func getAttributeValue(reason: CollapseReason, attrs: EmperorAttributes) -> Double {
        switch reason {
        case .mood: return attrs.mood
        case .intelligence: return attrs.intelligence
        case .charm: return attrs.charm
        case .reputation: return attrs.reputation
        case .popularity: return attrs.popularity
        case .morality: return attrs.morality
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
