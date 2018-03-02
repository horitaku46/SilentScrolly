//
//  SilentScrolly.swift
//  Example
//
//  Created by Takuma Horiuchi on 2018/02/22.
//  Copyright © 2018年 Takuma Horiuchi. All rights reserved.
//

import UIKit

struct SilentScrolly {

    enum Const {
        static let maxFluctuateNavigationBarVelocityY: CGFloat = 100
        static let animateDuration: TimeInterval = 0.3
    }

    enum BarState: Int {
        case show
        case incomplete
        case hide
    }

    var prevPositiveContentOffsetY: CGFloat = 0

    var firstNavigationBarFrameOriginY: CGFloat = 0
    var lastNavigationBarFrameOriginY: CGFloat = 0

    var firstContentInsetTop: CGFloat = 0
    var lastContentInsetTop: CGFloat = 0

    var firstScrollIndicatorInsetsTop: CGFloat = 0
    var lastScrollIndicatorInsetsTop: CGFloat = 0

    var barState: BarState = .show
}
