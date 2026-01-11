//
//  Generators.swift
//  gongtingrizhi
//
//  Created by 朱荣 on 2026/1/10.
//

import Foundation

// MARK: - 名字生成器
class NameGenerator {
    private let emperorSurnames = ["赵", "刘", "宇文", "杨", "朱", "景", "凌", "拓跋", "沈", "钟离"]
    private let emperorGivenNames = ["世乾", "元灏", "光文", "建平", "延", "衡", "熙", "尘山", "澈", "翊钧", "景玺", "瑞"]
    
    func generateEmperorName() -> String {
        let surname = emperorSurnames.randomElement() ?? "景"
        let givenName = emperorGivenNames.randomElement() ?? "延"
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
                title: "🏛️前朝",
                description: "丞相上奏：陛下，今年北方大旱，百姓颗粒无收，请陛下开仓放粮，救济灾民。",
                options: [
                    EventOption(text: "立即开仓放粮", toastText: "皇帝下令开仓，灾民感激涕零", logText: "因丞相的请求，皇帝决定立即开仓放粮，救济灾民"),
                    EventOption(text: "先调查再决定", toastText: "皇帝派遣钦差前往调查", logText: "因丞相的请求，皇帝决定先派遣官员调查灾情再作决定")
                ]
            ),
            (
                title: "🏛️前朝",
                description: "兵部尚书禀报：陛下，边境传来急报，邻国军队在边境集结，意图不明。",
                options: [
                    EventOption(text: "增派兵马防御", toastText: "边境兵马调动，军心大振", logText: "因兵部尚书的禀报，皇帝决定增派兵马加强边境防御"),
                    EventOption(text: "派遣使者交涉", toastText: "使者快马加鞭前往邻国", logText: "因兵部尚书的禀报，皇帝决定派遣使者前往邻国交涉")
                ]
            ),
            (
                title: "🏛️前朝",
                description: "户部尚书奏报：陛下，今年国库充盈，建议减免部分赋税，以安民心。",
                options: [
                    EventOption(text: "减免赋税", toastText: "百姓闻讯欢呼，民心大悦😊", logText: "因户部尚书的建议，皇帝决定减免赋税，民心大悦"),
                    EventOption(text: "保持现状", toastText: "国库继续充盈，以备不时之需", logText: "因户部尚书的建议，皇帝权衡后决定保持现有赋税政策")
                ]
            ),
            (
                title: "🏛️前朝",
                description: "御史大夫弹劾某位官员贪污受贿，请求陛下严惩！！😡",
                options: [
                    EventOption(text: "严惩不贷", toastText: "贪官被罢黜，朝野震动", logText: "因御史大夫的弹劾，皇帝决定严惩贪官，以正朝纲"),
                    EventOption(text: "调查后再定", toastText: "皇帝下令彻查此事", logText: "因御史大夫的弹劾，皇帝决定先调查真相再做决定")
                ]
            ),
            (
                title: "🏛️前朝",
                description: "大臣呈上边疆军情，皇帝虚心纳谏，边疆暂稳～😌",
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
                title: "⛲️宫廷",
                description: "宫中御养的橘猫不见了，宫人低声议论，说它昨夜还在御书房附近出没。今日一早，几位内侍在殿外小心翼翼地候着...",
                options: [
                    EventOption(text: "不用管，它自己会回来的", toastText: "皇帝命人备下鱼干🐟，御猫当夜悄然现身～", logText: nil),
                    EventOption(text: "找不到，杖责五十大板！", toastText: "那么凶，奴才们被你吓死了😰", logText: nil)
                ]
            ),
            (
                title: "⛲️宫廷",
                description: "中秋佳节临近，宫中灯火初上，皇后提议设宴群臣，共赏明月🌕，彰显皇室恩德。",
                options: [
                    EventOption(text: "举办盛宴", toastText: "宫中张灯结彩，华筵铺开，宫廷与民间一片欢腾👏", logText: "采纳皇后提议，中秋盛宴氛围温暖，人群笑语映照明月。"),
                    EventOption(text: "简单庆祝", toastText: "宫中布置简雅，群臣温馨共度中秋🏮", logText: nil)
                ]
            ),
            (
                title: "⛲️宫廷",
                description: "宫中御花园的牡丹花盛开，皇后轻笑邀皇帝共赏。花间一回眸，仿佛又回到年少时两人初见的模样。",
                options: [
                    EventOption(text: "欣然前往", toastText: "😘皇帝与皇后在花园中漫步赏花~", logText: nil),
                    EventOption(text: "忙于政务", toastText: "花香独留，皇后略感失落😢...", logText: nil)
                ]
            ),
            (
                title: "⛲️宫廷",
                description: "边关急奏传来：屯田士卒遭暴风侵袭，粮草散落泥泞，帐篷倒塌，哀嚎与呼救声混入风声。",
                options: [
                    EventOption(text: "亲自调度", toastText: "士卒获援，民心振奋💪", logText: "宫中夜灯映照书案，思绪仍牵边关安危..."),
                    EventOption(text: "委派大臣", toastText: "调度交由大臣，稳妥应对💪", logText: nil)
                ]
            ),
            (
                title: "⛲️宫廷",
                description: "太后召皇帝入书房，语气温和却坚定，提醒他膝下无子，事关皇室未来，需早作打算。",
                options: [
                    EventOption(text: "烦了想走", toastText: "不耐烦地回应太后，起身欲离开书房", logText: nil),
                    EventOption(text: "沉默不语", toastText: "书房静默，太后眉间忧思", logText: nil)
                ]
            ),
            (
                title: "⛲️宫廷",
                description: "今日大朝，群臣进见，皇上需决定是否采纳新的赋税制度提案，以平衡国库与民生。",
                options: [
                    EventOption(text: "采纳提案", toastText: "新政上奏，朝臣称善", logText: "皇帝采纳新赋税方案，国库渐充百官称善，朝堂风声更稳。"),
                    EventOption(text: "暂缓执行", toastText: "朝堂静待明日抉择，宫中沉思未了", logText: nil)
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
                title: "🐒后宫",
                description: "太医院官员匆匆入宫，恭敬禀报：“皇上，妃子遇喜了！”",
                options: [
                    EventOption(text: "亲自前往", toastText: "☺️见到爱妃安好，心头一片暖意", logText: nil),
                    EventOption(text: "暂缓理会", toastText: "皇帝埋首文书，眉眼却未展喜色", logText: nil)
                ]
            ),
            (
                title: "🐒后宫",
                description: "悄然步入后宫，她在院中理饰花卉，随即恭敬行礼，脸上浮现惊喜而柔和的笑意，阳光洒在她肩头，轻盈而生动。",
                options: [
                    EventOption(text: "伸手帮她整理花枝", toastText: "笑意与花香在院中流淌🌸", logText: "宠爱的妃子让后宫暗生嫉意。"),
                    EventOption(text: "微笑夸赞", toastText: "与妃子共餐，皇帝暗自喜悦", logText: nil)
                ]
            ),
            (
                title: "🐒后宫",
                description: "妃子在宫中挑选新来的书卷，皇后冷眼注视，轻声提醒妃子礼数。妃子心中暗自较量，想赢得皇帝好感，却不得不顾忌皇后的威严，气氛微微紧张。",
                options: [
                    EventOption(text: "偏袒妃子", toastText: "皇后警惕加深，宫中暗流悄起", logText: nil),
                    EventOption(text: "偏袒皇后", toastText: "妃子心生忌意，后宫暗流涌动", logText: nil)
                ]
            ),
            (
                title: "🐒后宫",
                description: "妃子们希望能在宫中举办一场诗词会，邀请皇帝一同参与。",
                options: [
                    EventOption(text: "批准举办", toastText: "宫中举办诗词会，妃子们吟诗作对", logText: "因妃子们的请求，皇帝批准举办诗词会"),
                    EventOption(text: "改日再议", toastText: "皇帝决定改日再议", logText: nil)
                ]
            ),
            (
                title: "🐒后宫",
                description: "有人私下议论某个妃子近日行为异于平日，似在暗中筹划什么。",
                options: [
                    EventOption(text: "暂不理会", toastText: "妃子谨慎行事，暗流潜伏🤫", logText: nil),
                    EventOption(text: "暗中调查", toastText: "皇帝暗查流言来源，，后宫气息微紧", logText: nil)
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
                title: "⚠️危急",
                description: "深夜，皇帝在寝宫中就寝。突然，一名刺客潜入宫中，意图行刺！！",
                options: [
                    EventOption(text: "奋力抵抗！", toastText: "禁卫及时赶到，刺客被擒", logText: "深夜遇刺，皇帝奋力抵抗，禁卫及时赶到救驾"),
                    EventOption(text: "呼救禁卫！", toastText: "皇帝遇刺身亡！", logText: "因遇刺事件，皇帝呼救禁卫但为时已晚，不幸身亡")
                ]
            ),
            (
                title: "⚠️危急",
                description: "🏹皇帝在御花园散步时，突然从暗处射来一支毒箭！！",
                options: [
                    EventOption(text: "躲避不及！", toastText: "皇帝中箭，虽经抢救但仍不幸身亡", logText: "因遇刺事件，皇帝躲避不及，不幸中箭身亡"),
                    EventOption(text: "禁卫护驾！", toastText: "禁卫以身挡箭，皇帝幸免于难", logText: "遇刺事件，禁卫舍身护驾，皇帝幸免于难")
                ]
            ),
            (
                title: "⚠️危急",
                description: "边关传来急报：有将领密谋造反，意图推翻朝廷！！",
                options: [
                    EventOption(text: "派兵镇压！", toastText: "朝廷派兵镇压，谋反被平息", logText: "边关谋反，皇帝派兵镇压，叛乱被平息"),
                    EventOption(text: "谈判安抚！", toastText: "谋反成功，王朝覆灭", logText: "边关谋反，皇帝招安失败，谋反成功，王朝覆灭")
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
