//
//  CViewModel.swift
//  FMModuleC
//
//  Created by FumingLeo on 2025/11/21.
//

import Foundation
import Combine

/// MVI架构中的ViewModel，负责管理状态和处理用户意图
@MainActor
public class CViewModel: ObservableObject {
    @Published public private(set) var state: CState
    
    private let intentSubject = PassthroughSubject<CIntent, Never>()
    private var cancellables = Set<AnyCancellable>()
    /// 搜索防抖任务，用于延迟执行搜索请求
    private var searchDebounceWorkItem: DispatchWorkItem?
    
    public init(initialState: CState = CState()) {
        self.state = initialState
        
        // 订阅Intent流，处理用户意图
        intentSubject
            .sink { [weak self] intent in
                guard let self = self else { return }
                self.handleIntent(intent)
            }
            .store(in: &cancellables)
    }
    
    /// 处理Intent，区分同步和异步操作
    private func handleIntent(_ intent: CIntent) {
        // 判断是否为同步Intent（不需要Middleware处理的）
        let isSynchronous: Bool = {
            switch intent {
            case .incrementCount, .showTime, .inputTextChanged, .clearError, 
                 .undo, .redo, .saveToHistory, .searchTextChanged:
                return true
            default:
                return false
            }
        }()
        
        if isSynchronous {
            self.state = CReducer.reduce(state: self.state, intent: intent)
            
            // showTime需要延迟清除toast消息
            if case .showTime = intent {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    guard let self = self else { return }
                    var updatedState = self.state
                    updatedState.toastMessage = nil
                    self.state = updatedState
                }
            }
            
            // searchTextChanged需要防抖处理，避免频繁触发搜索
            if case .searchTextChanged(let text) = intent {
                self.searchDebounceWorkItem?.cancel()
                let workItem = DispatchWorkItem { [weak self] in
                    guard let self = self, !text.isEmpty else { return }
                    self.dispatch(.performSearch(text))
                }
                self.searchDebounceWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
            }
            
            return
        }
        
        // 异步操作通过Middleware处理
        CMiddleware.middleware(intent: intent, state: self.state)
            .sink { [weak self] effect in
                guard let self = self else { return }
                if let effect = effect {
                    self.handleEffect(effect)
                }
            }
            .store(in: &cancellables)
    }
    
    /// 处理Effect，更新状态并处理可能的后续操作
    private func handleEffect(_ effect: CEffect) {
        self.state = CReducer.reduce(state: self.state, effect: effect)
        
        // 处理Effect可能触发的后续操作
        switch effect {
        case .triggerIntent(let intent):
            // Effect到Intent的转换
            self.dispatch(intent)
            
        case .chainEffect1, .chainEffect2, .chainEffect3:
            // 链式Effect处理，递归调用handleEffect
            CMiddleware.handleEffect(effect, state: self.state)
                .sink { [weak self] nextEffect in
                    guard let self = self, let nextEffect = nextEffect else { return }
                    self.handleEffect(nextEffect)
                }
                .store(in: &cancellables)
            
        case .networkDataFetched, .conditionalEffectExecuted:
            // 网络数据获取成功或条件性Effect执行后，增加计数
            self.state = CReducer.reduce(state: self.state, intent: .incrementCount)
            
        default:
            break
        }
    }
    
    public func dispatch(_ intent: CIntent) {
        intentSubject.send(intent)
    }
}
