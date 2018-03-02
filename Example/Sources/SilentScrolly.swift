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

    var prevPositiveContentOffsetY: CGFloat = 0

    var firstNavigationBarFrameOriginY: CGFloat = 0
    var lastNavigationBarFrameOriginY: CGFloat = 0
    var firstContentInsetTop: CGFloat = 0
    var lastContentInsetTop: CGFloat = 0

    var bottomView: UIView?
    var firstBottomViewFrameOriginY: CGFloat = 0
    var lastBottomViewFrameOriginY: CGFloat = 0
    var firstContentInsetBottom: CGFloat = 0
    var lastContentInsetBottom: CGFloat = 0
}
