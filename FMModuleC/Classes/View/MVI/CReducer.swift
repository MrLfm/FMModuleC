//
//  CReducer.swift
//  FMModuleC
//
//  Created by FumingLeo on 2025/11/21.
//

import Foundation

/// MVI架构中的Reducer，负责处理Intent和Effect，生成新的State
public struct CReducer {
    /// 根据Intent更新State
    public static func reduce(state: CState, intent: CIntent) -> CState {
        var newState = state
        
        switch intent {
        case .incrementCount:
            newState.count += 1
            
        case .showTime:
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "H点m分s秒"
            newState.toastMessage = formatter.string(from: Date())
            
        case .searchTextChanged(let text):
            newState.searchText = text
            // 清空搜索结果，等待新的搜索请求
            newState.searchResults = []
            
        case .inputTextChanged(let text):
            newState.inputText = text
            newState.inputError = nil
            
        case .clearError:
            newState.errorMessage = nil
            
        case .undo:
            if newState.canUndo {
                newState.historyIndex -= 1
                if newState.historyIndex >= 0 {
                    return newState.history[newState.historyIndex]
                }
            }
            
        case .redo:
            if newState.canRedo {
                newState.historyIndex += 1
                if newState.historyIndex < newState.history.count {
                    return newState.history[newState.historyIndex]
                }
            }
            
        case .saveToHistory:
            // 移除当前索引之后的历史记录（重做分支）
            var updatedHistory = Array(newState.history.prefix(newState.historyIndex + 1))
            updatedHistory.append(newState)
            
            // 限制历史记录数量，避免内存问题
            if updatedHistory.count > 50 {
                updatedHistory.removeFirst()
                newState.historyIndex = updatedHistory.count - 1
            } else {
                newState.historyIndex = updatedHistory.count - 1
            }
            
            newState.history = updatedHistory
            
        // 需要Middleware处理的异步Intent，直接返回原状态
        default:
            return newState
        }
        
        return newState
    }
    
    /// 根据Effect更新State（Effect通常由Middleware产生）
    public static func reduce(state: CState, effect: CEffect) -> CState {
        var newState = state
        
        switch effect {
        case .itemsLoaded(let items):
            newState.items = items
            newState.currentPage = 1
            newState.hasMorePages = items.count >= 10
            newState.isLoading = false
            newState.loadingMessage = nil
            
        case .moreItemsLoaded(let items):
            newState.items.append(contentsOf: items)
            newState.currentPage += 1
            newState.isLoading = false
            newState.loadingMessage = nil
            // 如果返回的项目数少于10个，表示已加载完所有数据
            newState.hasMorePages = items.count >= 10
            
        case .searchCompleted(let results):
            newState.searchResults = results
            newState.isLoading = false
            newState.loadingMessage = nil
            
        case .networkError(let message), .operationFailed(let message):
            newState.errorMessage = message
            newState.isLoading = false
            newState.loadingMessage = nil
            
        case .validationError(let message):
            newState.inputError = message
            
        case .loadingStarted(let message):
            newState.isLoading = true
            newState.loadingMessage = message
            newState.errorMessage = nil
            
        case .loadingFinished:
            newState.isLoading = false
            newState.loadingMessage = nil
            
        case .stateRestored(let restoredState):
            return restoredState
            
        default:
            break
        }
        
        return newState
    }
}
