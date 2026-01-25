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

// MARK: - 六维属性（包含体力）
struct EmperorAttributes: Codable {
    var stamina: Double = 100.0  // 体力（0-100）
    var mood: Double
    var intelligence: Double
    var charm: Double
    var reputation: Double
    var popularity: Double
    var morality: Double
    
    init(stamina: Double = 100.0,
         mood: Double = 0.5,
         intelligence: Double = 0.5,
         charm: Double = 0.5,
         reputation: Double = 0.5,
         popularity: Double = 0.5,
         morality: Double = 0.5) {
        self.stamina = stamina
        self.mood = mood
        self.intelligence = intelligence
        self.charm = charm
        self.reputation = reputation
        self.popularity = popularity
        self.morality = morality
    }
}

// MARK: - 皇帝特质标签
enum EmperorTrait: String, Codable, CaseIterable {
    case suspicious = "性情多疑"
    case diligent = "勤于政务"
    case softEared = "耳根偏软"
    case decisive = "果断决断"
    case lenient = "宽厚仁慈"
    case strict = "严苛律己"
    
    var description: String {
        switch self {
        case .suspicious: return "对他人保持警惕，容易怀疑"
        case .diligent: return "勤于处理政务，不辞辛劳"
        case .softEared: return "容易被他人意见影响"
        case .decisive: return "决策果断，不拖泥带水"
        case .lenient: return "待人宽厚，仁慈为怀"
        case .strict: return "对自己和他人要求严格"
        }
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
    case frontCourt = "🏛️前朝政务"
    case courtPersonnel = "⛲️宫廷人事"
    case harem = "💘后宫事务"
    case publicOpinion = "🍃世情风向"
    
    // 事件分类（用于本月事件列表）- 显示大的类型
    // 根据需求文档：朝政、军务、民间、后宫、宫廷
    var categoryName: String {
        switch self {
        case .frontCourt: return "朝政"  // 对应事件题材：户部、吏部、御史
        case .courtPersonnel: return "军务"  // 对应事件题材：将军、边关（根据departmentTag判断）
        case .harem: return "后宫"  // 对应事件题材：妃子、皇嗣、内廷
        case .publicOpinion: return "民间"  // 对应事件题材：灾荒、民变、奇闻
        }
    }
    
    // 事件部门标签（用于事件列表显示，但不在UI中显示，只用于内部逻辑）
    var departmentTag: String {
        switch self {
        case .frontCourt: return ["户部", "吏部", "御史"].randomElement() ?? "户部"
        case .courtPersonnel: return ["将军", "边关"].randomElement() ?? "将军"
        case .harem: return ["妃子", "皇嗣", "内廷"].randomElement() ?? "内廷"
        case .publicOpinion: return ["灾荒", "民变", "奇闻"].randomElement() ?? "民间"
        }
    }
    
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

// MARK: - 属性变化（包含体力）
struct AttributeChanges: Codable {
    var stamina: Double = 0.0  // 体力变化（0-100范围）
    var mood: Double = 0.0
    var intelligence: Double = 0.0
    var charm: Double = 0.0
    var reputation: Double = 0.0
    var popularity: Double = 0.0
    var morality: Double = 0.0
    
    // 默认初始化方法（所有参数都有默认值）
    init() {
        self.stamina = 0.0
        self.mood = 0.0
        self.intelligence = 0.0
        self.charm = 0.0
        self.reputation = 0.0
        self.popularity = 0.0
        self.morality = 0.0
    }
    
    // 兼容旧代码的初始化方法（不包含stamina）
    init(mood: Double = 0.0,
         intelligence: Double = 0.0,
         charm: Double = 0.0,
         reputation: Double = 0.0,
         popularity: Double = 0.0,
         morality: Double = 0.0) {
        self.stamina = 0.0
        self.mood = mood
        self.intelligence = intelligence
        self.charm = charm
        self.reputation = reputation
        self.popularity = popularity
        self.morality = morality
    }
    
    // 完整初始化方法（包含stamina）
    init(stamina: Double = 0.0,
         mood: Double = 0.0,
         intelligence: Double = 0.0,
         charm: Double = 0.0,
         reputation: Double = 0.0,
         popularity: Double = 0.0,
         morality: Double = 0.0) {
        self.stamina = stamina
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
    var monthInYear: Int  // 当前月份（1-12）
    var reignTitle: String
    var nationalStatus: NationalStatus
    var resourceStatus: ResourceStatus
    var courtStatus: CourtStatus
    var heirStatus: HeirStatus
    var attributes: EmperorAttributes
    var traits: [EmperorTrait]  // 皇帝特质标签（2-3个）
    
    init(id: UUID = UUID(),
         name: String,
         age: Int,
         dynastyStatus: DynastyStatus,
         yearInPower: Int = 1,
         monthInYear: Int = 1,
         reignTitle: String = "",
         nationalStatus: NationalStatus = .prosperous,
         resourceStatus: ResourceStatus = .balanced,
         courtStatus: CourtStatus = .harmonious,
         heirStatus: HeirStatus = .adequate,
         attributes: EmperorAttributes = EmperorAttributes(),
         traits: [EmperorTrait] = []) {
        self.id = id
        self.name = name
        self.age = age
        self.dynastyStatus = dynastyStatus
        self.yearInPower = yearInPower
        self.monthInYear = monthInYear
        self.reignTitle = reignTitle
        self.nationalStatus = nationalStatus
        self.resourceStatus = resourceStatus
        self.courtStatus = courtStatus
        self.heirStatus = heirStatus
        self.attributes = attributes
        self.traits = traits
    }
    
    var title: String {
        return "生于紫室"
    }
}

// MARK: - 月份枚举（1-12月）
enum Month: Int, CaseIterable, Codable {
    case january = 1
    case february = 2
    case march = 3
    case april = 4
    case may = 5
    case june = 6
    case july = 7
    case august = 8
    case september = 9
    case october = 10
    case november = 11
    case december = 12
    
    var name: String {
        let names = ["正月", "二月", "三月", "四月", "五月", "六月", 
                    "七月", "八月", "九月", "十月", "十一月", "十二月"]
        return names[self.rawValue - 1]
    }
    
    var next: Month {
        if self == .december {
            return .january
        }
        return Month(rawValue: self.rawValue + 1) ?? .january
    }
}

// MARK: - 季节枚举（保留用于兼容）
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
    case frontCourt = "前朝事件"
    case palace = "宫廷事件"
    case harem = "后宫事件"
    case critical = "突发事件"
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
    var isProcessed: Bool = false  // 是否已处理
    var feedbackText: String?  // 处理后的反馈文案
    var stage: GameStage?  // 事件所属阶段
    var isSystemEvent: Bool = false  // 是否为系统事件（系统事件选择选项后直接关闭，无"下一件"按钮）
    
    init(id: UUID = UUID(),
         title: String,
         type: EventType,
         description: String,
         options: [EventOption],
         source: EventSource = .frontCourt,
         isProcessed: Bool = false,
         feedbackText: String? = nil,
         stage: GameStage? = nil,
         isSystemEvent: Bool = false) {
        self.id = id
        self.title = title
        self.type = type
        self.description = description
        self.options = options
        self.source = source
        self.isProcessed = isProcessed
        self.feedbackText = feedbackText
        self.stage = stage
        self.isSystemEvent = isSystemEvent
    }
}

// MARK: - 游戏阶段（用于事件池）
enum GameStage: String, Codable {
    case earlyReign = "初登基"  // 1-12月
    case stable = "稳定期"      // 第2-5年
    case midLate = "中后期"     // 第6年+
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

// MARK: - 后宫成员模型
struct HaremMember: Identifiable, Codable {
    var id: UUID
    var name: String
    var rank: HaremRank  // 位分
    var age: Int
    var influence: Int  // 势力（0-100）
    var affection: Int  // 好感度（0-100）
    var children: Int  // 子嗣数量
    var traits: [HaremTrait]  // 标签（1-2个）
    var healthStatus: HealthStatus?  // 健康状态（正常时不显示）
    var pregnancyMonth: Int?  // 怀孕月份（从1开始计数，9个月后生产）
    
    init(id: UUID = UUID(),
         name: String,
         rank: HaremRank,
         age: Int,
         influence: Int = 50,
         affection: Int = 50,
         children: Int = 0,
         traits: [HaremTrait] = [],
         healthStatus: HealthStatus? = nil,
         pregnancyMonth: Int? = nil) {
        self.id = id
        self.name = name
        self.rank = rank
        self.age = age
        self.influence = influence
        self.affection = affection
        self.children = children
        self.traits = traits
        self.healthStatus = healthStatus
        self.pregnancyMonth = pregnancyMonth
    }
}

// MARK: - 后宫位分
enum HaremRank: String, Codable, CaseIterable {
    case empress = "皇后"
    case nobleConsort = "贵妃"
    case consort = "妃"
    case concubine = "嫔"
    case nobleLady = "贵人"
}

// MARK: - 后宫标签
enum HaremTrait: String, Codable, CaseIterable {
    // 容貌类
    case beautiful = "清丽可人"
    case iceSnow = "玉骨冰肌"
    case stunning = "倾城之姿"
    case peerless = "风华绝世"
    
    // 性情类
    case dignified = "端庄"
    case aloof = "高冷"
    case gentle = "温柔"
    case clever = "聪慧"
    case dependent = "依赖"
    
    // 才干类
    case learned = "学识渊博"
    case medical = "医术高明"
    case teaMaster = "端茶大师"
}

// MARK: - 健康状态
enum HealthStatus: String, Codable {
    case sick = "生病"
    case pregnant = "孕"
}

// MARK: - 皇嗣模型
struct Heir: Identifiable, Codable {
    var id: UUID
    var name: String
    var gender: Gender
    var age: Int
    var looks: Int  // 颜值（0-100）
    var ability: Int  // 能力（0-100）
    var influence: Int  // 影响力（0-100）
    var motherName: String  // 生母名字
    var traits: [HeirTrait]  // 标签（1-2个）
    var isCrownPrince: Bool = false  // 是否为储君
    
    init(id: UUID = UUID(),
         name: String,
         gender: Gender,
         age: Int = 0,
         looks: Int = 50,
         ability: Int = 50,
         influence: Int = 50,
         motherName: String,
         traits: [HeirTrait] = [],
         isCrownPrince: Bool = false) {
        self.id = id
        self.name = name
        self.gender = gender
        self.age = age
        self.looks = looks
        self.ability = ability
        self.influence = influence
        self.motherName = motherName
        self.traits = traits
        self.isCrownPrince = isCrownPrince
    }
}

// MARK: - 性别
enum Gender: String, Codable {
    case male = "皇子"
    case female = "公主"
}

// MARK: - 皇嗣标签
enum HeirTrait: String, Codable, CaseIterable {
    case intelligent = "聪敏"
    case sickly = "多病"
    case handsome = "俊美"
    case talented = "天赋异禀"
}
