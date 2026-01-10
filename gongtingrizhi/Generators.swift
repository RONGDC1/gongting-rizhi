//
//  Generators.swift
//  gongtingrizhi
//
//  Created by 朱荣 on 2026/1/10.
//

import Foundation

// MARK: - 名字生成器
class NameGenerator {
    private let emperorSurnames = ["李", "赵", "刘", "陈", "杨", "朱", "周", "吴", "徐", "孙", "沈", "王", "张"]
    private let emperorGivenNames = ["世民", "元昊", "光启", "建文", "永乐", "嘉靖", "康熙", "雍正", "乾隆", "嘉庆", "翊钧", "承乾", "显宗"]
    
    func generateEmperorName() -> String {
        let surname = emperorSurnames.randomElement() ?? "李"
        let givenName = emperorGivenNames.randomElement() ?? "世民"
        return surname + givenName
    }
}

// MARK: - 事件生成器
class EventGenerator {
    private let nameGenerator = NameGenerator()
    
    // MARK: - 生成事件（根据类型）
    func generateEvent(type: EventType) -> GameEvent {
        switch type {
        case .frontCourt:
            return generateFrontCourtEvent()
        case .palace:
            return generatePalaceEvent()
        case .harem:
            return generateHaremEvent()
        case .critical:
            return generateCriticalEvent()
        }
    }
    
    // MARK: - 生成前朝事件
    func generateFrontCourtEvent() -> GameEvent {
        let events: [(title: String, description: String, options: [EventOption])] = [
            (
                title: "前朝事件",
                description: "丞相上奏：'陛下，今年北方大旱，百姓颗粒无收，请陛下开仓放粮，救济灾民。'",
                options: [
                    EventOption(text: "立即开仓放粮", toastText: "皇帝下令开仓，灾民感激涕零", logText: "因丞相的请求，皇帝决定立即开仓放粮，救济灾民"),
                    EventOption(text: "先调查再决定", toastText: "皇帝派遣钦差前往调查", logText: "因丞相的请求，皇帝决定先派遣官员调查灾情再作决定")
                ]
            ),
            (
                title: "前朝事件",
                description: "兵部尚书禀报：'陛下，边境传来急报，邻国军队在边境集结，意图不明。'",
                options: [
                    EventOption(text: "增派兵马防御", toastText: "边境兵马调动，军心大振", logText: "因兵部尚书的禀报，皇帝决定增派兵马加强边境防御"),
                    EventOption(text: "派遣使者交涉", toastText: "使者快马加鞭前往邻国", logText: "因兵部尚书的禀报，皇帝决定派遣使者前往邻国交涉")
                ]
            ),
            (
                title: "前朝事件",
                description: "户部尚书奏报：'陛下，今年国库充盈，建议减免部分赋税，以安民心。'",
                options: [
                    EventOption(text: "减免赋税", toastText: "百姓闻讯欢呼，民心大悦", logText: "因户部尚书的建议，皇帝决定减免赋税，民心大悦"),
                    EventOption(text: "保持现状", toastText: "国库继续充盈，以备不时之需", logText: "因户部尚书的建议，皇帝权衡后决定保持现有赋税政策")
                ]
            ),
            (
                title: "前朝事件",
                description: "御史大夫弹劾某位官员贪污受贿，请求陛下严惩。",
                options: [
                    EventOption(text: "严惩不贷", toastText: "贪官被罢黜，朝野震动", logText: "因御史大夫的弹劾，皇帝决定严惩贪官，以正朝纲"),
                    EventOption(text: "调查后再定", toastText: "皇帝下令彻查此事", logText: "因御史大夫的弹劾，皇帝决定先调查真相再做决定")
                ]
            ),
            (
                title: "前朝事件",
                description: "大臣呈上边疆军情，皇帝虚心纳谏，边疆暂稳。",
                options: [
                    EventOption(text: "采纳建议", toastText: "皇帝采纳建议，边疆暂稳", logText: "大臣呈上边疆军情，皇帝虚心纳谏，边疆暂稳"),
                    EventOption(text: "自行决断", toastText: "皇帝深思后作出决断", logText: nil)
                ]
            )
        ]
        
        let selected = events.randomElement()!
        return GameEvent(
            title: selected.title,
            type: .frontCourt,
            description: selected.description,
            options: selected.options
        )
    }
    
    // MARK: - 生成宫廷事件
    func generatePalaceEvent() -> GameEvent {
        let events: [(title: String, description: String, options: [EventOption])] = [
            (
                title: "宫廷事件",
                description: "宫中御养的橘猫忽然不见了，宫人低声议论，说它昨夜还在御书房附近出没。今日一早，几位内侍在殿外候着，请示是否要继续寻找？",
                options: [
                    EventOption(text: "它自己会回来的", toastText: "皇帝命人备下鱼干，御猫当夜悄然现身", logText: nil),
                    EventOption(text: "所有人都去找", toastText: "宫中上下寻找御猫，最终还是找到了", logText: nil)
                ]
            ),
            (
                title: "宫廷事件",
                description: "宫中举办中秋佳节，皇后提议大宴群臣，与民同乐。",
                options: [
                    EventOption(text: "举办盛宴", toastText: "宫中张灯结彩，中秋盛宴如期举行", logText: "因宫廷盛典，皇帝决定举办中秋盛宴，与民同乐"),
                    EventOption(text: "简单庆祝", toastText: "宫中简单庆祝，避免铺张", logText: nil)
                ]
            ),
            (
                title: "宫廷事件",
                description: "宫中御花园的牡丹花盛开了，皇后邀请皇帝一同赏花。",
                options: [
                    EventOption(text: "欣然前往", toastText: "皇帝与皇后在花园中漫步赏花", logText: nil),
                    EventOption(text: "政务繁忙", toastText: "皇帝忙于政务，未能前去", logText: nil)
                ]
            ),
            (
                title: "宫廷事件",
                description: "宫中传来消息，某位老太监病重，请求见皇帝最后一面。",
                options: [
                    EventOption(text: "前往探望", toastText: "皇帝前往探望，老太监感激涕零", logText: "因宫中旧事，皇帝前往探望病重的老太监，体现仁慈"),
                    EventOption(text: "派人慰问", toastText: "皇帝派人代为慰问", logText: nil)
                ]
            ),
            (
                title: "宫廷事件",
                description: "宫中御厨研制出新菜品，想要献给皇帝品尝。",
                options: [
                    EventOption(text: "品尝新菜", toastText: "皇帝品尝后龙颜大悦，赏赐御厨", logText: nil),
                    EventOption(text: "稍后再尝", toastText: "皇帝决定稍后再品尝", logText: nil)
                ]
            ),
            (
                title: "宫廷事件",
                description: "预算报告提交，皇帝拒绝预算，大臣皱眉。",
                options: [
                    EventOption(text: "重新考虑", toastText: "皇帝重新审视预算报告", logText: "预算报告提交，皇帝重新考虑后批准"),
                    EventOption(text: "维持原判", toastText: "皇帝维持原决定", logText: nil)
                ]
            )
        ]
        
        let selected = events.randomElement()!
        return GameEvent(
            title: selected.title,
            type: .palace,
            description: selected.description,
            options: selected.options
        )
    }
    
    // MARK: - 生成后宫事件
    func generateHaremEvent() -> GameEvent {
        let events: [(title: String, description: String, options: [EventOption])] = [
            (
                title: "后宫事件",
                description: "宫中传来小妃请求，皇帝未作理会...",
                options: [
                    EventOption(text: "前往查看", toastText: "皇帝前往后宫，了解妃子请求", logText: nil),
                    EventOption(text: "继续不理", toastText: "皇帝专注于政务，未作理会", logText: nil)
                ]
            ),
            (
                title: "后宫事件",
                description: "某位妃子向皇帝哭诉，称自己受到其他妃子的排挤，请求皇帝做主。",
                options: [
                    EventOption(text: "安抚妃子", toastText: "皇帝安抚妃子，承诺会处理此事", logText: "因妃子的哭诉，皇帝安抚妃子并承诺会处理此事"),
                    EventOption(text: "调查情况", toastText: "皇帝下令调查后宫情况", logText: nil)
                ]
            ),
            (
                title: "后宫事件",
                description: "某位妃子亲自下厨，为皇帝准备了精致的点心，请求皇帝品尝。",
                options: [
                    EventOption(text: "品尝点心", toastText: "皇帝品尝点心，称赞妃子手艺", logText: nil),
                    EventOption(text: "稍后品尝", toastText: "皇帝决定稍后再品尝", logText: nil)
                ]
            ),
            (
                title: "后宫事件",
                description: "妃子们希望能在宫中举办一场诗词会，邀请皇帝一同参与。",
                options: [
                    EventOption(text: "批准举办", toastText: "宫中举办诗词会，妃子们吟诗作对", logText: "因妃子们的请求，皇帝批准举办诗词会"),
                    EventOption(text: "改日再议", toastText: "皇帝决定改日再议", logText: nil)
                ]
            ),
            (
                title: "后宫事件",
                description: "某位妃子为皇帝准备了一支新舞，希望能在宫中献舞。",
                options: [
                    EventOption(text: "观看献舞", toastText: "皇帝观看妃子献舞，龙心大悦", logText: nil),
                    EventOption(text: "改日观看", toastText: "皇帝决定改日观看", logText: nil)
                ]
            )
        ]
        
        let selected = events.randomElement()!
        return GameEvent(
            title: selected.title,
            type: .harem,
            description: selected.description,
            options: selected.options
        )
    }
    
    // MARK: - 生成危急事件
    func generateCriticalEvent() -> GameEvent {
        let events: [(title: String, description: String, options: [EventOption])] = [
            (
                title: "危急事件",
                description: "深夜，皇帝在寝宫中就寝。突然，一名刺客潜入宫中，意图行刺！",
                options: [
                    EventOption(text: "奋力抵抗", toastText: "禁卫及时赶到，刺客被擒", logText: "深夜遇刺，皇帝奋力抵抗，禁卫及时赶到救驾"),
                    EventOption(text: "呼救禁卫", toastText: "皇帝遇刺身亡", logText: "因遇刺事件，皇帝呼救禁卫但为时已晚，不幸身亡")
                ]
            ),
            (
                title: "危急事件",
                description: "皇帝在御花园散步时，突然从暗处射来一支毒箭！",
                options: [
                    EventOption(text: "躲避不及", toastText: "皇帝中箭，虽经抢救但仍不幸身亡", logText: "因遇刺事件，皇帝躲避不及，不幸中箭身亡"),
                    EventOption(text: "禁卫护驾", toastText: "禁卫以身挡箭，皇帝幸免于难", logText: "遇刺事件，禁卫舍身护驾，皇帝幸免于难")
                ]
            ),
            (
                title: "危急事件",
                description: "边关传来急报：有将领密谋造反，意图推翻朝廷！",
                options: [
                    EventOption(text: "派兵镇压", toastText: "朝廷派兵镇压，谋反被平息", logText: "边关谋反，皇帝派兵镇压，叛乱被平息"),
                    EventOption(text: "招安安抚", toastText: "谋反成功，王朝覆灭", logText: "边关谋反，皇帝招安失败，谋反成功，王朝覆灭")
                ]
            )
        ]
        
        let selected = events.randomElement()!
        return GameEvent(
            title: selected.title,
            type: .critical,
            description: selected.description,
            options: selected.options
        )
    }
}
