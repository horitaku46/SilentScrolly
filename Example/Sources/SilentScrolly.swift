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

    var preferredStatusBarStyle: UIStatusBarStyle? = nil
    var showStatusBarStyle: UIStatusBarStyle = .default
    var hideStatusBarStyle: UIStatusBarStyle = .default

    var scrollView: UIScrollView? = nil

    var isNavigationBarShow = true
    var isNavigationbarAnimateCompleted = true

    var prevPositiveContentOffsetY: CGFloat = 0

    var showNavigationBarFrameOriginY: CGFloat = 0
    var hideNavigationBarFrameOriginY: CGFloat = 0
    var showScrollIndicatorInsetsTop: CGFloat = 0
    var hideScrollIndicatorInsetsTop: CGFloat = 0

    var bottomView: UIView?
    var showBottomViewFrameOriginY: CGFloat = 0
    var hideBottomViewFrameOriginY: CGFloat = 0
    var showContentInsetBottom: CGFloat = 0
    var hideContentInsetBottom: CGFloat = 0
}
