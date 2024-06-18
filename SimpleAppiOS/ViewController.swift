//
//  ViewController.swift
//  Simple App iOS
//
//  Created by Ahmed Ali on 18/06/2024.
//

import UIKit
import IonicPortals

extension Portal {
    static let simpleDemo = Portal(
        name: "simple_demo"
    )
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        self.view = PortalUIView(portal: .simpleDemo)
    }
}
