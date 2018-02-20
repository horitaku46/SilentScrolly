//
//  TabBarController.swift
//  Example
//
//  Created by Takuma Horiuchi on 2018/02/20.
//  Copyright © 2018年 Takuma Horiuchi. All rights reserved.
//

import UIKit

final class TabBarController: UITabBarController {

    private enum Const {
        static let tabBarItemTitles = ["First"]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for (index, title) in Const.tabBarItemTitles.enumerated() {
            tabBar.items?[index].title = title
        }
    }
}
