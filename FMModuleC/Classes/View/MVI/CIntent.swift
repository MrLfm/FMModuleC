//
//  CIntent.swift
//  FMModuleC
//
//  Created by FumingLeo on 2025/11/21.
//

import Foundation

/// MVI架构中的Intent，表示用户意图或系统事件
public enum CIntent {
    // MARK: - 基础操作
    case incrementCount
    case incrementCountFromNetwork
    case showTime
    
    // MARK: - 数据加载
    case loadItems
    case loadMoreItems
    
    // MARK: - 搜索功能（带防抖）
    case searchTextChanged(String)
    case performSearch(String)
    
    // MARK: - 表单验证
    case inputTextChanged(String)
    case submitForm
    
    // MARK: - 错误处理
    case clearError
    case retryLastOperation
    
    // MARK: - 撤销/重做
    case undo
    case redo
    case saveToHistory
    
    // MARK: - 条件性操作
    case conditionalIncrement
    
    // MARK: - 链式操作
    case startChainOperation
    case chainStep1
    case chainStep2
    case chainStep3
}
