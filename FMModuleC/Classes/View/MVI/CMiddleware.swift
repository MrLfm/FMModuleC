//
//  CMiddleware.swift
//  FMModuleC
//
//  Created by FumingLeo on 2025/11/21.
//

import Foundation
import Combine

/// MVI架构中的Middleware，负责处理异步操作和副作用
public struct CMiddleware {
    /// 处理Intent，返回对应的Effect
    public static func middleware(intent: CIntent, state: CState) -> AnyPublisher<CEffect?, Never> {
        switch intent {
        case .incrementCountFromNetwork:
            return Future<CEffect?, Never> { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    // 模拟网络请求，30%概率失败
                    if Int.random(in: 1...10) <= 3 {
                        promise(.success(.networkError("网络请求失败，请稍后重试")))
                    } else {
                        promise(.success(.networkDataFetched))
                    }
                }
            }
            .eraseToAnyPublisher()
            
        case .loadItems:
            // 先发送加载开始状态，然后异步加载数据
            return Just(CEffect.loadingStarted("正在加载数据..."))
                .append(
                    Future<CEffect?, Never> { promise in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            let items = (1...10).map { index in
                                CState.ListItem(
                                    id: "item_\(index)",
                                    title: "项目 \(index)",
                                    subtitle: "这是第 \(index) 个项目"
                                )
                            }
                            promise(.success(.itemsLoaded(items)))
                        }
                    }
                )
                .eraseToAnyPublisher()
            
        case .loadMoreItems:
            // 检查是否还有更多数据和是否正在加载
            guard state.hasMorePages && !state.isLoading else {
                return Just(nil).eraseToAnyPublisher()
            }
            
            return Just(CEffect.loadingStarted("加载更多..."))
                .append(
                    Future<CEffect?, Never> { promise in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            let startIndex = state.items.count + 1
                            let pageSize = 10
                            let totalItems = 25
                            let endIndex = min(startIndex + pageSize - 1, totalItems)
                            let items = (startIndex...endIndex).map { index in
                                CState.ListItem(
                                    id: "item_\(index)",
                                    title: "项目 \(index)",
                                    subtitle: "这是第 \(index) 个项目"
                                )
                            }
                            promise(.success(.moreItemsLoaded(items)))
                        }
                    }
                )
                .eraseToAnyPublisher()
            
        case .performSearch(let query):
            // 执行搜索，过滤匹配的项目
            return Just(CEffect.loadingStarted("搜索中..."))
                .append(
                    Future<CEffect?, Never> { promise in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            let results = state.items.filter { item in
                                item.title.contains(query) || item.subtitle.contains(query)
                            }
                            promise(.success(.searchCompleted(results)))
                        }
                    }
                )
                .eraseToAnyPublisher()
            
        case .submitForm:
            // 表单验证
            if state.inputText.isEmpty {
                return Just(CEffect.validationError("输入不能为空")).eraseToAnyPublisher()
            }
            if state.inputText.count < 3 {
                return Just(CEffect.validationError("输入至少需要3个字符")).eraseToAnyPublisher()
            }
            
            // 验证通过后，触发链式操作
            return Just(CEffect.loadingFinished)
                .append(
                    Future<CEffect?, Never> { promise in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            promise(.success(.triggerIntent(.incrementCount)))
                        }
                    }
                )
                .eraseToAnyPublisher()
            
        case .retryLastOperation:
            // 根据当前错误状态决定重试操作
            if state.errorMessage != nil {
                return Future<CEffect?, Never> { promise in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        promise(.success(.networkDataFetched))
                    }
                }
                .eraseToAnyPublisher()
            }
            return Just(nil).eraseToAnyPublisher()
            
        case .conditionalIncrement:
            // 条件性操作：只有当count小于10时才执行
            if state.count < 10 {
                return Future<CEffect?, Never> { promise in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        promise(.success(.conditionalEffectExecuted))
                    }
                }
                .eraseToAnyPublisher()
            } else {
                return Just(CEffect.operationFailed("计数已达到上限")).eraseToAnyPublisher()
            }
            
        case .startChainOperation:
            return Future<CEffect?, Never> { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    promise(.success(.chainEffect1))
                }
            }
            .eraseToAnyPublisher()
            
        case .chainStep1:
            return Future<CEffect?, Never> { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    promise(.success(.chainEffect2))
                }
            }
            .eraseToAnyPublisher()
            
        case .chainStep2:
            return Future<CEffect?, Never> { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    promise(.success(.chainEffect3))
                }
            }
            .eraseToAnyPublisher()
            
        default:
            return Just(nil).eraseToAnyPublisher()
        }
    }
    
    /// 处理Effect，可能触发新的Effect或Intent（用于链式操作）
    public static func handleEffect(_ effect: CEffect, state: CState) -> AnyPublisher<CEffect?, Never> {
        switch effect {
        case .chainEffect1:
            // 链式操作第一步：触发下一个Intent
            return Future<CEffect?, Never> { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    promise(.success(.triggerIntent(.chainStep1)))
                }
            }
            .eraseToAnyPublisher()
            
        case .chainEffect2:
            // 链式操作第二步：触发下一个Intent
            return Future<CEffect?, Never> { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    promise(.success(.triggerIntent(.chainStep2)))
                }
            }
            .eraseToAnyPublisher()
            
        case .chainEffect3:
            // 链式操作完成
            return Just(CEffect.loadingFinished).eraseToAnyPublisher()
            
        default:
            return Just(nil).eraseToAnyPublisher()
        }
    }
}
