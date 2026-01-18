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
                title: "前朝事件",
                description: "丞相上奏：陛下，今年北方大旱，百姓颗粒无收，是否开仓赈济灾民？宫廷上下等待皇上决断。",
                options: [
                    EventOption(
                        text: "立即开仓放粮",
                        toastText: "皇帝下令开仓，灾民感激涕零",
                        logText: "皇帝决定立即开仓，赈济灾民。",
                        attitude: .lenient,
                        attributeChanges: AttributeChanges(mood: 0.0, intelligence: 0.0, charm: 0.0, reputation: 0.0, popularity: 0.2, morality: 0.15)
                    ),
                    EventOption(
                        text: "先调查再决定",
                        toastText: "钦差随即启程，核实灾情",
                        logText: "皇帝派遣官员调查灾情再作决断。",
                        attitude: .balanced,
                        attributeChanges: AttributeChanges(mood: 0.0, intelligence: 0.1, charm: 0.0, reputation: 0.0, popularity: 0.05, morality: 0.0)
                    ),
                    EventOption(
                        text: "拒绝开仓",
                        toastText: "皇帝认为灾情不实，拒绝开仓",
                        logText: "皇帝认为灾情不实",
                        attitude: .strong,
                        attributeChanges: AttributeChanges(mood: -0.05, intelligence: 0.0, charm: 0.0, reputation: -0.1, popularity: -0.1, morality: -0.1)
                    ),
                ]
            ),
            (
                title: "前朝事件",
                description: "兵部尚书禀报：陛下，边境传来急报，邻国军队在边境集结，意图不明。",
                options: [
                    EventOption(text: "增派兵马防御", toastText: "边境兵马调动，军心大振", logText: "因兵部尚书的禀报，皇帝决定增派兵马加强边境防御"),
                    EventOption(text: "派遣使者交涉", toastText: "使者快马加鞭前往邻国", logText: "因兵部尚书的禀报，皇帝决定派遣使者前往邻国交涉")
                ]
            ),
            (
                title: "前朝事件",
                description: "户部尚书奏报：陛下，今年国库充盈，建议减免部分赋税，以安民心。",
                options: [
                    EventOption(
                        text: "减免赋税",
                        toastText: "百姓闻讯欢呼，民心大悦😊",
                        logText: "因户部尚书的建议，皇帝决定减免赋税，民心大悦",
                        attitude: .lenient,
                        attributeChanges: AttributeChanges(mood: 0.05, intelligence: 0.0, charm: 0.0, reputation: 0.0, popularity: 0.15, morality: 0.05)
                    ),
                    EventOption(
                        text: "保持现状",
                        toastText: "赋税维持原样，官府继续运作",
                        logText: "皇帝权衡后决定保持现有赋税政策",
                        attitude: .balanced,
                        attributeChanges: AttributeChanges(mood: 0.0, intelligence: 0.1, charm: 0.0, reputation: 0.05, popularity: 0.0, morality: 0.0)
                    )
                ]
            ),
            (
                title: "前朝事件",
                description: "御史大夫弹劾某位官员贪污受贿，请求陛下严惩！！",
                options: [
                    EventOption(
                        text: "严惩不贷",
                        toastText: "贪官被罢黜，朝野震动",
                        logText: "因御史大夫的弹劾，皇帝决定严惩贪官，以正朝纲",
                        attitude: .strong,
                        attributeChanges: AttributeChanges(mood: 0.0, intelligence: 0.0, charm: 0.0, reputation: 0.1, popularity: 0.05, morality: 0.1)
                    ),
                    EventOption(
                        text: "调查后再定",
                        toastText: "皇帝下令彻查此事",
                        logText: "因御史大夫的弹劾，皇帝决定先调查真相再做决定",
                        attitude: .balanced,
                        attributeChanges: AttributeChanges(mood: 0.0, intelligence: 0.05, charm: 0.0, reputation: 0.0, popularity: 0.0, morality: 0.05)
                    )
                ]
            ),
            (
                title: "前朝事件",
                description: "皇上，江南学士名声远播，多次上书献策，才思敏捷，实为治国之良才。臣恭请陛下亲自召见，以纳贤助政！",
                options: [
                    EventOption(text: "采纳建议", toastText: "吏部尚书见你爱才，甚是欣慰😊", logText: "皇帝亲自召见江南学士，纳其才助朝政。"),
                    EventOption(text: "暂缓招揽", toastText: "书信留案，先观其行再作决断", logText: nil)
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
                description: "宫中御养的橘猫不见了，宫人低声议论，说它昨夜还在御书房附近出没。今日一早，几位内侍在殿外小心翼翼地候着...",
                options: [
                    EventOption(
                        text: "不用管，它自己会回来的",
                        toastText: "皇帝命人备下鱼干🐟，御猫当夜悄然现身～",
                        logText: nil,
                        attitude: .lenient,
                        attributeChanges: AttributeChanges(mood: 0.05, intelligence: 0.0, charm: 0.05, reputation: 0.0, popularity: 0.0, morality: 0.0)
                    ),
                    EventOption(
                        text: "找不到，杖责五十大板！",
                        toastText: "那么凶，奴才们被你吓死了😰",
                        logText: nil,
                        attitude: .strong,
                        attributeChanges: AttributeChanges(mood: -0.1, intelligence: 0.0, charm: 0.0, reputation: 0.0, popularity: -0.05, morality: -0.1)
                    )
                ]
            ),
            (
                title: "宫廷事件",
                description: "中秋佳节临近，宫中灯火初上，皇后提议设宴群臣，共赏明月，彰显皇室恩德。",
                options: [
                    EventOption(
                        text: "举办盛宴",
                        toastText: "宫中张灯结彩，华筵铺开，宫廷与民间一片欢腾。",
                        logText: "采纳皇后提议，中秋盛宴氛围温暖，人群笑语映照明月。",
                        attitude: .lenient,
                        attributeChanges: AttributeChanges(mood: 0.1, intelligence: 0.0, charm: 0.05, reputation: 0.0, popularity: 0.1, morality: 0.0)
                    ),
                    EventOption(
                        text: "简单庆祝",
                        toastText: "宫中布置简雅，群臣温馨共度中秋🏮",
                        logText: nil,
                        attitude: .balanced,
                        attributeChanges: AttributeChanges(mood: 0.05, intelligence: 0.0, charm: 0.0, reputation: 0.0, popularity: 0.0, morality: 0.0)
                    )
                ]
            ),
            (
                title: "宫廷事件",
                description: "宫中御花园的牡丹花盛开，皇后轻笑邀皇帝共赏。花间一回眸，仿佛又回到年少时两人初见的模样。",
                options: [
                    EventOption(text: "欣然前往", toastText: "😘皇帝与皇后在花园中漫步赏花~", logText: nil),
                    EventOption(text: "忙于政务", toastText: "花香独留，皇后略感失落😢...", logText: nil)
                ]
            ),
            (
                title: "宫廷事件",
                description: "御膳房呈上新菜，你轻尝一口，香味中带着几分细腻与巧思。宫女们屏息旁立，等待你的评价。",
                options: [
                    EventOption(text: "好吃好吃", toastText: "你轻抿一口，满意地点头😄", logText: "皇帝挑嘴却称赞新菜，宫内和民间纷纷效仿，新菜瞬间成为热门。"),
                    EventOption(text: "没尝出啥味", toastText: "你真难伺候，让新来的厨子战战兢兢😢", logText: nil)
                ]
            ),
            (
                title: "宫廷事件",
                description: "你在书案上翻阅奏折，笔墨飘香。侍臣小心递过最新奏报，不敢怠慢。窗外微风拂过，卷页轻轻晃动。",
                options: [
                    EventOption(text: "批示下去", toastText: "你批下公文，群臣忙碌，宫中井然有序。", logText: nil),
                    EventOption(text: "退回重议", toastText: "你鸡蛋里挑骨头，群臣微微紧张了😅", logText: nil)
                ]
            ),
            (
                title: "宫廷事件",
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
                title: "后宫事件",
                description: "太医院恭敬禀报：“有妃子遇喜了！”宫中顿时一阵轻微骚动，连窗外的小鸟似乎都停了片刻。你的心里有一丝意外，也有一丝期待。",
                options: [
                    EventOption(text: "前往探望", toastText: "见到爱妃安好，心头一片暖意", logText: nil),
                    EventOption(text: "暂缓理会", toastText: "皇帝埋首文书，眉眼却未展喜色", logText: nil)
                ]
            ),
            (
                title: "后宫事件",
                description: "新来的妃子说话的语气，忽然让你想起旧人。有人看在眼里，故意学她从前的装扮，连步子都慢了半分。",
                options: [
                    EventOption(text: "刻意疏远", toastText: "微微避开，不作过多回应", logText: "新妃略显尴尬，旁妃暗自揣度。"),
                    EventOption(text: "微笑夸赞", toastText: "你多看一眼，她便笑得更小心翼翼", logText: nil)
                ]
            ),
            (
                title: "后宫事件",
                description: "内务府新进一批胭脂，据说颜色像刚落的晚霞。几位妃子都想要同一盒，送到你案前的名册，却只够写一个名字。",
                options: [
                    EventOption(text: "赐给心仪之人", toastText: "一盒胭脂，三张冷脸", logText: nil),
                    EventOption(text: "谁都不给", toastText: "皇帝未作赐予，众妃各怀心思", logText: nil)
                ]
            ),
            (
                title: "后宫事件",
                description: "夜深时，有人抚琴。曲子不算高明，却很认真。太监问要不要查问，你却忽然想听完。",
                options: [
                    EventOption(text: "召她来见", toastText: "琴弹得一般，人倒是挺真的", logText: "皇帝因琴声召见妃子，宫中多有议论。"),
                    EventOption(text: "不必惊动", toastText: "有些心事，远一点更好听", logText: nil)
                ]
            ),
            (
                title: "后宫事件",
                description: "御花园里有人放风筝，线忽然断了，正好落在你脚边。风筝背面写着一句小字，像是不该给你看的。",
                options: [
                    EventOption(text: "当作无事", toastText: "装没看见，也是门功夫", logText: nil),
                    EventOption(text: "命人调查", toastText: "皇帝命查风筝来历，，后宫气息微紧", logText: nil)
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
    
    // MARK: - 生成世情风向事件
    func generatePublicOpinionEvent() -> GameEvent {
        let events: [(title: String, description: String, options: [EventOption])] = [
            (
                title: "世情风向",
                description: "几家书院近日辩论不断，有人称当今政令“稳而慢”，有人说“慢即是安”。争论写成条陈递进宫里，问陛下愿不愿亲自听一听。",
                options: [
                    EventOption(text: "微服出访", toastText: "这些话，平日没人敢对你说", logText: "皇帝微服出访，百姓感念皇恩，民心大悦。"),
                    EventOption(text: "不作回应", toastText: "民间百姓对你略感失望", logText: nil)
                ]
            ),
            (
                title: "世情风向",
                description: "市集里米价又涨了一截，茶馆里骂声比说书声还响。有人说是几家大商贾暗中囤货，也有人说不过是老天不肯下雨。奏折递到案前，只等陛下一句话。",
                options: [
                    EventOption(text: "严查商贾", toastText: "这下，得把肚子吐出来。", logText: "因市井传言，皇帝下令严查商贾，物价回落，百姓称善。"),
                    EventOption(text: "暂不理会", toastText: "朝廷未有动作，市井议论更甚，怨气隐约上浮", logText: nil)
                ]
            ),
            (
                title: "世情风向",
                description: "近来坊间流传一首新诗，字句清淡，却把朝廷比作“久坐的旧椅”。文人抄来抄去，越传越像一场无声的聚会。有人劝陛下早些按住这阵风。",
                options: [
                    EventOption(text: "查禁此诗", toastText: "纸是按住了，嘴可没那么听话", logText: "因民间流传新诗，皇帝下令查禁，文人议论纷纷。"),
                    EventOption(text: "不管不管", toastText: "朝廷未加干涉，诗作仍在流传，舆论渐成气候。", logText: nil)
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
    
    // MARK: - 生成突发事件
    func generateCriticalEvent() -> GameEvent {
        let events: [(title: String, description: String, options: [EventOption])] = [
            (
                title: "突发事件",
                description: "夜深灯昏，你尚未入梦。帷帐外传来一声极轻的响动，下一瞬寒光已逼近咽喉——刺客来了！",
                options: [
                    EventOption(text: "拔剑自守！", toastText: "陛下这一剑还挺像样，就是手有点抖🥶", logText: "禁卫及时赶到，刺客被擒。"),
                    EventOption(text: "呼救禁卫！", toastText: "喊是喊了，可刀比嗓子快！", logText: "因遇刺事件，皇帝呼救禁卫但为时已晚，不幸身亡。")
                ]
            ),
            (
                title: "突发事件",
                description: "御花园里风很轻，你正听内侍说着闲话。忽然一声弦响，一支暗箭破空而来，带着刺鼻的药味！",
                options: [
                    EventOption(text: "本能闪避！", toastText: "你仍被毒箭擦中，药性凶猛！", logText: "园中遇袭，不幸中箭身亡"),
                    EventOption(text: "禁卫护驾！", toastText: "有人替你挡了箭，却没机会听你说声谢", logText: "禁卫舍身护驾，皇帝幸免于难。")
                ]
            ),
            (
                title: "突发事件",
                description: "急报入京：边关将领拥兵自重，檄文已传诸郡，称天命不在朝廷！",
                options: [
                    EventOption(text: "铁腕平叛！", toastText: "诏书一张，多少人替你拼命。", logText: "边将反叛，皇帝发兵征讨数月，乱事终定。"),
                    EventOption(text: "遣使招安！", toastText: "谈的是前程，丢的是王朝", logText: "边关谋反谋反成功，王朝覆灭。")
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
