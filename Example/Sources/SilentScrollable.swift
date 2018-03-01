//
//  SilentScrollable.swift
//  Example
//
//  Created by Takuma Horiuchi on 2018/02/22.
//  Copyright © 2018年 Takuma Horiuchi. All rights reserved.
//

import UIKit

protocol SilentScrollable: class {
    var silentScrolly: SilentScrolly? { get set }
}

extension SilentScrollable where Self: UIViewController {

    func setSilentScrolly(_ scrollView: UIScrollView) {
        guard let navigationBarFrame = navigationController?.navigationBar.frame else {
            return
        }
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let totalHeight = statusBarHeight + navigationBarFrame.height

        silentScrolly = SilentScrolly()

        silentScrolly?.firstNavigationBarFrameOriginY = navigationBarFrame.origin.y
        silentScrolly?.lastNavigationBarFrameOriginY = -navigationBarFrame.height

        silentScrolly?.firstContentInsetTop = scrollView.contentInset.top
        silentScrolly?.lastContentInsetTop = scrollView.contentInset.top - totalHeight
    }

    func followNavigationBar(_ scrollView: UIScrollView) {
        if scrollView.contentSize.height < scrollView.bounds.height {
            return
        }

        guard let prevPositiveContentOffsetY = silentScrolly?.prevPositiveContentOffsetY else {
            return
        }
        let velocityY = scrollView.panGestureRecognizer.velocity(in: view).y
        let isScrollUp = velocityY < 0
        let isInteractive = fabs(velocityY) < SilentScrolly.Const.maxInteractiveVelocityY

        let positiveContentOffsetY = calcPositiveContentOffsetY(scrollView)

        if positiveContentOffsetY != prevPositiveContentOffsetY && scrollView.isTracking {
            if isScrollUp {
                adjustNavigationBar(scrollView, isShow: false, isInteractive: isInteractive)
            } else {
                adjustNavigationBar(scrollView, isShow: true, isInteractive: isInteractive)
            }
        }

        silentScrolly?.prevPositiveContentOffsetY = positiveContentOffsetY
    }

    func decideNavigationBarState(_ scrollView: UIScrollView) {
        guard let firstNavigationBarFrameOriginY = silentScrolly?.firstNavigationBarFrameOriginY,
            let lastNavigationBarFrameOriginY = silentScrolly?.lastNavigationBarFrameOriginY,
            let currentNavigationBarOriginY = navigationController?.navigationBar.frame.origin.y else {
                return
        }
        let firstMoveDistance = fabs(currentNavigationBarOriginY - firstNavigationBarFrameOriginY)
        let lastMoveDidstance = fabs(currentNavigationBarOriginY - lastNavigationBarFrameOriginY)

        if firstMoveDistance > lastMoveDidstance {
            adjustNavigationBar(scrollView, isShow: false, isInteractive: false)
        } else {
            adjustNavigationBar(scrollView, isShow: true, isInteractive: false)
        }
    }

    private func calcPositiveContentOffsetY(_ scrollView: UIScrollView) -> CGFloat {
        var contentOffsetY = scrollView.contentOffset.y + scrollView.contentInset.top
        contentOffsetY = contentOffsetY > 0 ? contentOffsetY : 0
        return contentOffsetY
    }

    private func adjustNavigationBar(_ scrollView: UIScrollView, isShow: Bool, isInteractive: Bool) {
        guard let firstNavigationBarFrameOriginY = silentScrolly?.firstNavigationBarFrameOriginY,
            let lastNavigationBarFrameOriginY = silentScrolly?.lastNavigationBarFrameOriginY,
            let firstContentInsetTop = silentScrolly?.firstContentInsetTop,
            let lastContentInsetTop = silentScrolly?.lastContentInsetTop,
            let currentNavigationBarOriginY = navigationController?.navigationBar.frame.origin.y else {
                return
        }

        let eitherNavigationBarFrameOriginY = isShow ? firstNavigationBarFrameOriginY : lastNavigationBarFrameOriginY
        let eitherContentInsetTop = isShow ? firstContentInsetTop : lastContentInsetTop
        let fluctuateNumber: CGFloat = isShow ? 1 : -1

        if isInteractive {
            if currentNavigationBarOriginY != eitherNavigationBarFrameOriginY && scrollView.contentInset.top != eitherContentInsetTop {
                navigationController?.navigationBar.frame.origin.y += fluctuateNumber

                let insetTop = scrollView.contentInset.top + fluctuateNumber
                scrollView.contentInset.top = insetTop
                scrollView.scrollIndicatorInsets.top = insetTop
            }

        } else {
            UIView.animate(withDuration: SilentScrolly.Const.animateDuration) {
                self.navigationController?.navigationBar.frame.origin.y = eitherNavigationBarFrameOriginY
                scrollView.contentInset.top = eitherContentInsetTop
                scrollView.scrollIndicatorInsets.top = eitherContentInsetTop
            }
        }
    }
}
