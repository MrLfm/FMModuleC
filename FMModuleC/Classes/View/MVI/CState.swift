//
//  CState.swift
//  FMModuleC
//
//  Created by FumingLeo on 2025/11/21.
//

import Foundation

/// MVI架构中的State，表示应用的状态
public struct CState: Equatable {
    // MARK: - 基础状态
    public var count: Int
    public var toastMessage: String?
    
    // MARK: - 加载状态
    public var isLoading: Bool
    public var loadingMessage: String?
    
    // MARK: - 错误状态
    public var errorMessage: String?
    
    // MARK: - 列表数据
    public var items: [ListItem]
    
    // MARK: - 搜索相关
    public var searchText: String
    public var searchResults: [ListItem]
    
    // MARK: - 分页相关
    public var currentPage: Int
    public var hasMorePages: Bool
    
    // MARK: - 表单验证
    public var inputText: String
    public var inputError: String?
    
    // MARK: - 历史状态（用于撤销/重做）
    /// 历史状态快照数组，用于实现撤销/重做功能
    /// 注意：为了节省内存，只存储状态的快照，不存储完整状态树
    public var history: [CState]
    /// 当前历史状态的索引
    public var historyIndex: Int
    /// 历史记录最大数量限制，避免内存问题
    private static let maxHistoryCount = 50
    
    public struct ListItem: Equatable, Identifiable {
        public let id: String
        public let title: String
        public let subtitle: String
        
        public init(id: String, title: String, subtitle: String) {
            self.id = id
            self.title = title
            self.subtitle = subtitle
        }
    }
    
    public init(
        count: Int = 0,
        toastMessage: String? = nil,
        isLoading: Bool = false,
        loadingMessage: String? = nil,
        errorMessage: String? = nil,
        items: [ListItem] = [],
        searchText: String = "",
        searchResults: [ListItem] = [],
        currentPage: Int = 1,
        hasMorePages: Bool = true,
        inputText: String = "",
        inputError: String? = nil,
        history: [CState] = [],
        historyIndex: Int = -1
    ) {
        self.count = count
        self.toastMessage = toastMessage
        self.isLoading = isLoading
        self.loadingMessage = loadingMessage
        self.errorMessage = errorMessage
        self.items = items
        self.searchText = searchText
        self.searchResults = searchResults
        self.currentPage = currentPage
        self.hasMorePages = hasMorePages
        self.inputText = inputText
        self.inputError = inputError
        self.history = history
        self.historyIndex = historyIndex
    }
    
    // MARK: - 派生状态
    
    /// 根据搜索状态返回要显示的项目列表
    public var displayItems: [ListItem] {
        if !searchText.isEmpty {
            return searchResults
        }
        return items
    }
    
    /// 是否可以执行撤销操作
    public var canUndo: Bool {
        return historyIndex > 0
    }
    
    /// 是否可以执行重做操作
    public var canRedo: Bool {
        return historyIndex < history.count - 1
    }
}
