//
//  CHostController.swift
//  FMModuleC
//
//  Created by FumingLeo on 2025/11/21.
//

import SwiftUI

public class CHostController: UIHostingController<CView> {
    
    public init() {
        let view = CView()
        super.init(rootView: view)
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
