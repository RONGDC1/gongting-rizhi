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
    
    // 月份系统
    @Published var currentMonth: Month = .january  // 当前月份（1-12）
    
    // 本月事件系统（每月4-6个事件）
    @Published var monthlyEvents: [GameEvent] = []  // 本月事件列表
    @Published var processedEventIds: Set<UUID> = []  // 已处理的事件ID
    
    // 事件池系统（保留用于兼容）
    @Published var eventPoolQueues: [EventSource: [GameEvent]] = [:]
    @Published var eventsProcessedThisRound: Int = 0
    
    // 关系系统
    @Published var haremMembers: [HaremMember] = []  // 后宫成员
    @Published var heirs: [Heir] = []  // 皇嗣
    @Published var crownPrince: Heir?  // 储君
    @Published var isRelationshipsUnlocked: Bool = false  // 关系tab是否解锁（完成新帝登基事件后解锁）
    
    // 记忆片段
    @Published var memoryFragments: [MemoryFragment] = []
    
    // 计算当前年份（每4回合为一年）
    var currentYear: Int {
        return (currentRound - 1) / 4 + 1
    }
    
    // 最大回合数（回合上限）
    let maxRounds: Int = 10
    
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
        currentMonth = .january
        logs = []
        gameState = .emperorConfirm
        currentEvent = nil
        endingType = nil
        collapseReason = nil
        suddenReason = nil
        toastMessage = nil
        eventPoolQueues = [:]
        eventsProcessedThisRound = 0
        monthlyEvents = []
        processedEventIds = []
        haremMembers = []
        heirs = []
        crownPrince = nil
        memoryFragments = []
        isRelationshipsUnlocked = false
        systemEventQueue = []  // 重置系统事件队列
        pendingHeirForNaming = nil  // 重置待命名皇嗣
        
        if emperor != nil {
            emperor!.yearInPower = 1
            emperor!.monthInYear = 1
        }
    }
    
    // MARK: - 确认皇帝信息，进入游戏（生成六维属性和四类属性标签）
    func confirmEmperorAndStart() {
        guard var emperor = emperor else { return }
        
        // 生成六维属性（包含体力）
        emperor.attributes = generateRandomAttributes()
        
        // 生成四类属性标签（随机展示一种）
        emperor.nationalStatus = NationalStatus.allCases.randomElement() ?? .prosperous
        emperor.resourceStatus = ResourceStatus.allCases.randomElement() ?? .balanced
        emperor.courtStatus = CourtStatus.allCases.randomElement() ?? .harmonious
        emperor.heirStatus = HeirStatus.allCases.randomElement() ?? .adequate
        
        // 生成皇帝特质标签（2-3个）
        let allTraits = EmperorTrait.allCases
        let traitCount = Int.random(in: 2...3)
        emperor.traits = Array(allTraits.shuffled().prefix(traitCount))
        
        // 初始化月份
        emperor.monthInYear = 1
        
        self.emperor = emperor
        gameState = .playing
        
        // 添加新帝即位日志
        let initialLog = GameLog(
            season: currentSeason,
            year: currentYear,
            content: "新帝即位，天下静观其变。"
        )
        logs.insert(initialLog, at: 0)
        
        // 生成初始后宫成员（三位妃子：皇后、贵妃、妃）
        generateInitialHarem()
        
        // 触发开局系统弹窗事件序列（祝贺新帝登基 -> 册立皇后）
        triggerCoronationSystemEventSequence()
        
        // 注意：开局不生成普通本月事件，系统弹窗事件完成后才生成本月事件
    }
    
    // MARK: - 生成初始后宫成员（开局默认三位妃子：皇后、贵妃、妃，各只有一位）
    private func generateInitialHarem() {
        let names = ["柳清涟", "赵修竹", "李婉容", "王若兰", "陈素心"]
        let shuffledNames = names.shuffled()
        
        // 确保有且仅有一位皇后、一位贵妃、一位妃，开局默认三位妃子
        let ranks: [HaremRank] = [.empress, .nobleConsort, .consort]
        
        for i in 0..<3 {
            let name = shuffledNames[i]
            let rank = ranks[i]  // 固定顺序：皇后、贵妃、妃
            let age = Int.random(in: 25...35)
            
            // 根据位分随机生成优秀属性
            var traits: [HaremTrait] = []
            if rank == .empress {
                traits = [.dignified, .clever].shuffled().prefix(2).map { $0 }
            } else if rank == .nobleConsort {
                let allTraits = HaremTrait.allCases
                traits = Array(allTraits.shuffled().prefix(Int.random(in: 1...2)))
            } else {
                let allTraits = HaremTrait.allCases
                traits = Array(allTraits.shuffled().prefix(Int.random(in: 1...2)))
            }
            
            let member = HaremMember(
                name: name,
                rank: rank,
                age: age,
                influence: rank == .empress ? Int.random(in: 90...100) : Int.random(in: 60...90),
                affection: rank == .empress ? 100 : Int.random(in: 20...80),
                traits: traits
            )
            haremMembers.append(member)
        }
        
        // 按位份排序：皇后、贵妃、妃
        haremMembers.sort { member1, member2 in
            let rankOrder: [HaremRank: Int] = [.empress: 0, .nobleConsort: 1, .consort: 2, .concubine: 3, .nobleLady: 4]
            return (rankOrder[member1.rank] ?? 99) < (rankOrder[member2.rank] ?? 99)
        }
    }
    
    // MARK: - 生成随机皇帝（不包含六维属性）
    private func generateRandomEmperor() -> Emperor {
        let names = nameGenerator.generateEmperorName()
        let ages = Int.random(in: 20...30)  // 根据需求：20-30岁随机
        let statuses: [DynastyStatus] = [.prosperity, .stable, .unstable]
        let reignTitles = ["永泰", "平瑞", "元启", "建青", "光熙", "正元", "天和", "景和"]
        
        return Emperor(
            name: names,
            age: ages,
            dynastyStatus: statuses.randomElement() ?? .stable,
            yearInPower: 1,
            monthInYear: 1,  // 初始月份：正月
            reignTitle: reignTitles.randomElement() ?? "元启",
            traits: []  // 特质在confirmEmperorAndStart中生成
        )
    }
    
    // MARK: - 生成随机六维属性（包含体力）
    private func generateRandomAttributes() -> EmperorAttributes {
        return EmperorAttributes(
            stamina: 100.0,  // 体力初始为100
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
        
        // 危急刺杀事件不在开局第一回合触发
        if emperor.monthInYear == 1 && emperor.yearInPower == 1 {
            return
        }
        
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
    
    // MARK: - 手动推进一年（已废弃，现在使用endCurrentMonth按月推进）
    @available(*, deprecated, message: "使用endCurrentMonth()按月推进")
    func advanceOneYear() {
        guard gameState == .playing else { return }
        
        // 兼容旧代码：推进12个月（一年）
        guard var emperor = emperor else { return }
        
        for _ in 0..<12 {
            if emperor.monthInYear == 12 {
                emperor.monthInYear = 1
                emperor.yearInPower += 1
                emperor.age += 1
            } else {
                emperor.monthInYear += 1
            }
        }
        
        // 恢复体力
        emperor.attributes.stamina = 100.0
        
        self.emperor = emperor
        
        // 生成本月事件
        generateMonthlyEvents()
        
        // 检查是否需要自动弹出紧急事件
        checkAndTriggerCriticalEvent()
    }
    
    // MARK: - 处理事件选择（选择选项后直接关闭弹窗）
    func handleEventChoice(option: EventOption) {
        guard let event = currentEvent else { return }
        
        let eventSource = event.source
        let isCriticalEvent = event.type == .critical
        
        // 处理系统事件队列
        if event.isSystemEvent {
            // 处理新帝登基专属事件：册立后妃
            if event.title == "册立后妃" {
                // 从选项文本中提取名字（格式：册立XXX为皇后）
                let optionText = option.text
                if optionText.hasPrefix("册立") && optionText.hasSuffix("为皇后") {
                    let name = String(optionText.dropFirst(2).dropLast(3))
                    updateHaremRank(name: name, newRank: .empress)
                }
            }
            
            // 处理皇嗣命名事件
            if event.title == "皇嗣命名" {
                if option.text == "采用礼部命名" {
                    // 使用默认名字
                    if let pending = pendingHeirForNaming {
                        var finalHeir = pending.heir
                        finalHeir.name = pending.defaultName
                        heirs.append(finalHeir)
                        pendingHeirForNaming = nil
                    }
                } else if option.text == "朕亲自命名" {
                    // 触发自定义命名弹窗（这里先使用默认名字，后续可以扩展为输入框）
                    // 暂时使用默认名字
                    if let pending = pendingHeirForNaming {
                        var finalHeir = pending.heir
                        finalHeir.name = pending.defaultName
                        heirs.append(finalHeir)
                        pendingHeirForNaming = nil
                    }
                }
            }
            
            // 从队列中移除当前事件
            systemEventQueue.removeAll { $0.id == event.id }
            
            // 先关闭当前弹窗
            currentEvent = nil
            
            // 如果队列中还有事件，无缝切换到下一个
            if let nextEvent = systemEventQueue.first {
                // 延迟一点时间，让当前弹窗关闭动画完成，然后显示下一个事件
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.currentEvent = nextEvent
                }
            } else {
                // 所有系统事件完成，生成本月普通事件并解锁关系tab
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.isRelationshipsUnlocked = true
                    self?.generateMonthlyEvents()
                }
            }
        } else {
            // 普通事件和危急事件：选择选项后直接关闭弹窗
            currentEvent = nil
        }
        
        // 标记事件为已处理（本月事件系统）
        if !isCriticalEvent {
            processedEventIds.insert(event.id)
            
            // 更新事件反馈文本
            if let index = monthlyEvents.firstIndex(where: { $0.id == event.id }) {
                monthlyEvents[index].isProcessed = true
                monthlyEvents[index].feedbackText = option.toastText
            }
        }
        
        // 选择选项后直接关闭弹窗（由调用方处理）
        
        // 兼容旧的事件池系统
        if !isCriticalEvent {
            if var queue = eventPoolQueues[eventSource] {
                if !queue.isEmpty {
                    queue.removeFirst()
                    eventPoolQueues[eventSource] = queue
                }
            }
        }
        
        // 不再显示Toast消息，反馈直接显示在事件详情卡片内
        
        // 更新六维属性（包含体力）
        if var emperor = emperor {
            // 处理本月事件时，扣除体力-10（系统事件不扣除）
            if !isCriticalEvent && !event.isSystemEvent {
                emperor.attributes.stamina = max(0.0, emperor.attributes.stamina - 10.0)
            }
            
            // 更新属性变化（如果有）
            if let changes = option.attributeChanges {
                // 更新体力（如果有变化，且体力范围是0-100）
                if changes.stamina != 0.0 {
                    emperor.attributes.stamina = max(0.0, min(100.0, emperor.attributes.stamina + changes.stamina))
                }
                
                // 更新其他六维属性（范围0.0-1.0）
                emperor.attributes.mood = max(0.0, min(1.0, emperor.attributes.mood + changes.mood))
                emperor.attributes.intelligence = max(0.0, min(1.0, emperor.attributes.intelligence + changes.intelligence))
                emperor.attributes.charm = max(0.0, min(1.0, emperor.attributes.charm + changes.charm))
                emperor.attributes.reputation = max(0.0, min(1.0, emperor.attributes.reputation + changes.reputation))
                emperor.attributes.popularity = max(0.0, min(1.0, emperor.attributes.popularity + changes.popularity))
                emperor.attributes.morality = max(0.0, min(1.0, emperor.attributes.morality + changes.morality))
            }
            
            self.emperor = emperor
            
            // 检查数值极端（只检查六维，不检查体力）
            checkExtremeValues()
            
            // 检查体力为0时强制休息
            if emperor.attributes.stamina <= 0 {
                handleStaminaExhausted()
            }
        }
        
        // 世界侧写已移除，不再更新
        
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
    
    /// 更新后宫成员位分
    private func updateHaremRank(name: String, newRank: HaremRank) {
        // 先将所有其他成员的皇后位分移除
        for i in 0..<haremMembers.count {
            if haremMembers[i].rank == .empress && haremMembers[i].name != name {
                haremMembers[i].rank = .nobleConsort  // 降为贵妃
            }
        }
        
        // 设置新皇后
        if let index = haremMembers.firstIndex(where: { $0.name == name }) {
            haremMembers[index].rank = newRank
            if newRank == .empress {
                haremMembers[index].affection = 100  // 皇后好感度设为100
            }
        }
    }
    
    /// 检查新帝登基事件是否全部完成（已废弃，现在使用系统弹窗事件）
    private func checkCoronationEventsCompletion() {
        // 此方法已废弃，新帝登基事件现在通过系统弹窗处理
        // 保留此方法以避免编译错误，但不再使用
    }
    
    // MARK: - 检查数值极端（只检查数值过低的情况）
    private func checkExtremeValues() {
        guard let emperor = emperor else { return }
        let attrs = emperor.attributes
        
        // 检查各属性是否过低（<0.1），并记录原因
        if attrs.mood < 0.1 {
            collapseReason = .mood
            endingType = .collapse
            gameState = .ended
        } else if attrs.intelligence < 0.1 {
            collapseReason = .intelligence
            endingType = .collapse
            gameState = .ended
        } else if attrs.charm < 0.1 {
            collapseReason = .charm
            endingType = .collapse
            gameState = .ended
        } else if attrs.reputation < 0.1 {
            collapseReason = .reputation
            endingType = .collapse
            gameState = .ended
        } else if attrs.popularity < 0.1 {
            collapseReason = .popularity
            endingType = .collapse
            gameState = .ended
        } else if attrs.morality < 0.1 {
            collapseReason = .morality
            endingType = .collapse
            gameState = .ended
        }
    }
    
    /// 扣除妃子互动体力（-10）
    func deductStaminaForHaremInteraction() {
        guard var emperor = emperor else { return }
        emperor.attributes.stamina = max(0.0, emperor.attributes.stamina - 10.0)
        self.emperor = emperor
        
        // 检查体力为0时强制休息
        if emperor.attributes.stamina <= 0 {
            handleStaminaExhausted()
        }
    }
    
    // MARK: - 处理体力耗尽（强制休息到下个月）
    private func handleStaminaExhausted() {
        guard gameState == .playing else { return }
        
        // 显示提示
        toastMessage = ToastMessage(text: "体力耗尽，强制休息至下月恢复")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.toastMessage = nil
        }
        
        // 自动进入下一个月（恢复体力）
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.endCurrentMonth()
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
    
    // MARK: - 以储君身份开始新游戏
    func startNewGameWithHeir(crownPrince heir: Heir) {
        // 保存当前游戏状态（用于继承趋势）
        let previousAttributes = emperor?.attributes
        
        // 判断储君是否成年（假设16岁为成年）
        let isAdult = heir.age >= 16
        
        if !isAdult {
            // 情况A：储君未成年
            // 触发全局提示页（这里简化为直接快进到成年）
            // 新帝年龄设为16岁
            let newAge = 16
            let newEmperor = createEmperorFromHeir(heir: heir, age: newAge)
            self.emperor = newEmperor
        } else {
            // 情况B：储君已成年
            // 直接继位，年龄=当前实际年龄
            let newEmperor = createEmperorFromHeir(heir: heir, age: heir.age)
            self.emperor = newEmperor
        }
        
        // 继承部分标签（从储君特质中继承）
        if var newEmperor = self.emperor {
            // 继承部分皇帝特质（从储君特质转换）
            newEmperor.traits = convertHeirTraitsToEmperorTraits(heirTraits: heir.traits)
            
            // 世界状态继承"趋势"（非精确数值）
            // 根据前一个皇帝的属性趋势，设置新皇帝的初始属性
            if let previousAttrs = previousAttributes {
                // 继承趋势：如果前一个皇帝某项属性较高，新皇帝该项也较高（但随机化）
                newEmperor.attributes = generateInheritedAttributes(previousAttributes: previousAttrs)
            } else {
                // 如果没有前一个皇帝的数据，使用随机属性
                newEmperor.attributes = generateRandomAttributes()
            }
            
            // 重置游戏状态
            newEmperor.yearInPower = 1
            newEmperor.monthInYear = 1
            self.emperor = newEmperor
        }
        
        // 重置游戏状态
        currentSeason = .spring
        currentRound = 1
        currentMonth = .january
        logs = []
        gameState = .emperorConfirm
        currentEvent = nil
        endingType = nil
        collapseReason = nil
        suddenReason = nil
        toastMessage = nil
        eventPoolQueues = [:]
        eventsProcessedThisRound = 0
        monthlyEvents = []
        processedEventIds = []
        haremMembers = []
        heirs = []
        self.crownPrince = nil
        memoryFragments = []
        isRelationshipsUnlocked = false
        systemEventQueue = []
        pendingHeirForNaming = nil
        
        // 生成初始后宫成员
        generateInitialHarem()
    }
    
    /// 从储君创建新皇帝
    private func createEmperorFromHeir(heir: Heir, age: Int) -> Emperor {
        // 生成年号（随机）
        let reignTitles = ["永泰", "平瑞", "元启", "建青", "光熙", "正元", "天和", "景和"]
        
        return Emperor(
            name: heir.name,  // 使用储君的完整名字
            age: age,
            dynastyStatus: .stable,  // 默认稳定
            yearInPower: 1,
            monthInYear: 1,
            reignTitle: reignTitles.randomElement() ?? "元启",
            traits: []  // 特质在后续设置
        )
    }
    
    /// 从名字中提取姓
    private func getSurnameFromName(_ name: String) -> String {
        let doubleCharSurnames = ["宇文", "拓跋", "钟离"]
        for surname in doubleCharSurnames {
            if name.hasPrefix(surname) {
                return surname
            }
        }
        // 默认返回第一个字符作为姓
        return String(name.prefix(1))
    }
    
    /// 从名字中提取名（去掉姓）
    private func getNameWithoutSurname(_ name: String) -> String {
        let surname = getSurnameFromName(name)
        return String(name.dropFirst(surname.count))
    }
    
    /// 将储君特质转换为皇帝特质
    private func convertHeirTraitsToEmperorTraits(heirTraits: [HeirTrait]) -> [EmperorTrait] {
        var emperorTraits: [EmperorTrait] = []
        
        // 根据储君特质映射到皇帝特质
        for trait in heirTraits {
            switch trait {
            case .intelligent:
                if Bool.random() {
                    emperorTraits.append(.diligent)  // 聪敏 -> 勤于政务
                }
            case .talented:
                if Bool.random() {
                    emperorTraits.append(.decisive)  // 天赋异禀 -> 果断决断
                }
            default:
                break
            }
        }
        
        // 确保至少有2-3个特质
        if emperorTraits.count < 2 {
            let allTraits = EmperorTrait.allCases
            let neededCount = 2 - emperorTraits.count
            let additionalTraits = Array(allTraits.shuffled().prefix(neededCount))
            emperorTraits.append(contentsOf: additionalTraits)
        }
        
        return Array(emperorTraits.prefix(3))
    }
    
    /// 生成继承的属性（基于前一个皇帝的趋势）
    private func generateInheritedAttributes(previousAttributes: EmperorAttributes) -> EmperorAttributes {
        // 继承趋势：如果前一个皇帝某项属性较高，新皇帝该项也较高（但随机化）
        func inheritValue(_ previous: Double) -> Double {
            // 如果前一个皇帝属性较高（>0.6），新皇帝也较高（0.5-0.8）
            // 如果前一个皇帝属性较低（<0.4），新皇帝也较低（0.2-0.5）
            // 否则随机（0.3-0.7）
            if previous > 0.6 {
                return Double.random(in: 0.5...0.8)
            } else if previous < 0.4 {
                return Double.random(in: 0.2...0.5)
            } else {
                return Double.random(in: 0.3...0.7)
            }
        }
        
        return EmperorAttributes(
            stamina: 100.0,  // 体力初始为100
            mood: inheritValue(previousAttributes.mood),
            intelligence: inheritValue(previousAttributes.intelligence),
            charm: inheritValue(previousAttributes.charm),
            reputation: inheritValue(previousAttributes.reputation),
            popularity: inheritValue(previousAttributes.popularity),
            morality: inheritValue(previousAttributes.morality)
        )
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
    
    // MARK: - 月份系统相关方法
    
    /// 获取月份显示文本（如：景和元年·正月(1/12)）
    func getMonthDisplayText() -> String {
        guard let emperor = emperor else { return "景和元年·正月(1/12)" }
        let year = emperor.yearInPower
        let month = emperor.monthInYear
        
        let yearText: String
        if year == 1 {
            yearText = "\(emperor.reignTitle)元年"
        } else {
            yearText = "\(emperor.reignTitle)\(chineseNumber(year))年"
        }
        
        let monthName = Month(rawValue: month)?.name ?? "正月"
        return "\(yearText)·\(monthName)(\(month)/12)"
    }
    
    /// 获取本月事件列表
    func getMonthlyEvents() -> [GameEvent] {
        return monthlyEvents
    }
    
    /// 选择事件（打开详情弹窗）
    func selectEvent(_ event: GameEvent) {
        currentEvent = event
    }
    
    /// 结束本月（推进到下一个月）
    func endCurrentMonth() {
        guard var emperor = emperor else { return }
        
        // 处理未处理的事件（可能恶化）
        handleUnprocessedEvents()
        
        // 处理怀孕状态：增加怀孕月份，9个月后生产
        handlePregnancyProgress()
        
        // 推进月份
        if emperor.monthInYear == 12 {
            // 进入下一年
            emperor.monthInYear = 1
            emperor.yearInPower += 1
            emperor.age += 1
        } else {
            emperor.monthInYear += 1
        }
        
        // 恢复体力
        emperor.attributes.stamina = 100.0
        
        self.emperor = emperor
        
        // 生成新月份的事件（不包含妃子遇喜提醒）
        generateMonthlyEvents()
        
        // 检查是否需要自动弹出紧急事件
        checkAndTriggerCriticalEvent()
    }
    
    /// 处理怀孕进度：增加怀孕月份，9个月后生产
    private func handlePregnancyProgress() {
        for i in 0..<haremMembers.count {
            if haremMembers[i].healthStatus == .pregnant,
               var month = haremMembers[i].pregnancyMonth {
                month += 1
                haremMembers[i].pregnancyMonth = month
                
                // 9个月后生产
                if month >= 9 {
                    // 移除怀孕状态
                    haremMembers[i].healthStatus = nil
                    haremMembers[i].pregnancyMonth = nil
                    haremMembers[i].children += 1
                    
                    // 生成皇嗣
                    generateHeir(motherName: haremMembers[i].name, motherTraits: haremMembers[i].traits)
                    
                    // 触发系统弹窗事件：皇嗣出生
                    triggerBirthSystemEvent(memberName: haremMembers[i].name)
                }
            }
        }
    }
    
    /// 生成皇嗣（触发命名系统弹窗）
    private func generateHeir(motherName: String, motherTraits: [HaremTrait]) {
        let gender: Gender = Bool.random() ? .male : .female
        
        // 获取皇帝的姓（从皇帝名字中提取）
        let emperorSurname = getEmperorSurname()
        
        // 生成默认名字（礼部命名）
        let defaultName = generateHeirName(surname: emperorSurname, gender: gender)
        
        // 创建临时皇嗣（待命名）
        let tempHeir = Heir(
            name: defaultName,  // 临时名字，用户可以选择修改
            gender: gender,
            age: 0,
            looks: Int.random(in: 50...100),
            ability: Int.random(in: 30...90),
            influence: 0,
            motherName: motherName,
            traits: generateHeirTraits(motherTraits: motherTraits)
        )
        
        // 触发命名系统弹窗事件
        triggerHeirNamingEvent(heir: tempHeir, emperorSurname: emperorSurname)
    }
    
    /// 获取皇帝的姓
    private func getEmperorSurname() -> String {
        guard let emperor = emperor else { return "拓跋" }
        // 从皇帝名字中提取姓（假设是单字或双字姓）
        let name = emperor.name
        // 常见单字姓
        let singleCharSurnames = ["赵", "刘", "杨", "沈", "凌"]
        // 常见双字姓
        let doubleCharSurnames = ["宇文", "拓跋", "钟离"]
        
        // 检查是否是双字姓
        for surname in doubleCharSurnames {
            if name.hasPrefix(surname) {
                return surname
            }
        }
        
        // 检查是否是单字姓
        for surname in singleCharSurnames {
            if name.hasPrefix(surname) {
                return surname
            }
        }
        
        // 默认返回第一个字符作为姓
        return String(name.prefix(1))
    }
    
    /// 生成皇嗣名字（礼部命名）
    private func generateHeirName(surname: String, gender: Gender) -> String {
        let maleNames = ["世乾", "元灏", "光文", "建平", "延", "衡", "熙", "尘山", "澈", "翊钧", "景玺", "瑞"]
        let femaleNames = ["婉容", "若兰", "素心", "清涟", "修竹", "月华", "雪梅", "秋霜", "春晓", "夏荷"]
        
        let givenName = gender == .male 
            ? (maleNames.randomElement() ?? "延")
            : (femaleNames.randomElement() ?? "婉容")
        return surname + givenName
    }
    
    /// 触发皇嗣命名系统弹窗事件
    private func triggerHeirNamingEvent(heir: Heir, emperorSurname: String) {
        let defaultName = heir.name
        let genderText = heir.gender == .male ? "皇子" : "公主"
        
        let namingEvent = GameEvent(
            title: "皇嗣命名",
            type: .harem,
            description: "【礼部】\n\n\(heir.motherName)顺利生产，诞下\(genderText)。\n\n礼部拟名：\(defaultName)\n\n请陛下决定：",
            options: [
                EventOption(
                    text: "采用礼部命名",
                    toastText: "\(defaultName)之名已定，录入宗谱",
                    logText: "皇嗣\(defaultName)降生，采用礼部命名。",
                    attitude: .balanced,
                    attributeChanges: AttributeChanges(stamina: 0.0, mood: 0.1, intelligence: 0.0, charm: 0.05, reputation: 0.05, popularity: 0.05, morality: 0.0)
                ),
                EventOption(
                    text: "朕亲自命名",
                    toastText: "等待陛下赐名...",
                    logText: nil,
                    attitude: .balanced,
                    attributeChanges: AttributeChanges(stamina: 0.0, mood: 0.0, intelligence: 0.0, charm: 0.0, reputation: 0.0, popularity: 0.0, morality: 0.0)
                )
            ],
            source: .harem,
            isSystemEvent: true  // 标记为系统事件
        )
        
        // 临时存储待命名的皇嗣信息
        pendingHeirForNaming = (heir: heir, defaultName: defaultName, surname: emperorSurname)
        
        // 设置为系统事件，自动弹出
        currentEvent = namingEvent
    }
    
    // 临时存储待命名的皇嗣信息
    @Published var pendingHeirForNaming: (heir: Heir, defaultName: String, surname: String)? = nil
    
    /// 生成皇嗣特质（继承自父母）
    private func generateHeirTraits(motherTraits: [HaremTrait]) -> [HeirTrait] {
        var traits: [HeirTrait] = []
        // 根据母妃特质生成子嗣特质（简化实现）
        if motherTraits.contains(.clever) {
            if Bool.random() {
                traits.append(.intelligent)
            }
        }
        return traits
    }
    
    /// 触发妃子有喜系统弹窗事件
    func triggerPregnancySystemEvent(memberName: String) {
        let event = GameEvent(
            title: "妃子有喜",
            type: .harem,
            description: "太医院恭敬禀报：\(memberName)遇喜了！宫中顿时一阵轻微骚动，连窗外的小鸟似乎都停了片刻。",
            options: [
                EventOption(
                    text: "前往探望",
                    toastText: "见到爱妃安好，心头一片暖意",
                    logText: "皇帝前往探望有喜的妃子，关怀备至。",
                    attitude: .lenient,
                    attributeChanges: AttributeChanges(stamina: 0.0, mood: 0.1, intelligence: 0.0, charm: 0.05, reputation: 0.0, popularity: 0.0, morality: 0.0)
                ),
                EventOption(
                    text: "暂缓理会",
                    toastText: "皇帝埋首文书，眉眼却未展喜色",
                    logText: nil,
                    attitude: .balanced,
                    attributeChanges: AttributeChanges(stamina: 0.0, mood: -0.05, intelligence: 0.05, charm: -0.05, reputation: 0.0, popularity: 0.0, morality: 0.0)
                )
            ],
            source: .harem,
            isSystemEvent: true  // 标记为系统事件
        )
        // 设置为系统事件，自动弹出
        currentEvent = event
    }
    
    /// 触发皇嗣出生系统弹窗事件（已废弃，现在使用命名事件）
    func triggerBirthSystemEvent(memberName: String) {
        // 此方法已废弃，皇嗣出生现在通过generateHeir触发命名事件
        // 保留此方法以避免编译错误，但不再使用
    }
    
    // 系统事件队列（用于无缝切换多个系统事件）
    @Published var systemEventQueue: [GameEvent] = []
    
    /// 触发开局系统弹窗事件序列（祝贺新帝登基 -> 册立皇后）
    private func triggerCoronationSystemEventSequence() {
        guard let emperor = emperor else { return }
        
        // 第一个事件：祝贺新帝登基（给玩家开局身份感）
        let congratulationEvent = GameEvent(
            title: "新帝登基",
            type: .palace,
            description: "【朝贺】\n你作为新帝的第一天，天下静观其变：\n\n新帝\(emperor.name)登基，天下臣民齐声祝贺。礼部奏报：\"陛下初登大宝，万民仰望，朝野上下皆期盼明君治世。",
            options: [
                EventOption(
                    text: "接受朝贺",
                    toastText: "新帝接受朝贺，朝野上下皆感振奋",
                    logText: "新帝登基，接受天下朝贺，万民仰望。",
                    attitude: .balanced,
                    attributeChanges: AttributeChanges(stamina: 0.0, mood: 0.15, intelligence: 0.0, charm: 0.1, reputation: 0.15, popularity: 0.1, morality: 0.05)
                )
            ],
            source: .frontCourt,
            isSystemEvent: true  // 标记为系统事件
        )
        
        // 第二个事件：册立皇后
        let haremNames = haremMembers.map { $0.name }
        let coronationEvent = GameEvent(
            title: "册立后妃",
            type: .harem,
            description: "【内廷】新帝登基，礼部奏请册立皇后。需从宫中佳丽中选定一位为皇后。",
            options: haremNames.prefix(3).map { name in
                EventOption(
                    text: "册立\(name)为皇后",
                    toastText: "\(name)被册立为皇后，母仪天下",
                    logText: "新帝登基，册立\(name)为皇后。",
                    attitude: .balanced,
                    attributeChanges: AttributeChanges(stamina: 0.0, mood: 0.1, intelligence: 0.0, charm: 0.1, reputation: 0.1, popularity: 0.05, morality: 0.0)
                )
            },
            source: .harem,
            isSystemEvent: true  // 标记为系统事件
        )
        
        // 将两个事件加入队列
        systemEventQueue = [congratulationEvent, coronationEvent]
        
        // 弹出第一个事件
        if let firstEvent = systemEventQueue.first {
            currentEvent = firstEvent
        }
    }
    
    /// 生成本月事件（4-6个）
    private func generateMonthlyEvents() {
        let eventCount = Int.random(in: 4...6)
        var events: [GameEvent] = []
        
        // 根据游戏阶段确定事件池
        let stage = getCurrentStage()
        let sources: [EventSource] = [.frontCourt, .courtPersonnel, .harem, .publicOpinion]
        
        for _ in 0..<eventCount {
            let source = sources.randomElement() ?? .frontCourt
            var event: GameEvent
            
            if source == .publicOpinion {
                event = eventGenerator.generatePublicOpinionEvent()
            } else {
                event = eventGenerator.generateEvent(type: source.eventType)
            }
            
            event.source = source
            event.stage = stage
            events.append(event)
        }
        
        monthlyEvents = events
        processedEventIds = []
    }
    
    /// 获取当前游戏阶段
    private func getCurrentStage() -> GameStage {
        guard let emperor = emperor else { return .earlyReign }
        
        let totalMonths = (emperor.yearInPower - 1) * 12 + emperor.monthInYear
        
        if totalMonths <= 12 {
            return .earlyReign  // 初登基（1-12月）
        } else if emperor.yearInPower <= 5 {
            return .stable  // 稳定期（第2-5年）
        } else {
            return .midLate  // 中后期（第6年+）
        }
    }
    
    /// 处理未处理的事件（月末结算）
    /// 未处理的事件可能恶化或转化为隐患，或在下个月以"更糟版本"再出现
    private func handleUnprocessedEvents() {
        for event in monthlyEvents {
            if !processedEventIds.contains(event.id) {
                // 未处理的事件可能恶化
                // 根据事件类型和游戏阶段，决定是否恶化或转化为隐患
                // 这里可以添加更复杂的逻辑，暂时只记录日志
                let log = GameLog(
                    season: currentSeason,
                    year: currentYear,
                    content: "\(event.title)未及时处理，可能带来后续影响。"
                )
                logs.insert(log, at: 0)
            }
        }
    }
    
    /// 设置储君
    func setCrownPrince(heir: Heir) {
        // 取消之前的储君
        if let previousCrownPrince = crownPrince {
            if let index = heirs.firstIndex(where: { $0.id == previousCrownPrince.id }) {
                heirs[index].isCrownPrince = false
            }
        }
        
        // 设置新储君
        if let index = heirs.firstIndex(where: { $0.id == heir.id }) {
            heirs[index].isCrownPrince = true
            crownPrince = heirs[index]
            
            // 记录日志
            let log = GameLog(
                season: currentSeason,
                year: currentYear,
                content: "皇帝立\(heir.name)为储君。"
            )
            logs.insert(log, at: 0)
        }
    }
    
    /// 获取近期消息（用于关系视图）
    func getRecentNews() -> String? {
        if heirs.isEmpty {
            return "【近期消息】宗庙无继，朝中已有隐忧..."
        } else if crownPrince == nil {
            return "【近期消息】皇帝还未立储，朝野势力暗暗观望。"
        }
        return nil
    }
}
