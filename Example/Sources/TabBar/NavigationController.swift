//
//  NavigationController.swift
//  Example
//
//  Created by Takuma Horiuchi on 2018/03/11.
//  Copyright © 2018年 Takuma Horiuchi. All rights reserved.
//

import UIKit

final class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barTintColor = .darkGray
        navigationBar.tintColor = .white
    }
}
