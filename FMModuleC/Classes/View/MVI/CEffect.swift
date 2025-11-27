//
//  CEffect.swift
//  FMModuleC
//
//  Created by FumingLeo on 2025/11/21.
//

import Foundation

/// MVI架构中的Effect，表示副作用或需要处理的事件
public enum CEffect {
    // MARK: - 网络操作
    case networkDataFetched
    
    // MARK: - 数据加载
    case itemsLoaded([CState.ListItem])
    case moreItemsLoaded([CState.ListItem])
    case searchCompleted([CState.ListItem])
    
    // MARK: - 错误处理
    case networkError(String)
    case validationError(String)
    case operationFailed(String)
    
    // MARK: - 加载状态
    case loadingStarted(String?)
    case loadingFinished
    
    // MARK: - Intent触发（Effect到Intent的转换）
    case triggerIntent(CIntent)
    
    // MARK: - 链式Effect
    case chainEffect1
    case chainEffect2
    case chainEffect3
    
    // MARK: - 状态持久化
    case stateSaved
    case stateRestored(CState)
    
    // MARK: - 条件性Effect
    case conditionalEffectExecuted
}
