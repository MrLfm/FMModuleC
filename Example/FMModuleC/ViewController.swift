//
//  ViewController.swift
//  FMModuleC
//
//  Created by MrLfm on 11/21/2025.
//  Copyright (c) 2025 MrLfm. All rights reserved.
//

import UIKit
import FMModuleCenter

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func presentCViewController(_ sender: Any) {
        let vc = FMModuleCenter.shared.get(FMModuleCServiceProtocol.self)?.getCViewController()
        if let vc = vc {
            present(vc, animated: true)
        }
        else {
            print("getCViewController()失败！没有注册服务：FMModuleCServiceProtocol")
        }
    }
}

