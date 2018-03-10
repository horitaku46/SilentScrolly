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

    func configureSilentScrolly(_ scrollView: UIScrollView, followBottomView: UIView? = nil, isAddObserver: Bool = true) {
        guard let navigationBarFrame = navigationController?.navigationBar.frame else {
            return
        }
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let totalHeight = statusBarHeight + navigationBarFrame.height

        silentScrolly = SilentScrolly()
        silentScrolly?.scrollView = scrollView

        silentScrolly?.firstNavigationBarFrameOriginY = navigationBarFrame.origin.y
        silentScrolly?.lastNavigationBarFrameOriginY = -navigationBarFrame.height
        silentScrolly?.firstScrollIndicatorInsetsTop = scrollView.scrollIndicatorInsets.top
        silentScrolly?.lastScrollIndicatorInsetsTop = scrollView.scrollIndicatorInsets.top - totalHeight

        if let bottomView = followBottomView {
            silentScrolly?.bottomView = bottomView
            silentScrolly?.firstBottomViewFrameOriginY = UIScreen.main.bounds.height - bottomView.frame.height
            silentScrolly?.lastBottomViewFrameOriginY = UIScreen.main.bounds.height
            silentScrolly?.firstContentInsetBottom = bottomView is UITabBar ? 0 : bottomView.frame.height
            silentScrolly?.lastContentInsetBottom = bottomView is UITabBar ? -bottomView.frame.height : 0
        }

        if isAddObserver {
            NotificationCenter.default.addObserver(forName: .UIApplicationDidBecomeActive,
                                                   object: nil,
                                                   queue: nil) { [weak self] in
                self?.didBecomeActive($0)
            }
        }
    }

    func orientationChange() {
        guard let scrollView = silentScrolly?.scrollView else {
            return
        }
        showNavigationBar()
        configureSilentScrolly(scrollView, followBottomView: silentScrolly?.bottomView, isAddObserver: false)
    }

    func followNavigationBar() {
        guard let scrollView = silentScrolly?.scrollView,
            let prevPositiveContentOffsetY = silentScrolly?.prevPositiveContentOffsetY else {
                return
        }

        if scrollView.contentSize.height < scrollView.bounds.height {
            return
        }

        let velocityY = scrollView.panGestureRecognizer.velocity(in: view).y
        let positiveContentOffsetY = calcPositiveContentOffsetY(scrollView)

        if positiveContentOffsetY != prevPositiveContentOffsetY && scrollView.isTracking {
            isScrollUp(velocityY) ? adjustEitherView(scrollView, isShow: false) : adjustEitherView(scrollView, isShow: true)
        }

        silentScrolly?.prevPositiveContentOffsetY = positiveContentOffsetY
    }

    func decideNavigationBarState() {
        guard let scrollView = silentScrolly?.scrollView,
            let firstNavigationBarFrameOriginY = silentScrolly?.firstNavigationBarFrameOriginY,
            let currentNavigationBarOriginY = navigationController?.navigationBar.frame.origin.y else {
                return
        }

        if scrollView.contentOffset.y.isZero {
            adjustEitherView(scrollView, isShow: true)
            return
        }

        let velocityY = scrollView.panGestureRecognizer.velocity(in: view).y
        let navigationBarMoveDistance = fabs(currentNavigationBarOriginY - firstNavigationBarFrameOriginY)

        if velocityY < SilentScrolly.Const.maxFluctuateNavigationBarVelocityY {
            navigationBarMoveDistance > 0 ? adjustEitherView(scrollView, isShow: false) : adjustEitherView(scrollView, isShow: true)
        } else {
            isScrollUp(velocityY) ? adjustEitherView(scrollView, isShow: false) : adjustEitherView(scrollView, isShow: true)
        }
    }

    func showNavigationBar() {
        guard let scrollView = silentScrolly?.scrollView else {
            return
        }
        adjustEitherView(scrollView, isShow: true)
    }

    private func calcPositiveContentOffsetY(_ scrollView: UIScrollView) -> CGFloat {
        var contentOffsetY = scrollView.contentOffset.y + scrollView.contentInset.top
        contentOffsetY = contentOffsetY > 0 ? contentOffsetY : 0
        return contentOffsetY
    }

    private func isScrollUp(_ velocityY: CGFloat) -> Bool {
        return velocityY <= 0
    }

    private func adjustEitherView(_ scrollView: UIScrollView, isShow: Bool, animated: Bool = true) {
        guard let isNavigationbarAnimateCompleted = silentScrolly?.isNavigationbarAnimateCompleted,
            let firstNavigationBarFrameOriginY = silentScrolly?.firstNavigationBarFrameOriginY,
            let lastNavigationBarFrameOriginY = silentScrolly?.lastNavigationBarFrameOriginY,
            let firstScrollIndicatorInsetsTop = silentScrolly?.firstScrollIndicatorInsetsTop,
            let lastScrollIndicatorInsetsTop = silentScrolly?.lastScrollIndicatorInsetsTop,
            let currentNavigationBarOriginY = navigationController?.navigationBar.frame.origin.y else {
                return
        }

        if !isNavigationbarAnimateCompleted {
            return
        }

        let eitherNavigationBarFrameOriginY = isShow ? firstNavigationBarFrameOriginY : lastNavigationBarFrameOriginY
        let eitherScrollIndicatorInsetsTop = isShow ? firstScrollIndicatorInsetsTop : lastScrollIndicatorInsetsTop
        let navigationBarContentsAlpha: CGFloat = isShow ? 1 : 0

        func setPosition() {
            navigationController?.navigationBar.frame.origin.y = eitherNavigationBarFrameOriginY
            scrollView.scrollIndicatorInsets.top = eitherScrollIndicatorInsetsTop
            setNavigationBarContentsAlpha(navigationBarContentsAlpha)

            silentScrolly?.isNavigationBarShow = isShow
        }

        if !animated {
            setPosition()
            animateBottomView(scrollView, isShow: isShow, animated: animated)
            return
        }

        if currentNavigationBarOriginY != eitherNavigationBarFrameOriginY && scrollView.scrollIndicatorInsets.top != eitherScrollIndicatorInsetsTop {
            silentScrolly?.isNavigationbarAnimateCompleted = false
            isShow ? self.setNavigationBarAlpha(isClear: false) : nil

            UIView.animate(withDuration: SilentScrolly.Const.animateDuration, animations: {
                setPosition()
            }, completion: { _ in
                isShow ? nil : self.setNavigationBarAlpha(isClear: true)
                self.silentScrolly?.isNavigationbarAnimateCompleted = true
            })

            animateBottomView(scrollView, isShow: isShow, animated: animated)
        }
    }

    private func animateBottomView(_ scrollView: UIScrollView, isShow: Bool, animated: Bool = true) {
        guard let bottomView = silentScrolly?.bottomView,
            let firstBottomViewFrameOriginY = silentScrolly?.firstBottomViewFrameOriginY,
            let lastBottomViewFrameOriginY = silentScrolly?.lastBottomViewFrameOriginY,
            let firstContentInsetBottom = silentScrolly?.firstContentInsetBottom,
            let lastContentInsetBottom = silentScrolly?.lastContentInsetBottom else {
            return
        }

        let eitherBottomViewFrameOriginY = isShow ? firstBottomViewFrameOriginY : lastBottomViewFrameOriginY
        let eitherContentInsetBottom = isShow ? firstContentInsetBottom : lastContentInsetBottom

        func setPosition() {
            bottomView.frame.origin.y = eitherBottomViewFrameOriginY
            scrollView.contentInset.bottom = eitherContentInsetBottom
            scrollView.scrollIndicatorInsets.bottom = eitherContentInsetBottom
        }

        if !animated {
            setPosition()
            return
        }

        UIView.animate(withDuration: SilentScrolly.Const.animateDuration) {
            setPosition()
        }
    }

    private func setNavigationBarAlpha(isClear: Bool) {
        let image = isClear ? UIImage() : nil
        navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        navigationController?.navigationBar.shadowImage = image
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

    private func didBecomeActive(_ notification: Notification) {
        if isViewLoaded && view.window != nil {
            guard let scrollView = silentScrolly?.scrollView,
                let isShow = silentScrolly?.isNavigationBarShow else {
                    return
            }
            adjustEitherView(scrollView, isShow: isShow, animated: false)
        }
    }
}
