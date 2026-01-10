//
//  Models.swift
//  gongtingrizhi
//
//  Created by 朱荣 on 2026/1/10.
//

import Foundation

// MARK: - 王朝状态枚举
enum DynastyStatus: String, Codable {
    case prosperity = "盛世"      // 盛世
    case stable = "稳定"          // 稳定
    case unstable = "飘摇"        // 飘摇（标红）
    
    var isUnstable: Bool {
        return self == .unstable
    }
}

// MARK: - 皇帝模型
struct Emperor: Identifiable, Codable {
    let id = UUID()
    var name: String            // 姓名
    var age: Int                // 年龄（18-40随机）
    var dynastyStatus: DynastyStatus  // 王朝状态
    var yearInPower: Int = 1    // 在位年数
    var reignTitle: String = "" // 年号（用于显示）
    
    // 固定称号
    var title: String {
        return "生于紫室"
    }
}

// MARK: - 季节枚举
enum Season: String, CaseIterable, Codable {
    case spring = "春"
    case summer = "夏"
    case autumn = "秋"
    case winter = "冬"
    
    var next: Season {
        switch self {
        case .spring: return .summer
        case .summer: return .autumn
        case .autumn: return .winter
        case .winter: return .spring
        }
    }
}

// MARK: - 事件类型枚举
enum EventType: String, Codable {
    case frontCourt = "前朝事件"     // 前朝事件
    case palace = "宫廷事件"         // 宫廷事件
    case harem = "后宫事件"          // 后宫事件
    case critical = "危急事件"       // 危急事件（低概率）
}

// MARK: - 事件选项
struct EventOption: Identifiable, Codable {
    let id = UUID()
    var text: String           // 选项文本
    var toastText: String      // Toast文案（即时反馈，必填）
    var logText: String?       // 日志文案（可选，用于记录历史）
}

// MARK: - 事件模型
struct GameEvent: Identifiable, Codable {
    let id = UUID()
    var title: String          // 事件标题
    var type: EventType        // 事件类型
    var description: String    // 事件描述
    var options: [EventOption] // 选项列表（2个）
}

// MARK: - 日志模型
struct GameLog: Identifiable, Codable {
    let id = UUID()
    var season: Season
    var year: Int
    var content: String     // 日志内容
    var timestamp: Date = Date()
}

// MARK: - 游戏状态
enum GameState: Codable {
    case emperorConfirm      // 皇帝信息确认页
    case playing            // 游戏中
    case ended              // 游戏结束
}

// MARK: - 游戏结局类型
enum EndingType: String, Codable {
    case abdication = "退位"              // 主动退位
    case assassination = "遇刺身亡"       // 遇刺身亡
    case rebellion = "谋反成功"           // 谋反成功
}

// MARK: - Toast消息模型
struct ToastMessage: Identifiable, Codable {
    let id = UUID()
    var text: String
    var timestamp: Date = Date()
}
