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

    func setSilentScrolly(_ scrollView: UIScrollView, followBottomView: UIView? = nil) {
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

        if let bottomView = followBottomView {
            silentScrolly?.bottomView = bottomView
            silentScrolly?.firstBottomViewFrameOriginY = bottomView.frame.origin.y
            silentScrolly?.lastBottomViewFrameOriginY = bottomView.frame.origin.y + bottomView.frame.height
            silentScrolly?.firstContentInsetBottom = scrollView.contentInset.bottom
            silentScrolly?.lastContentInsetBottom = scrollView.contentInset.bottom - bottomView.frame.height
        }
    }

    func followNavigationBar(_ scrollView: UIScrollView) {
        if scrollView.contentSize.height < scrollView.bounds.height {
            return
        }

        guard let prevPositiveContentOffsetY = silentScrolly?.prevPositiveContentOffsetY else {
            return
        }

        let velocityY = scrollView.panGestureRecognizer.velocity(in: view).y
        let positiveContentOffsetY = calcPositiveContentOffsetY(scrollView)

        if positiveContentOffsetY != prevPositiveContentOffsetY && scrollView.isTracking {
            isScrollUp(velocityY) ? adjustEitherView(scrollView, isShow: false) : adjustEitherView(scrollView, isShow: true)
        }

        silentScrolly?.prevPositiveContentOffsetY = positiveContentOffsetY
    }

    func decideNavigationBarState(_ scrollView: UIScrollView) {
        guard let firstNavigationBarFrameOriginY = silentScrolly?.firstNavigationBarFrameOriginY,
            let currentNavigationBarOriginY = navigationController?.navigationBar.frame.origin.y else {
                return
        }

        if scrollView.contentOffset.y.isZero {
            adjustEitherView(scrollView, isShow: true)
            return
        }

        let velocityY = scrollView.panGestureRecognizer.velocity(in: view).y
        let firstMoveDistance = fabs(currentNavigationBarOriginY - firstNavigationBarFrameOriginY)

        if velocityY < SilentScrolly.Const.maxFluctuateNavigationBarVelocityY {
            firstMoveDistance > 0 ? adjustEitherView(scrollView, isShow: false) : adjustEitherView(scrollView, isShow: true)
        } else {
            isScrollUp(velocityY) ? adjustEitherView(scrollView, isShow: false) : adjustEitherView(scrollView, isShow: true)
        }
    }

    private func calcPositiveContentOffsetY(_ scrollView: UIScrollView) -> CGFloat {
        var contentOffsetY = scrollView.contentOffset.y + scrollView.contentInset.top
        contentOffsetY = contentOffsetY > 0 ? contentOffsetY : 0
        return contentOffsetY
    }

    private func isScrollUp(_ velocityY: CGFloat) -> Bool {
        return velocityY <= 0
    }

    private func adjustEitherView(_ scrollView: UIScrollView, isShow: Bool) {
        guard let firstNavigationBarFrameOriginY = silentScrolly?.firstNavigationBarFrameOriginY,
            let lastNavigationBarFrameOriginY = silentScrolly?.lastNavigationBarFrameOriginY,
            let firstContentInsetTop = silentScrolly?.firstContentInsetTop,
            let lastContentInsetTop = silentScrolly?.lastContentInsetTop,
            let currentNavigationBarOriginY = navigationController?.navigationBar.frame.origin.y else {
                return
        }

        let eitherNavigationBarFrameOriginY = isShow ? firstNavigationBarFrameOriginY : lastNavigationBarFrameOriginY
        let eitherContentInsetTop = isShow ? firstContentInsetTop : lastContentInsetTop
        let navigationBarContentsAlpha: CGFloat = isShow ? 1 : 0

        if currentNavigationBarOriginY != eitherNavigationBarFrameOriginY && scrollView.contentInset.top != eitherContentInsetTop {
            UIView.animate(withDuration: SilentScrolly.Const.animateDuration) {
                self.navigationController?.navigationBar.frame.origin.y = eitherNavigationBarFrameOriginY
                scrollView.contentInset.top = eitherContentInsetTop
                scrollView.scrollIndicatorInsets.top = eitherContentInsetTop
                self.setNavigationBarContentsAlpha(navigationBarContentsAlpha)
            }

            animateBottomView(scrollView, isShow: isShow)
        }
    }

    private func animateBottomView(_ scrollView: UIScrollView, isShow: Bool) {
        guard let _ = silentScrolly?.bottomView,
            let firstBottomViewFrameOriginY = silentScrolly?.firstBottomViewFrameOriginY,
            let lastBottomViewFrameOriginY = silentScrolly?.lastBottomViewFrameOriginY,
            let firstContentInsetBottom = silentScrolly?.firstContentInsetBottom,
            let lastContentInsetBottom = silentScrolly?.lastContentInsetBottom else {
            return
        }

        let eitherBottomViewFrameOriginY = isShow ? firstBottomViewFrameOriginY : lastBottomViewFrameOriginY
        let eitherContentInsetBottom = isShow ? firstContentInsetBottom : lastContentInsetBottom

        UIView.animate(withDuration: SilentScrolly.Const.animateDuration) {
            self.tabBarController?.tabBar.frame.origin.y = eitherBottomViewFrameOriginY
            scrollView.contentInset.bottom = eitherContentInsetBottom
            scrollView.scrollIndicatorInsets.bottom = eitherContentInsetBottom
        }
    }

    private func setNavigationBarContentsAlpha(_ alpha: CGFloat) {
        guard let navigationBar = navigationController?.navigationBar else {
            return
        }
        navigationItem.titleView?.alpha = alpha
        navigationBar.tintColor = navigationBar.tintColor.withAlphaComponent(alpha)
        if let titleColor = navigationBar.titleTextAttributes?[.foregroundColor] as? UIColor {
            navigationBar.titleTextAttributes = [.foregroundColor : titleColor.withAlphaComponent(alpha)]
        } else {
            navigationBar.titleTextAttributes = [.foregroundColor : UIColor.black.withAlphaComponent(alpha)]
        }
    }
}
