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

// MARK: - 四类属性标签枚举
enum NationalStatus: String, Codable, CaseIterable {
    case prosperous = "国泰民安"
    case uncertain = "风云未定"
    case turbulent = "风雨飘摇"
}

enum ResourceStatus: String, Codable, CaseIterable {
    case abundant = "国库充盈"
    case balanced = "收支平衡"
    case deficit = "国库亏空"
}

enum CourtStatus: String, Codable, CaseIterable {
    case harmonious = "和睦"
    case ripple = "微澜"
    case turmoil = "风波"
}

enum HeirStatus: String, Codable, CaseIterable {
    case excellent = "优秀"
    case adequate = "尚可"
    case none = "无"
}

// MARK: - 六维属性
struct EmperorAttributes: Codable {
    var mood: Double
    var intelligence: Double
    var charm: Double
    var reputation: Double
    var popularity: Double
    var morality: Double
    
    init(mood: Double = 0.5,
         intelligence: Double = 0.5,
         charm: Double = 0.5,
         reputation: Double = 0.5,
         popularity: Double = 0.5,
         morality: Double = 0.5) {
        self.mood = mood
        self.intelligence = intelligence
        self.charm = charm
        self.reputation = reputation
        self.popularity = popularity
        self.morality = morality
    }
}

// MARK: - 态度类型
enum AttitudeType: String, Codable {
    case strong = "强硬"
    case balanced = "权衡"
    case lenient = "宽纵"
    case selfish = "私心"
}

// MARK: - 事件来源（事件池）
enum EventSource: String, Codable, CaseIterable {
    case frontCourt = "前朝政务"
    case courtPersonnel = "宫廷人事"
    case harem = "后宫事务"
    case publicOpinion = "世情风向"
    
    var eventType: EventType {
        switch self {
        case .frontCourt: return .frontCourt
        case .courtPersonnel: return .palace
        case .harem: return .harem
        case .publicOpinion: return .palace
        }
    }
    
    var color: (red: Double, green: Double, blue: Double) {
        switch self {
        case .frontCourt: return (0.53, 0.7, 0.88)      // 蓝色
        case .courtPersonnel: return (0.88, 0.77, 0.53)  // 黄色
        case .harem: return (0.88, 0.52, 0.66)          // 玫红色
        case .publicOpinion: return (0.45, 0.69, 0.52)  // 绿色
        }
    }
}

// MARK: - 属性变化
struct AttributeChanges: Codable {
    var mood: Double
    var intelligence: Double
    var charm: Double
    var reputation: Double
    var popularity: Double
    var morality: Double
    
    init(mood: Double = 0.0,
         intelligence: Double = 0.0,
         charm: Double = 0.0,
         reputation: Double = 0.0,
         popularity: Double = 0.0,
         morality: Double = 0.0) {
        self.mood = mood
        self.intelligence = intelligence
        self.charm = charm
        self.reputation = reputation
        self.popularity = popularity
        self.morality = morality
    }
}

// MARK: - 记忆片段
struct MemoryFragment: Identifiable, Codable {
    var id: UUID
    var speaker: String
    var content: String
    
    init(id: UUID = UUID(), speaker: String, content: String) {
        self.id = id
        self.speaker = speaker
        self.content = content
    }
}

// MARK: - 皇帝模型
struct Emperor: Identifiable, Codable {
    var id: UUID
    var name: String
    var age: Int
    var dynastyStatus: DynastyStatus
    var yearInPower: Int
    var reignTitle: String
    var nationalStatus: NationalStatus
    var resourceStatus: ResourceStatus
    var courtStatus: CourtStatus
    var heirStatus: HeirStatus
    var attributes: EmperorAttributes
    
    init(id: UUID = UUID(),
         name: String,
         age: Int,
         dynastyStatus: DynastyStatus,
         yearInPower: Int = 1,
         reignTitle: String = "",
         nationalStatus: NationalStatus = .prosperous,
         resourceStatus: ResourceStatus = .balanced,
         courtStatus: CourtStatus = .harmonious,
         heirStatus: HeirStatus = .adequate,
         attributes: EmperorAttributes = EmperorAttributes()) {
        self.id = id
        self.name = name
        self.age = age
        self.dynastyStatus = dynastyStatus
        self.yearInPower = yearInPower
        self.reignTitle = reignTitle
        self.nationalStatus = nationalStatus
        self.resourceStatus = resourceStatus
        self.courtStatus = courtStatus
        self.heirStatus = heirStatus
        self.attributes = attributes
    }
    
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
    case frontCourt = "🏛️前朝事件"
    case palace = "⛲️宫廷事件"
    case harem = "🏮后宫事件"
    case critical = "⚠️危急事件"
}

// MARK: - 事件选项
struct EventOption: Identifiable, Codable {
    var id: UUID
    var text: String
    var toastText: String
    var logText: String?
    var attitude: AttitudeType?
    var attributeChanges: AttributeChanges?
    
    init(id: UUID = UUID(),
         text: String,
         toastText: String,
         logText: String? = nil,
         attitude: AttitudeType? = nil,
         attributeChanges: AttributeChanges? = nil) {
        self.id = id
        self.text = text
        self.toastText = toastText
        self.logText = logText
        self.attitude = attitude
        self.attributeChanges = attributeChanges
    }
}

// MARK: - 事件模型
struct GameEvent: Identifiable, Codable {
    var id: UUID
    var title: String
    var type: EventType
    var description: String
    var options: [EventOption]
    var source: EventSource
    
    init(id: UUID = UUID(),
         title: String,
         type: EventType,
         description: String,
         options: [EventOption],
         source: EventSource = .frontCourt) {
        self.id = id
        self.title = title
        self.type = type
        self.description = description
        self.options = options
        self.source = source
    }
}

// MARK: - 日志模型
struct GameLog: Identifiable, Codable {
    let id: UUID
    var season: Season
    var year: Int
    var content: String
    var timestamp: Date
    
    init(id: UUID = UUID(),
         season: Season,
         year: Int,
         content: String,
         timestamp: Date = Date()) {
        self.id = id
        self.season = season
        self.year = year
        self.content = content
        self.timestamp = timestamp
    }
}

// MARK: - 游戏状态
enum GameState: Codable {
    case emperorConfirm
    case playing
    case ended
}

// MARK: - 游戏结局类型
enum EndingType: String, Codable {
    case naturalEnd = "自然终点"
    case collapse = "状态坍塌"
    case sudden = "突发终结"
    case abdication = "退位"
}

// MARK: - 坍塌原因
enum CollapseReason: String, Codable {
    case mood = "心情"
    case intelligence = "才智"
    case charm = "魅力"
    case reputation = "声望"
    case popularity = "民心"
    case morality = "道德"
}

// MARK: - 突发原因
enum SuddenReason: String, Codable {
    case assassination = "遇刺"
    case rebellion = "谋反"
}

// MARK: - Toast消息模型
struct ToastMessage: Identifiable, Codable {
    let id: UUID
    var text: String
    var timestamp: Date
    
    init(id: UUID = UUID(), text: String, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
    }
}
