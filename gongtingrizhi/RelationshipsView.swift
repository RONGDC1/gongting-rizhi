//
//  RelationshipsView.swift
//  gongtingrizhi
//
//  Created by 朱荣 on 2026/1/10.
//

import SwiftUI

// MARK: - 关系视图（Tab 2）
struct RelationshipsView: View {
    @ObservedObject var gameManager: GameManager
    @State private var selectedTab: RelationshipTab = .harem
    @State private var selectedMember: HaremMember? = nil  // 选中的妃子（用于显示交互弹窗）
    
    var body: some View {
        ZStack {
            // 背景色
            Color(red: 0.95, green: 0.92, blue: 0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部状态栏（与御桌视图一致）
                topStatusHeader
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                
                // Tab切换（后宫/皇嗣）
                relationshipTabBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                
                // 主内容区
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        switch selectedTab {
                        case .harem:
                            haremContentView
                        case .heirs:
                            heirsContentView
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 80)  // 为底部Tab留出空间
                }
            }
            
            // 妃子交互弹窗（使用ZStack覆盖，而不是fullScreenCover）
            if let member = selectedMember {
                ZStack {
                    // 半透明蒙层（不遮挡背景内容）
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                selectedMember = nil
                            }
                        }
                    
                    // 弹窗内容（居中显示）
                    HaremMemberActionView(member: member, gameManager: gameManager, onDismiss: {
                        withAnimation {
                            selectedMember = nil
                        }
                    })
                    .transition(.scale.combined(with: .opacity))
                }
                .zIndex(1000)
            }
        }
    }
    
    // MARK: - 顶部状态栏
    
    private var topStatusHeader: some View {
        HStack {
            Text(gameManager.getMonthDisplayText())
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(red: 0.55, green: 0.50, blue: 0.45))
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
    
    // MARK: - Tab切换栏
    
    private var relationshipTabBar: some View {
        HStack(spacing: 0) {
            // 后宫Tab
            TabButton(
                title: "后宫(\(gameManager.haremMembers.count))",
                isSelected: selectedTab == .harem,
                action: { selectedTab = .harem }
            )
            
            // 皇嗣Tab
            TabButton(
                title: "皇嗣(\(gameManager.heirs.count))",
                isSelected: selectedTab == .heirs,
                action: { selectedTab = .heirs }
            )
        }
        .frame(height: 44)
        .background(Color.white.opacity(0.75))
        .cornerRadius(8)
    }
    
    // MARK: - 后宫内容视图
    
    private var haremContentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 近期消息卡片（如果有）
            if let recentNews = gameManager.getRecentNews() {
                recentNewsCard(news: recentNews)
            }
            
            // 妃子列表（按位份排序：皇后、贵妃、妃）
            if gameManager.haremMembers.isEmpty {
                Text("暂无妃子")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                ForEach(gameManager.haremMembers.sorted { member1, member2 in
                    let rankOrder: [HaremRank: Int] = [.empress: 0, .nobleConsort: 1, .consort: 2, .concubine: 3, .nobleLady: 4]
                    return (rankOrder[member1.rank] ?? 99) < (rankOrder[member2.rank] ?? 99)
                }) { member in
                    HaremMemberCard(member: member, gameManager: gameManager, onTap: {
                        withAnimation {
                            selectedMember = member
                        }
                    })
                }
            }
        }
    }
    
    // MARK: - 皇嗣内容视图
    
    private var heirsContentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 立储卡片（如果有子嗣但未立储）
            if !gameManager.heirs.isEmpty && gameManager.crownPrince == nil {
                crownPrinceCard
            }
            
            // 皇嗣列表
            if gameManager.heirs.isEmpty {
                Text("暂无皇嗣")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                ForEach(gameManager.heirs) { heir in
                    HeirCard(heir: heir, gameManager: gameManager)
                }
            }
        }
    }
    
    // MARK: - 近期消息卡片
    
    private func recentNewsCard(news: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "bell.fill")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.64, green: 0.4, blue: 0.23))
            
            Text(news)
                .font(.system(size: 13))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.75))
        .cornerRadius(8)
    }
    
    // MARK: - 立储卡片
    
    @State private var showCrownPrinceSelection = false
    
    private var crownPrinceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("王朝立储")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(red: 0.45, green: 0.35, blue: 0.25))
            
            Text("皇帝还未立储，朝野势力暗暗观望。")
                .font(.system(size: 13))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
            
            Button(action: {
                showCrownPrinceSelection = true
            }) {
                Text("立储")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.64, green: 0.4, blue: 0.23))
                    .cornerRadius(6)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.75))
        .cornerRadius(12)
        .fullScreenCover(isPresented: $showCrownPrinceSelection) {
            CrownPrinceSelectionView(gameManager: gameManager, onDismiss: {
                showCrownPrinceSelection = false
            })
        }
    }
}

// MARK: - 关系Tab枚举

enum RelationshipTab {
    case harem   // 后宫
    case heirs   // 皇嗣
}

// MARK: - 妃子卡片组件

struct HaremMemberCard: View {
    let member: HaremMember
    @ObservedObject var gameManager: GameManager
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 姓名和位分（标签放在位份标签右边）
            HStack {
                Text(member.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.45, green: 0.35, blue: 0.25))
                
                Text(member.rank.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                
                // 标签（放在位份标签右边）
                if !member.traits.isEmpty {
                    ForEach(member.traits.prefix(2), id: \.self) { trait in
                        Text(trait.rawValue)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(red: 0.35, green: 0.65, blue: 0.35))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(red: 0.9, green: 0.95, blue: 0.9))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                // 健康状态标签（如果有）
                if let status = member.healthStatus {
                    Text(status == .pregnant ? "孕" : "病")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(status == .pregnant ? Color.orange : Color.red)
                        .cornerRadius(4)
                }
            }
            
            // 描述（根据位分生成）
            Text(getMemberDescription())
                .font(.system(size: 13))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                .lineSpacing(4)
            
            // 属性数值
            HStack(spacing: 16) {
                AttributeItem(label: "年龄", value: "\(member.age)")
                AttributeItem(label: "势力", value: "\(member.influence)")
                AttributeItem(label: "好感度", value: "\(member.affection)")
                AttributeItem(label: "子嗣", value: "\(member.children)")
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.75))
        .cornerRadius(12)
        .onTapGesture {
            onTap()
        }
    }
    
    private func getMemberDescription() -> String {
        switch member.rank {
        case .empress:
            return "三朝重臣之女，先帝早年订婚于你，与你情深意重"
        case .nobleConsort:
            return "虽出生于名门世家，却凭才情取得圣宠深爱"
        default:
            return "入宫以来，温婉贤淑，深得宫中上下喜爱"
        }
    }
}

// MARK: - 皇嗣卡片组件

struct HeirCard: View {
    let heir: Heir
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 姓名和身份
            HStack {
                Text(heir.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.45, green: 0.35, blue: 0.25))
                
                Text(heir.gender == .male ? "皇子" : "公主")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                
                Spacer()
                
                // 储君标签
                if heir.isCrownPrince {
                    Text("太子")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange)
                        .cornerRadius(4)
                }
            }
            
            // 生母信息
            Text("生母: \(heir.motherName)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
            
            // 标签（如果有）
            if !heir.traits.isEmpty {
                HStack(spacing: 6) {
                    ForEach(heir.traits.prefix(2), id: \.self) { trait in
                        Text(trait.rawValue)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(red: 0.35, green: 0.65, blue: 0.35))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(red: 0.9, green: 0.95, blue: 0.9))
                            .cornerRadius(4)
                    }
                }
            }
            
            // 属性数值
            HStack(spacing: 16) {
                AttributeItem(label: "年龄", value: "\(heir.age)")
                AttributeItem(label: "颜值", value: "\(heir.looks)")
                AttributeItem(label: "能力", value: "\(heir.ability)")
                AttributeItem(label: "影响力", value: "\(heir.influence)")
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.75))
        .cornerRadius(12)
    }
}

// MARK: - 属性项组件

struct AttributeItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
        }
    }
}

// MARK: - 妃子交互弹窗

struct HaremMemberActionView: View {
    let member: HaremMember
    @ObservedObject var gameManager: GameManager
    let onDismiss: () -> Void
    @State private var selectedAction: HaremAction? = nil
    @State private var showPregnancyChoice = false
    
    enum HaremAction {
        case chat
        case discussHeir
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text("\(member.name) | \(member.rank.rawValue)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(red: 0.45, green: 0.35, blue: 0.25))
            
            // 反馈内容（如果已选择交互）
            if let action = selectedAction {
                if action == .chat {
                    Text("烛光映照下，她轻声细语，心意暗动，好感度+10")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else if action == .discussHeir {
                    if showPregnancyChoice {
                        VStack(spacing: 12) {
                            Text("夜深人静，她依偎在你怀中...")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                Button("留") {
                                    handlePregnancyChoice(stay: true)
                                }
                                .buttonStyle(.borderedProminent)
                                
                                Button("不留") {
                                    handlePregnancyChoice(stay: false)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    } else {
                        Text("你与她讨论子嗣之事，她脸颊微红...")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
            }
            
            // 交互选项（未选择时显示）
            if selectedAction == nil {
                VStack(spacing: 12) {
                    Button("陪伴闲聊") {
                        selectedAction = .chat
                        // 增加好感度
                        if let index = gameManager.haremMembers.firstIndex(where: { $0.id == member.id }) {
                            gameManager.haremMembers[index].affection = min(100, member.affection + 10)
                        }
                        // 扣除体力-10
                        gameManager.deductStaminaForHaremInteraction()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("讨论子嗣") {
                        selectedAction = .discussHeir
                        showPregnancyChoice = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(24)
        .frame(width: 280)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    private func handlePregnancyChoice(stay: Bool) {
        if stay {
            // 扣除体力-10（留宿）
            gameManager.deductStaminaForHaremInteraction()
            
            // 40%概率怀孕
            if Int.random(in: 1...100) <= 40 {
                // 怀孕：设置健康状态和怀孕月份
                if let index = gameManager.haremMembers.firstIndex(where: { $0.id == member.id }) {
                    gameManager.haremMembers[index].healthStatus = .pregnant
                    gameManager.haremMembers[index].pregnancyMonth = 1  // 从第1个月开始
                    
                    // 触发系统弹窗事件：妃子有喜
                    gameManager.triggerPregnancySystemEvent(memberName: member.name)
                }
            }
        }
        // 无论是否怀孕，都关闭弹窗
        onDismiss()
    }
}

// MARK: - 立储选择视图

struct CrownPrinceSelectionView: View {
    @ObservedObject var gameManager: GameManager
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // 全屏蒙层
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // 弹窗内容（居中显示）
            VStack(spacing: 20) {
                // 标题
                Text("选择储君")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.45, green: 0.35, blue: 0.25))
                
                // 皇嗣列表
                if gameManager.heirs.isEmpty {
                    Text("暂无皇嗣")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                        .padding(.vertical, 40)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(gameManager.heirs) { heir in
                                Button(action: {
                                    // 设置储君
                                    gameManager.setCrownPrince(heir: heir)
                                    onDismiss()
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(heir.name)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                            
                                            Text("\(heir.gender == .male ? "皇子" : "公主") | 生母: \(heir.motherName)")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                                        }
                                        
                                        Spacer()
                                        
                                        if heir.isCrownPrince {
                                            Text("已立储")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.orange)
                                                .cornerRadius(4)
                                        }
                                    }
                                    .padding(12)
                                    .background(heir.isCrownPrince ? Color(red: 0.95, green: 0.9, blue: 0.85) : Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(heir.isCrownPrince ? Color.orange : Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxHeight: 400)
                }
                
                // 取消按钮
                Button(action: onDismiss) {
                    Text("取消")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                        .cornerRadius(6)
                }
            }
            .padding(24)
            .frame(width: 320)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
    }
}

#Preview {
    RelationshipsView(gameManager: GameManager())
}
