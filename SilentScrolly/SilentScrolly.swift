//
//  SilentScrolly.swift
//  SilentScrolly
//
//  Created by Takuma Horiuchi on 2018/02/22.
//  Copyright © 2018年 Takuma Horiuchi. All rights reserved.
//

import UIKit

public struct SilentScrolly {

    public enum Const {
        public static let maxFluctuateNavigationBarVelocityY: CGFloat = 100
        public static let animateDuration: TimeInterval = 0.3
    }

    public var preferredStatusBarStyle: UIStatusBarStyle? = nil
    public var showStatusBarStyle: UIStatusBarStyle = .default
    public var hideStatusBarStyle: UIStatusBarStyle = .default

    public var scrollView: UIScrollView? = nil

    public var isNavigationBarShow = true
    public var isNavigationbarAnimateCompleted = true

    public var prevPositiveContentOffsetY: CGFloat = 0

    public var showNavigationBarFrameOriginY: CGFloat = 0
    public var hideNavigationBarFrameOriginY: CGFloat = 0
    public var showScrollIndicatorInsetsTop: CGFloat = 0
    public var hideScrollIndicatorInsetsTop: CGFloat = 0

    public var bottomView: UIView?
    public var showBottomViewFrameOriginY: CGFloat = 0
    public var hideBottomViewFrameOriginY: CGFloat = 0
    public var showContentInsetBottom: CGFloat = 0
    public var hideContentInsetBottom: CGFloat = 0
}
