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
    @Published var currentRound: Int = 1  // 当前回合数（从1开始）
    @Published var gameState: GameState = .emperorConfirm
    @Published var currentEvent: GameEvent?
    @Published var endingType: EndingType?
    @Published var toastMessage: ToastMessage?  // Toast消息
    @Published var showingLogsView: Bool = false  // 是否显示日志查看页

    // -----------------------------
    // 计算当前年份（每4回合为一年）
    // -----------------------------
    var currentYear: Int {
        return (currentRound - 1) / 4 + 1
    }

    // -----------------------------
    // 新增事件计数属性，用于4次事件自动下一回合
    // -----------------------------
    @Published var eventsThisRound: Int = 0   // 当前回合触发事件次数
    let maxEventsPerRound = 4                 // 4次事件自动下一回合

    
    // 随机生成器
    private let nameGenerator = NameGenerator()
    private let eventGenerator = EventGenerator()
    private var eventTimer: Timer?
    
    // MARK: - 初始化游戏
    func startNewGame() {
        // 生成随机皇帝
        emperor = generateRandomEmperor()
        
        // 重置游戏状态
        currentSeason = .spring
        currentRound = 1
        logs = []
        gameState = .emperorConfirm
        currentEvent = nil
        endingType = nil
        toastMessage = nil
        showingLogsView = false
        
        // 停止事件定时器
        eventTimer?.invalidate()
        eventTimer = nil
        
        // 更新皇帝年份为1
        if emperor != nil {
            emperor!.yearInPower = 1
        }
    }
    
    // MARK: - 重新生成皇帝（换一换功能）
    func regenerateEmperor() {
        emperor = generateRandomEmperor()
        if emperor != nil {
            emperor!.yearInPower = 1
        }
    }
    
    // MARK: - 确认皇帝信息，进入游戏
    func confirmEmperorAndStart() {
        gameState = .playing
        
        // 添加新帝即位日志（自动添加季节和年份）
        let initialLog = GameLog(
            season: currentSeason,
            year: currentYear,
            content: "\(currentSeason.rawValue) · 第\(currentYear)年｜新帝即位，天下静观其变。民心增加"
        )
        logs.insert(initialLog, at: 0)
        
        // 启动事件定时器（随机时间触发，比如5秒左右）
        scheduleRandomEvent()
    }
    
    // MARK: - 生成随机皇帝
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
    
    // MARK: - 安排随机事件
    @MainActor
    func scheduleRandomEvent() {
        // 取消之前的定时器
        eventTimer?.invalidate()
        
        // 随机延迟时间（4-5秒）
        let delay = Double.random(in: 4...5)
        
        eventTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.triggerRandomEvent()
        }
    }
    
    // MARK: - 触发随机事件
    func triggerRandomEvent() {
        // ✅ 1️⃣ 游戏未在进行中则直接返回，防止多余触发
        guard gameState == .playing else { return }

        // ✅ 2️⃣ 处理危急事件
        // 危急事件概率较低，但飘摇状态会提升概率
        if shouldTriggerCriticalEvent() {
            currentEvent = eventGenerator.generateCriticalEvent()
            return
        }

        // ✅ 3️⃣ 处理普通随机事件
        let eventType: EventType
        let random = Int.random(in: 1...100)

        if random <= 33 {
            eventType = .frontCourt   // 前朝事件
        } else if random <= 66 {
            eventType = .palace       // 宫廷事件
        } else {
            eventType = .harem        // 后宫事件
        }

        // 生成事件并赋值给 currentEvent
        currentEvent = eventGenerator.generateEvent(type: eventType)

        // ✅ 4️⃣ 增加本回合事件计数
        eventsThisRound += 1

        // ✅ 5️⃣ 如果事件次数达到上限，自动进入下一回合
        if eventsThisRound >= maxEventsPerRound {
            // 延迟 0.3 秒，让第四个事件短暂显示
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.nextRound()
            }
        }
    }

    
    // MARK: - 判断是否触发危急事件
    private func shouldTriggerCriticalEvent() -> Bool {
        // 基础概率较低
        var baseProbability = 3  // 3%基础概率
        
        // 如果王朝状态为飘摇，概率提升
        if emperor?.dynastyStatus == .unstable {
            baseProbability = 15  // 飘摇状态提升到15%
        }
        
        // 游戏进行越久，概率也稍微提升
        let yearBonus = currentYear * 1  // 每年增加1%
        let finalProbability = min(baseProbability + yearBonus, 25)  // 最多25%
        
        let random = Int.random(in: 1...100)
        return random <= finalProbability
    }
    
    // ============================================================
    // MARK: - 处理事件选择（⚠️ 修复版：解决 Toast 显示问题）
    // ============================================================
    func handleEventChoice(option: EventOption) {
        guard let event = currentEvent else { return }
        
        // ✅ 第1步：先关闭弹窗
        currentEvent = nil
        
        // ✅ 第2步：延迟 0.35 秒后显示 Toast（等弹窗淡出动画完成）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            
            // 显示Toast消息（即时反馈）
            self.toastMessage = ToastMessage(text: option.toastText)
            
            // 3秒后自动消失Toast
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.toastMessage = nil
            }
        }
        
        // ✅ 第3步：如果有日志文案，写入日志（自动添加季节和年份）
        if let logText = option.logText, !logText.isEmpty {
            let fullLogText = "\(currentSeason.rawValue) · 第\(currentYear)年｜\(logText)"
            let log = GameLog(
                season: currentSeason,
                year: currentYear,
                content: fullLogText
            )
            logs.insert(log, at: 0)  // 最新的日志在前面
        }
        
        // ✅ 第4步：如果是危急事件，检查是否游戏结束
        if event.type == .critical {
            // 根据日志文案判断是否游戏结束
            if let logText = option.logText, !logText.isEmpty {
                if logText.contains("身亡") || logText.contains("不幸身亡") || logText.contains("遇刺身亡") {
                    endingType = .assassination
                    gameState = .ended
                    eventTimer?.invalidate()
                    eventTimer = nil
                } else if logText.contains("覆灭") || logText.contains("谋反成功") || logText.contains("王朝覆灭") {
                    endingType = .rebellion
                    gameState = .ended
                    eventTimer?.invalidate()
                    eventTimer = nil
                }
            } else {
                // 如果没有日志文案，根据描述和选项判断
                if event.description.contains("遇刺") || event.description.contains("刺杀") {
                    // 遇刺事件：根据选项判断是否死亡
                    if option.text.contains("身亡") || option.toastText.contains("身亡") {
                        endingType = .assassination
                        gameState = .ended
                        eventTimer?.invalidate()
                        eventTimer = nil
                    }
                } else if event.description.contains("谋反") {
                    // 谋反事件：根据选项判断是否成功
                    if option.text.contains("成功") || option.text.contains("覆灭") || option.toastText.contains("覆灭") {
                        endingType = .rebellion
                        gameState = .ended
                        eventTimer?.invalidate()
                        eventTimer = nil
                    }
                }
            }
        }
        
        // ✅ 第5步：如果不是结局事件，继续安排下一个随机事件
        if gameState == .playing {
            scheduleRandomEvent()
        }
    }
    
    // MARK: - 下一回合
    func nextRound() {
        // 推进回合
        currentRound += 1
        
        // 根据回合数确定季节：1=春，2=夏，3=秋，4=冬，然后循环
        let seasonIndex = (currentRound - 1) % 4
        switch seasonIndex {
        case 0:
            currentSeason = .spring
        case 1:
            currentSeason = .summer
        case 2:
            currentSeason = .autumn
        case 3:
            currentSeason = .winter
        default:
            currentSeason = .spring
        }
        
        // 每4回合（一年）年龄+1，年份+1
        if currentRound > 1 && (currentRound - 1) % 4 == 0 && emperor != nil {
            emperor!.age += 1
            emperor!.yearInPower += 1
            
            // 新一年的日志（可选，根据需求）
            // let yearLog = GameLog(
            //     season: currentSeason,
            //     year: currentYear,
            //     content: "第\(currentYear)年开始"
            // )
            // logs.insert(yearLog, at: 0)
        }
        
        // 更新皇帝在位年数（根据当前年份）
        if emperor != nil {
            emperor!.yearInPower = currentYear
        }
        
        // 取消当前定时器，重新安排事件
        eventTimer?.invalidate()
        scheduleRandomEvent()
    }
    
    // MARK: - 主动退位
    func abdicate() {
        endingType = .abdication
        gameState = .ended
        
        // 停止事件定时器
        eventTimer?.invalidate()
        eventTimer = nil
        
        let log = GameLog(
            season: currentSeason,
            year: currentYear,
            content: "\(currentSeason.rawValue) · 第\(currentYear)年｜皇帝决定退位让贤"
        )
        logs.insert(log, at: 0)
    }
    
    // MARK: - 重新开始
    func restart() {
        startNewGame()
    }
    
    // MARK: - 翻看日志
    func showLogsView() {
        showingLogsView = true
    }
    
    // MARK: - 关闭日志视图
    func hideLogsView() {
        showingLogsView = false
    }
    
    deinit {
        eventTimer?.invalidate()
    }
}
