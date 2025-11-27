//
//  CView.swift
//  Pods-FMModuleC_Example
//
//  Created by FumingLeo on 2025/11/21.
//

import SwiftUI

/// MVI架构中的View，负责UI展示和用户交互
public struct CView: View {
    @StateObject private var viewModel = CViewModel()
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                sectionHeader("原有场景")
                counterSection
                originalButtonsSection
                
                Divider()
                
                sectionHeader("场景1: 加载状态和错误处理")
                loadingAndErrorSection
                
                Divider()
                
                sectionHeader("场景2: 列表数据和分页加载")
                listAndPaginationSection
                
                Divider()
                
                sectionHeader("场景3: 搜索功能（防抖）")
                searchSection
                
                Divider()
                
                sectionHeader("场景4: 表单验证")
                formValidationSection
                
                Divider()
                
                sectionHeader("场景5: 撤销/重做功能")
                undoRedoSection
                
                Divider()
                
                sectionHeader("场景6: 条件性操作")
                conditionalOperationSection
                
                Divider()
                
                sectionHeader("场景7: 链式操作（Effect链）")
                chainOperationSection
            }
            .padding()
        }
        .overlay(
            Group {
                // Toast消息提示
                if let toastMessage = viewModel.state.toastMessage {
                    VStack {
                        Spacer()
                        Text(toastMessage)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                            .padding(.bottom, 50)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                
                // 加载指示器
                if viewModel.state.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        if let message = viewModel.state.loadingMessage {
                            Text(message)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(radius: 10)
                }
            }
            .animation(.easeInOut, value: viewModel.state.toastMessage)
            .animation(.easeInOut, value: viewModel.state.isLoading)
        )
    }
    
    // MARK: - 视图组件
    
    private var counterSection: some View {
        VStack {
            Text("计数: \(viewModel.state.count)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.primary)
        }
    }
    
    private var originalButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                viewModel.dispatch(.incrementCount)
            }) {
                Text("点击加1")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Button(action: {
                viewModel.dispatch(.incrementCountFromNetwork)
            }) {
                Text("网络获取后加1")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .cornerRadius(8)
            }
            
            Button(action: {
                viewModel.dispatch(.showTime)
            }) {
                Text("显示时间")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .cornerRadius(8)
            }
        }
    }
    
    private var loadingAndErrorSection: some View {
        VStack(spacing: 12) {
            if let errorMessage = viewModel.state.errorMessage {
                HStack {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                    Spacer()
                    Button("清除") {
                        viewModel.dispatch(.clearError)
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
            
            Button(action: {
                viewModel.dispatch(.retryLastOperation)
            }) {
                Text("重试上次操作")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.purple)
                    .cornerRadius(8)
            }
        }
    }
    
    private var listAndPaginationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                viewModel.dispatch(.loadItems)
            }) {
                Text("加载列表数据")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.indigo)
                    .cornerRadius(8)
            }
            
            if !viewModel.state.displayItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.state.displayItems.prefix(5)) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .font(.system(size: 16, weight: .medium))
                                Text(item.subtitle)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                    }
                    
                    if viewModel.state.hasMorePages {
                        Button(action: {
                            viewModel.dispatch(.loadMoreItems)
                        }) {
                            Text("加载更多 (\(viewModel.state.items.count) 项)")
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
    }
    
    private var searchSection: some View {
        VStack(spacing: 12) {
            TextField("搜索...", text: Binding(
                get: { viewModel.state.searchText },
                set: { viewModel.dispatch(.searchTextChanged($0)) }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            
            if !viewModel.state.searchResults.isEmpty {
                Text("找到 \(viewModel.state.searchResults.count) 个结果")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var formValidationSection: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                TextField("输入文本（至少3个字符）", text: Binding(
                    get: { viewModel.state.inputText },
                    set: { viewModel.dispatch(.inputTextChanged($0)) }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if let inputError = viewModel.state.inputError {
                    Text(inputError)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
            
            Button(action: {
                viewModel.dispatch(.submitForm)
            }) {
                Text("提交表单")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.teal)
                    .cornerRadius(8)
            }
        }
    }
    
    private var undoRedoSection: some View {
        HStack(spacing: 12) {
            Button(action: {
                viewModel.dispatch(.undo)
            }) {
                Text("撤销")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(viewModel.state.canUndo ? Color.gray : Color.gray.opacity(0.5))
                    .cornerRadius(8)
            }
            .disabled(!viewModel.state.canUndo)
            
            Button(action: {
                viewModel.dispatch(.saveToHistory)
            }) {
                Text("保存状态")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.brown)
                    .cornerRadius(8)
            }
            
            Button(action: {
                viewModel.dispatch(.redo)
            }) {
                Text("重做")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(viewModel.state.canRedo ? Color.gray : Color.gray.opacity(0.5))
                    .cornerRadius(8)
            }
            .disabled(!viewModel.state.canRedo)
        }
    }
    
    private var conditionalOperationSection: some View {
        VStack(spacing: 12) {
            Text("当前计数: \(viewModel.state.count)")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Button(action: {
                viewModel.dispatch(.conditionalIncrement)
            }) {
                Text("条件性增加（仅当 < 10 时）")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.pink)
                    .cornerRadius(8)
            }
        }
    }
    
    private var chainOperationSection: some View {
        Button(action: {
            viewModel.dispatch(.startChainOperation)
        }) {
            Text("启动链式操作（Effect链）")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.cyan)
                .cornerRadius(8)
        }
    }
    
    // MARK: - 辅助方法
    
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.top, 8)
    }
}
