//
//  FMModuleC.swift
//  FMModuleC
//
//  Created by FumingLeo on 2025/11/21.
//

import Foundation
import FMModuleCenter

@objc public class FMModuleC: NSObject, @preconcurrency FMModuleCenterProtocol {
    // 注册组件服务
    @MainActor @objc public static func registerService() {
        FMModuleCenter.shared.register(FMModuleCServiceProtocol.self, serviceImpl: FMModuleCServiceImpl())
        print("✅ 已注册服务：\(FMModuleCServiceProtocol.self)")
    }
}

// 组件对外提供的服务
public class FMModuleCServiceImpl:  FMModuleCServiceProtocol {
    public init() {}
    
    public func getCViewController() -> UIViewController {
        return CHostController()
    }
}
