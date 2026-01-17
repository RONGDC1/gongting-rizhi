//
//  GameManager.swift
//  gongtingrizhi
//
//  Created by 朱荣 on 2026/1/10.
//

import Foundation
import SwiftUI
import Combine

class GameManager: ObservableObject {
    // -----------------------------
    // 游戏核心数据
    // -----------------------------
    @Published var emperor: Emperor?
    @Published var logs: [GameLog] = []
    @Published var currentSeason: Season = .spring
    @Published var currentRound: Int = 1  // 当前回合数
    @Published var gameState: GameState = .emperorConfirm
    @Published var currentEvent: GameEvent?
    @Published var endingType: EndingType?
    @Published var collapseReason: CollapseReason?
    @Published var suddenReason: SuddenReason?
    @Published var toastMessage: ToastMessage?
    
    // 事件池系统（每回合4个事件类型，每个随机3-5个待处理事件）
    @Published var eventPoolQueues: [EventSource: [GameEvent]] = [:]  // 每个事件类型的事件队列
    @Published var eventsProcessedThisRound: Int = 0  // 本回合已处理事件数
    
    // 记忆片段
    @Published var memoryFragments: [MemoryFragment] = []
    
    // 世界侧写
    @Published var courtNarrative: String = "新帝即位，天下静观其变。"
    @Published var palaceNarrative: String = "年号初易，新元伊始。"
    
    // 计算当前年份（每4回合为一年）
    var currentYear: Int {
        return (currentRound - 1) / 4 + 1
    }
    
    // 最大回合数（回合上限）
    let maxRounds: Int = 50
    
    // 随机生成器
    private let nameGenerator = NameGenerator()
    private let eventGenerator = EventGenerator()
    
    // MARK: - 初始化游戏
    func startNewGame() {
        // 生成随机皇帝（不包含六维属性，在进入主界面时生成）
        emperor = generateRandomEmperor()
        
        // 重置游戏状态
        currentSeason = .spring
        currentRound = 1
        logs = []
        gameState = .emperorConfirm
        currentEvent = nil
        endingType = nil
        collapseReason = nil
        suddenReason = nil
        toastMessage = nil
        eventPoolQueues = [:]
        eventsProcessedThisRound = 0
        memoryFragments = []
        courtNarrative = "新帝即位，天下静观其变。"
        palaceNarrative = "年号初易，新元伊始。"
        
        if emperor != nil {
            emperor!.yearInPower = 1
        }
    }
    
    // MARK: - 确认皇帝信息，进入游戏（生成六维属性和四类属性标签）
    func confirmEmperorAndStart() {
        guard var emperor = emperor else { return }
        
        // 生成六维属性（一次性随机生成）
        emperor.attributes = generateRandomAttributes()
        
        // 生成四类属性标签（随机展示一种）
        emperor.nationalStatus = NationalStatus.allCases.randomElement() ?? .prosperous
        emperor.resourceStatus = ResourceStatus.allCases.randomElement() ?? .balanced
        emperor.courtStatus = CourtStatus.allCases.randomElement() ?? .harmonious
        emperor.heirStatus = HeirStatus.allCases.randomElement() ?? .adequate
        
        self.emperor = emperor
        gameState = .playing
        
        // 添加新帝即位日志
        let initialLog = GameLog(
            season: currentSeason,
            year: currentYear,
            content: "新帝即位，天下静观其变。"
        )
        logs.insert(initialLog, at: 0)
        
        // 生成第一个事件池（不自动触发事件，等待用户点击事务卡片）
        generateEventPoolForRound()
        
        // 检查是否需要自动弹出紧急事件
        checkAndTriggerCriticalEvent()
    }
    
    // MARK: - 生成随机皇帝（不包含六维属性）
    private func generateRandomEmperor() -> Emperor {
        let names = nameGenerator.generateEmperorName()
        let ages = Int.random(in: 18...40)
        let statuses: [DynastyStatus] = [.prosperity, .stable, .unstable]
        let reignTitles = ["永泰", "平瑞", "元启", "建青", "光熙", "正元", "天和"]
        
        return Emperor(
            name: names,
            age: ages,
            dynastyStatus: statuses.randomElement() ?? .stable,
            yearInPower: 1,
            reignTitle: reignTitles.randomElement() ?? "元启"
        )
    }
    
    // MARK: - 生成随机六维属性
    private func generateRandomAttributes() -> EmperorAttributes {
        return EmperorAttributes(
            mood: Double.random(in: 0.3...0.8),
            intelligence: Double.random(in: 0.3...0.8),
            charm: Double.random(in: 0.3...0.8),
            reputation: Double.random(in: 0.3...0.8),
            popularity: Double.random(in: 0.3...0.8),
            morality: Double.random(in: 0.3...0.8)
        )
    }
    
    // MARK: - 为当前回合生成事件池（每回合4个事件类型，每个随机3-5个待处理事件）
    private func generateEventPoolForRound() {
        let sources: [EventSource] = [.frontCourt, .courtPersonnel, .harem, .publicOpinion]
        eventPoolQueues = [:]
        
        // 为每个事件类型生成3-5个事件
        for source in sources {
            let eventCount = Int.random(in: 3...5)
            var queue: [GameEvent] = []
            
            for _ in 0..<eventCount {
                var event: GameEvent
                if source == .publicOpinion {
                    event = eventGenerator.generatePublicOpinionEvent()
                } else {
                    event = eventGenerator.generateEvent(type: source.eventType)
                }
                event.source = source
                queue.append(event)
            }
            
            eventPoolQueues[source] = queue
        }
        
        eventsProcessedThisRound = 0
    }
    
    // MARK: - 触发下一个事件（由用户点击事务卡片触发）
    func triggerNextEventForSource(_ source: EventSource) {
        guard gameState == .playing else { return }
        guard currentEvent == nil else { return }  // 如果已有事件在显示，不重复触发
        guard toastMessage == nil else { return }  // 如果Toast正在显示，不触发新事件
        
        guard let queue = eventPoolQueues[source], !queue.isEmpty else { return }
        
        // 取出第一个事件显示（但不从队列移除，只有选择选项后才移除）
        currentEvent = queue[0]
    }
    
    // MARK: - 关闭事件弹窗（不减少数量）
    func closeEventPopup() {
        currentEvent = nil
    }
    
    // MARK: - 检查并触发紧急事件（自动弹出）
    private func checkAndTriggerCriticalEvent() {
        guard gameState == .playing else { return }
        guard currentEvent == nil else { return }  // 如果已有事件在显示，不重复触发
        guard toastMessage == nil else { return }  // 如果Toast正在显示，不触发
        
        guard let emperor = emperor else { return }
        
        // 基础概率
        var probability = 5
        
        // 检查属性状态：风雨飘摇时提高概率
        if emperor.nationalStatus == .turbulent {
            probability += 20
        }
        
        // 检查六维属性：任何属性低于30（0.3）时提高概率
        let attrs = emperor.attributes
        let lowAttributes = [
            attrs.mood < 0.3,
            attrs.intelligence < 0.3,
            attrs.charm < 0.3,
            attrs.reputation < 0.3,
            attrs.popularity < 0.3,
            attrs.morality < 0.3
        ].filter { $0 }.count
        
        // 每有一个属性低于30，增加10%概率
        probability += lowAttributes * 10
        
        // 限制最大概率为80%
        probability = min(probability, 80)
        
        let random = Int.random(in: 1...100)
        
        if random <= probability {
            // 生成紧急事件并自动弹出
            let criticalEvent = eventGenerator.generateCriticalEvent()
            currentEvent = criticalEvent
        }
    }
    
    // MARK: - 检查并进入下一回合
    private func checkAndAdvanceRound() {
        guard gameState == .playing else { return }
        
        // 如果所有事件池都空了，进入下一回合
        let allEmpty = eventPoolQueues.values.allSatisfy { $0.isEmpty }
        if allEmpty {
            advanceToNextRound()
        }
    }
    
    // MARK: - 进入下一回合（处理完所有事件后自动进入三个月）
    private func advanceToNextRound() {
        // 推进一个季节（三个月）
        currentSeason = currentSeason.next
        currentRound += 1
        
        // 每4个季节（12个月）年龄+1，在位年数+1
        if currentRound > 1 && (currentRound - 1) % 4 == 0, var emperor = emperor {
            emperor.age += 1
            emperor.yearInPower += 1
            self.emperor = emperor
        }
        
        // 检查回合上限
        if currentRound > maxRounds {
            endingType = .naturalEnd
            gameState = .ended
            return
        }
        
        // 生成新的事件池（不自动触发事件，等待用户点击事务卡片）
        generateEventPoolForRound()
        
        // 检查是否需要自动弹出紧急事件
        checkAndTriggerCriticalEvent()
    }
    
    // MARK: - 手动推进一年（点击光阴流转按钮）
    func advanceOneYear() {
        guard gameState == .playing else { return }
        
        // 推进4个季节（一年）
        for _ in 0..<4 {
            currentSeason = currentSeason.next
            currentRound += 1
        }
        
        // 年龄+1，在位年数+1
        if var emperor = emperor {
            emperor.age += 1
            emperor.yearInPower += 1
            self.emperor = emperor
        }
        
        // 检查回合上限
        if currentRound > maxRounds {
            endingType = .naturalEnd
            gameState = .ended
            return
        }
        
        // 生成新的事件池
        generateEventPoolForRound()
        
        // 检查是否需要自动弹出紧急事件
        checkAndTriggerCriticalEvent()
    }
    
    // MARK: - 处理事件选择（选择选项后才减少数量）
    func handleEventChoice(option: EventOption) {
        guard let event = currentEvent else { return }
        
        let eventSource = event.source
        let isCriticalEvent = event.type == .critical
        
        // 关闭弹窗
        currentEvent = nil
        
        // 只有非危急事件才从队列中移除
        if !isCriticalEvent {
            if var queue = eventPoolQueues[eventSource] {
                // 移除队列第一个事件（就是当前显示的这个）
                if !queue.isEmpty {
                    queue.removeFirst()
                    eventPoolQueues[eventSource] = queue
                }
            }
        }
        
        // 显示Toast消息
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            self.toastMessage = ToastMessage(text: option.toastText)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.toastMessage = nil
            }
        }
        
        // 更新六维属性
        if let changes = option.attributeChanges, var emperor = emperor {
            emperor.attributes.mood = max(0.0, min(1.0, emperor.attributes.mood + changes.mood))
            emperor.attributes.intelligence = max(0.0, min(1.0, emperor.attributes.intelligence + changes.intelligence))
            emperor.attributes.charm = max(0.0, min(1.0, emperor.attributes.charm + changes.charm))
            emperor.attributes.reputation = max(0.0, min(1.0, emperor.attributes.reputation + changes.reputation))
            emperor.attributes.popularity = max(0.0, min(1.0, emperor.attributes.popularity + changes.popularity))
            emperor.attributes.morality = max(0.0, min(1.0, emperor.attributes.morality + changes.morality))
            self.emperor = emperor
            
            // 检查数值极端
            checkExtremeValues()
        }
        
        // 更新世界侧写
        if let logText = option.logText {
            updateNarrative(source: eventSource, logText: logText)
        }
        
        // 记录日志
        if let logText = option.logText, !logText.isEmpty {
            let log = GameLog(
                season: currentSeason,
                year: currentYear,
                content: logText
            )
            logs.insert(log, at: 0)
            
            // 检查是否生成记忆片段
            if shouldGenerateMemoryFragment(logText: logText) {
                let fragment = generateMemoryFragment(logText: logText)
                memoryFragments.append(fragment)
            }
        }
        
        // 检查危急事件是否导致游戏结束
        if event.type == .critical {
            checkCriticalEventEnding(event: event, option: option)
        }
        
        // 如果游戏还在进行，记录已处理事件数
        if gameState == .playing {
            eventsProcessedThisRound += 1
            
            // 检查所有事件池是否都空了
            let allEmpty = eventPoolQueues.values.allSatisfy { $0.isEmpty }
            if allEmpty {
                // 所有事件池都空了，自动进入三个月（一个季节）
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.advanceToNextRound()
                }
            } else {
                // 还有事件，但不会自动弹出，等待用户点击事务卡片
                checkAndTriggerCriticalEvent()
            }
        }
    }
    
    // MARK: - 检查数值极端
    private func checkExtremeValues() {
        guard let emperor = emperor else { return }
        let attrs = emperor.attributes
        
        // 检查各属性是否极端，并记录原因
        if attrs.mood < 0.1 || attrs.mood > 0.9 {
            collapseReason = .mood
            endingType = .collapse
            gameState = .ended
        } else if attrs.intelligence < 0.1 || attrs.intelligence > 0.9 {
            collapseReason = .intelligence
            endingType = .collapse
            gameState = .ended
        } else if attrs.charm < 0.1 || attrs.charm > 0.9 {
            collapseReason = .charm
            endingType = .collapse
            gameState = .ended
        } else if attrs.reputation < 0.1 || attrs.reputation > 0.9 {
            collapseReason = .reputation
            endingType = .collapse
            gameState = .ended
        } else if attrs.popularity < 0.1 || attrs.popularity > 0.9 {
            collapseReason = .popularity
            endingType = .collapse
            gameState = .ended
        } else if attrs.morality < 0.1 || attrs.morality > 0.9 {
            collapseReason = .morality
            endingType = .collapse
            gameState = .ended
        }
    }
    
    // MARK: - 检查危急事件结局
    private func checkCriticalEventEnding(event: GameEvent, option: EventOption) {
        if let logText = option.logText {
            if logText.contains("身亡") || logText.contains("遇刺身亡") {
                suddenReason = .assassination
                endingType = .sudden
                gameState = .ended
            } else if logText.contains("覆灭") || logText.contains("谋反成功") || logText.contains("王朝覆灭") {
                suddenReason = .rebellion
                endingType = .sudden
                gameState = .ended
            }
        } else if option.text.contains("身亡") || option.toastText.contains("身亡") {
            suddenReason = .assassination
            endingType = .sudden
            gameState = .ended
        } else if option.text.contains("成功") || option.text.contains("覆灭") || option.toastText.contains("覆灭") {
            suddenReason = .rebellion
            endingType = .sudden
            gameState = .ended
        }
    }
    
    // MARK: - 更新世界侧写
    private func updateNarrative(source: EventSource, logText: String) {
        switch source {
        case .frontCourt:
            courtNarrative = logText
        case .courtPersonnel, .harem:
            palaceNarrative = logText
        case .publicOpinion:
            if logText.contains("朝堂") || logText.contains("政务") {
                courtNarrative = logText
            } else {
                palaceNarrative = logText
            }
        }
    }
    
    // MARK: - 判断是否生成记忆片段
    private func shouldGenerateMemoryFragment(logText: String) -> Bool {
        let keywords = ["灾民", "开仓", "放粮", "水灾", "救", "命", "救济", "百姓"]
        return keywords.contains { logText.contains($0) }
    }
    
    // MARK: - 生成记忆片段
    private func generateMemoryFragment(logText: String) -> MemoryFragment {
        if logText.contains("灾民") || logText.contains("开仓") || logText.contains("放粮") || logText.contains("救济") {
            let fragments = [
                MemoryFragment(
                    speaker: "获救的灾民后代",
                    content: "\"我祖父常说他这条命是陛下给的。如今我在学堂教书，告诉学生仁政救人的道理。\""
                ),
                MemoryFragment(
                    speaker: "开封老农",
                    content: "\"那年水灾，要不是陛下开仓放粮，我们一家早饿死了。我让孙子每年清明都朝京城方向碰个头。\""
                )
            ]
            return fragments.randomElement() ?? fragments[0]
        }
        
        return MemoryFragment(
            speaker: "民间百姓",
            content: "\"陛下在位期间，虽无大功亦无大过，王朝按旧制运行。\""
        )
    }
    
    // MARK: - 主动退位
    func abdicate() {
        endingType = .abdication
        gameState = .ended
        
        let log = GameLog(
            season: currentSeason,
            year: currentYear,
            content: "皇帝决定退位让贤"
        )
        logs.insert(log, at: 0)
    }
    
    // MARK: - 重新开始
    func restart() {
        startNewGame()
    }
    
    
    // MARK: - 获取事件池剩余数量
    func getEventPoolCount(for source: EventSource) -> Int {
        guard let queue = eventPoolQueues[source] else { return 0 }
        // 直接返回队列数量，因为弹出的事件还在队列中
        return queue.count
    }
    
    // MARK: - 获取季节描述
    func getSeasonDescription() -> String {
        switch currentSeason {
        case .spring: return "初春"
        case .summer: return "盛夏"
        case .autumn: return "深秋"
        case .winter: return "寒冬"
        }
    }
    
    // MARK: - 获取年号显示文本
    func getReignTitleDisplay() -> String {
        guard let emperor = emperor else { return "景和" }
        let year = emperor.yearInPower
        
        if year == 1 {
            return "\(emperor.reignTitle)元年"
        } else {
            // 将数字转换为中文数字
            return "\(emperor.reignTitle)\(chineseNumber(year))年"
        }
    }
    
    // MARK: - 中文数字转换
    private func chineseNumber(_ num: Int) -> String {
        let numbers = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
        if num <= 10 {
            return numbers[num]
        } else if num < 20 {
            return "十" + (num > 10 ? numbers[num - 10] : "")
        } else {
            let tens = num / 10
            let ones = num % 10
            return numbers[tens] + "十" + (ones == 0 ? "" : numbers[ones])
        }
    }
    
    // MARK: - 获取时间状态文本
    func getTimeStatusText() -> String {
        guard let emperor = emperor else { return "初登大宝" }
        
        let age = emperor.age
        
        if emperor.yearInPower == 1 {
            return "初登大宝"
        } else if age <= 30 {
            return ["锐意进取", "年轻有为", "励精图治", "少年天子"].randomElement() ?? "锐意进取"
        } else if age <= 45 {
            return ["春秋鼎盛", "年富力强", "稳坐江山", "运筹帷幄"].randomElement() ?? "春秋鼎盛"
        } else if age <= 55 {
            return ["久居帝位", "老成持重", "在位多年", "威望日隆"].randomElement() ?? "久居帝位"
        } else {
            return ["年事已高", "垂垂老矣", "日薄西山", "风烛残年"].randomElement() ?? "年事已高"
        }
    }
}
