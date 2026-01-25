//
//  MainContainerView.swift
//  gongtingrizhi
//
//  Created by 朱荣 on 2026/1/10.
//

import SwiftUI

// MARK: - 主容器视图（包含底部Tab导航）
struct MainContainerView: View {
    @ObservedObject var gameManager: GameManager
    @State private var selectedTab: MainTab = .imperialDesk
    @State private var isShowingEventDetail = false  // 是否显示事件详情（用于隐藏底部导航栏）
    
    var body: some View {
        VStack(spacing: 0) {
            // 主内容区
            Group {
                switch selectedTab {
                case .imperialDesk:
                    ImperialDeskView(gameManager: gameManager, isShowingEventDetail: $isShowingEventDetail)
                case .relationships:
                    RelationshipsView(gameManager: gameManager)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 底部Tab导航（在详情视图中隐藏）
            if !isShowingEventDetail {
                bottomTabBar
            }
        }
    }
    
    // MARK: - 底部Tab导航栏
    private var bottomTabBar: some View {
        HStack(spacing: 0) {
            // Tab 1: 御桌
            TabButton(
                title: "御桌",
                isSelected: selectedTab == .imperialDesk,
                action: { selectedTab = .imperialDesk }
            )
            
            // Tab 2: 关系（需要解锁）
            TabButton(
                title: "关系",
                isSelected: selectedTab == .relationships,
                isEnabled: gameManager.isRelationshipsUnlocked,
                action: { 
                    if gameManager.isRelationshipsUnlocked {
                        selectedTab = .relationships
                    }
                }
            )
        }
        .frame(height: 60)
        .background(Color.white.opacity(0.9))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.9)),
            alignment: .top
        )
    }
}

// MARK: - Tab枚举
enum MainTab {
    case imperialDesk  // 御桌
    case relationships  // 关系
}

// MARK: - Tab按钮组件
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    init(title: String, isSelected: Bool, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isEnabled ? (isSelected ? Color(red: 0.64, green: 0.4, blue: 0.23) : Color(red: 0.6, green: 0.6, blue: 0.6)) : Color(red: 0.7, green: 0.7, blue: 0.7))
                
                if isSelected {
                    Rectangle()
                        .frame(width: 30, height: 2)
                        .foregroundColor(Color(red: 0.64, green: 0.4, blue: 0.23))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    MainContainerView(gameManager: GameManager())
}
