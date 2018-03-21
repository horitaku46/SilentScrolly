//
//  SilentScrollable.swift
//  SilentScrolly
//
//  Created by Takuma Horiuchi on 2018/02/22.
//  Copyright © 2018年 Takuma Horiuchi. All rights reserved.
//

import UIKit

public protocol SilentScrollable: class {
    var silentScrolly: SilentScrolly? { get set }
    func statusBarStyle(showStyle: UIStatusBarStyle, hideStyle: UIStatusBarStyle) -> UIStatusBarStyle
    func configureSilentScrolly(_ scrollView: UIScrollView, followBottomView: UIView?)
    func followNavigationBar()
    func showNavigationBar()
    func hideNavigationBar()
    func navigationBarWillDisappear()
    func navigationBarDidDisappear()
}

public extension SilentScrollable where Self: UIViewController {

    public func statusBarStyle(showStyle: UIStatusBarStyle, hideStyle: UIStatusBarStyle) -> UIStatusBarStyle {
        guard let preferredStatusBarStyle = silentScrolly?.preferredStatusBarStyle else {
            /// To consider whether statusBarStyle and configureSilentScrolly precede.
            if silentScrolly == nil {
                silentScrolly = SilentScrolly()
            }
            silentScrolly?.preferredStatusBarStyle = showStyle
            silentScrolly?.showStatusBarStyle = showStyle
            silentScrolly?.hideStatusBarStyle = hideStyle
            return showStyle
        }
        return preferredStatusBarStyle
    }

    private func setStatusBarAppearanceShow() {
        guard let showStyle = silentScrolly?.showStatusBarStyle else {
            return
        }
        silentScrolly?.preferredStatusBarStyle = showStyle
        setNeedsStatusBarAppearanceUpdate()
    }

    private func setStatusBarAppearanceHide() {
        guard let hideStyle = silentScrolly?.hideStatusBarStyle else {
            return
        }
        silentScrolly?.preferredStatusBarStyle = hideStyle
        setNeedsStatusBarAppearanceUpdate()
    }

    public func configureSilentScrolly(_ scrollView: UIScrollView, followBottomView: UIView? = nil) {
        guard let navigationBarHeight = navigationController?.navigationBar.bounds.height,
            let safeAreaInsetsBottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom else {
            return
        }
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let totalHeight = statusBarHeight + navigationBarHeight

        /// To consider whether statusBarStyle and configureSilentScrolly precede.
        if silentScrolly == nil {
            silentScrolly = SilentScrolly()
        }

        silentScrolly?.scrollView = scrollView

        silentScrolly?.isNavigationBarShow = true
        silentScrolly?.isNavigationbarAnimateCompleted = true
        silentScrolly?.isTransitionCompleted = true

        silentScrolly?.showNavigationBarFrameOriginY = statusBarHeight
        silentScrolly?.hideNavigationBarFrameOriginY = -navigationBarHeight
        silentScrolly?.showScrollIndicatorInsetsTop = scrollView.scrollIndicatorInsets.top
        silentScrolly?.hideScrollIndicatorInsetsTop = scrollView.scrollIndicatorInsets.top - totalHeight

        // FIXME: Because the following adjusts it to the setting that I showed with a example
        if let bottomView = followBottomView {
            let eitherSafeAreaInsetsBottom = bottomView is UITabBar ? 0 : safeAreaInsetsBottom
            let bottomViewHeight = bottomView.bounds.height + eitherSafeAreaInsetsBottom
            silentScrolly?.bottomView = bottomView
            silentScrolly?.showBottomViewFrameOriginY = UIScreen.main.bounds.height - bottomViewHeight
            silentScrolly?.hideBottomViewFrameOriginY = UIScreen.main.bounds.height
            silentScrolly?.showContentInsetBottom = bottomView is UITabBar ? 0 : bottomViewHeight
            silentScrolly?.hideContentInsetBottom = bottomView is UITabBar ? -bottomViewHeight : -eitherSafeAreaInsetsBottom
        }

        if let isAddObserver = silentScrolly?.isAddObserver {
            if isAddObserver {
                NotificationCenter.default.addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: nil) { [weak self] in
                    self?.orientationDidChange($0)
                }
                NotificationCenter.default.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: nil) { [weak self] in
                    self?.didBecomeActive($0)
                }
            }
            silentScrolly?.isAddObserver = false
        }
    }

    private func orientationDidChange(_ notification: Notification) {
        guard isViewLoaded,
            let _ = view.window,
            let scrollView = silentScrolly?.scrollView else {
            return
        }
        // animation completed because the calculation is crazy
        adjustEitherView(scrollView, isShow: true, animated: false) { [weak self] in
            guard let me = self else { return }
            me.configureSilentScrolly(scrollView, followBottomView: me.silentScrolly?.bottomView)
        }
        adjustEitherView(scrollView, isShow: true, animated: false)
    }

    private func didBecomeActive(_ notification: Notification) {
        guard isViewLoaded,
            let _ = view.window,
            let scrollView = silentScrolly?.scrollView,
            let isShow = silentScrolly?.isNavigationBarShow else {
                return
        }
        adjustEitherView(scrollView, isShow: isShow, animated: false)
    }

    public func followNavigationBar() {
        guard let scrollView = silentScrolly?.scrollView,
            let prevPositiveContentOffsetY = silentScrolly?.prevPositiveContentOffsetY else {
                return
        }

        if scrollView.contentSize.height < scrollView.bounds.height || scrollView.isZooming {
            return
        }

        if scrollView.contentOffset.y <= 0 {
            adjustEitherView(scrollView, isShow: true)
            return
        }

        let positiveContentOffsetY = calcPositiveContentOffsetY(scrollView)
        let velocityY = scrollView.panGestureRecognizer.velocity(in: view).y

        if positiveContentOffsetY != prevPositiveContentOffsetY && scrollView.isTracking {
            if velocityY < SilentScrolly.Const.minDoNothingAdjustNavigationBarVelocityY {
                adjustEitherView(scrollView, isShow: false)
            } else if velocityY > SilentScrolly.Const.maxDoNothingAdjustNavigationBarVelocityY {
                adjustEitherView(scrollView, isShow: true)
            }
        }

        silentScrolly?.prevPositiveContentOffsetY = positiveContentOffsetY
    }

    public func showNavigationBar() {
        guard let scrollView = silentScrolly?.scrollView else {
            return
        }
        adjustEitherView(scrollView, isShow: true)
    }

    public func hideNavigationBar() {
        guard let scrollView = silentScrolly?.scrollView else {
            return
        }
        adjustEitherView(scrollView, isShow: false)
    }

    public func navigationBarWillDisappear() {
        showNavigationBar()
        silentScrolly?.isTransitionCompleted = false
    }

    public func navigationBarDidDisappear() {
        silentScrolly?.isTransitionCompleted = true
    }

    private func calcPositiveContentOffsetY(_ scrollView: UIScrollView) -> CGFloat {
        var contentOffsetY = scrollView.contentOffset.y + scrollView.contentInset.top
        contentOffsetY = contentOffsetY > 0 ? contentOffsetY : 0
        return contentOffsetY
    }

    private func adjustEitherView(_ scrollView: UIScrollView, isShow: Bool, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let isNavigationbarAnimateCompleted = silentScrolly?.isNavigationbarAnimateCompleted,
            let isTransitionCompleted = silentScrolly?.isTransitionCompleted,
            let showNavigationBarFrameOriginY = silentScrolly?.showNavigationBarFrameOriginY,
            let hideNavigationBarFrameOriginY = silentScrolly?.hideNavigationBarFrameOriginY,
            let showScrollIndicatorInsetsTop = silentScrolly?.showScrollIndicatorInsetsTop,
            let hideScrollIndicatorInsetsTop = silentScrolly?.hideScrollIndicatorInsetsTop,
            let currentNavigationBarOriginY = navigationController?.navigationBar.frame.origin.y else {
                return
        }

        if scrollView.contentSize.height < scrollView.bounds.height || !isNavigationbarAnimateCompleted || !isTransitionCompleted {
            return
        }

        let eitherNavigationBarFrameOriginY = isShow ? showNavigationBarFrameOriginY : hideNavigationBarFrameOriginY
        let eitherScrollIndicatorInsetsTop = isShow ? showScrollIndicatorInsetsTop : hideScrollIndicatorInsetsTop
        let navigationBarContentsAlpha: CGFloat = isShow ? 1 : 0

        func setPosition() {
            if silentScrolly?.preferredStatusBarStyle != nil {
                isShow ? setStatusBarAppearanceShow() : setStatusBarAppearanceHide()
            }
            navigationController?.navigationBar.frame.origin.y = eitherNavigationBarFrameOriginY
            scrollView.scrollIndicatorInsets.top = eitherScrollIndicatorInsetsTop
            setNavigationBarContentsAlpha(navigationBarContentsAlpha)
            silentScrolly?.isNavigationBarShow = isShow
        }

        if !animated {
            setPosition()
            animateBottomView(scrollView, isShow: isShow, animated: animated)
            completion?()
            return
        }

        if currentNavigationBarOriginY != eitherNavigationBarFrameOriginY && scrollView.scrollIndicatorInsets.top != eitherScrollIndicatorInsetsTop {
            silentScrolly?.isNavigationbarAnimateCompleted = false

            UIView.animate(withDuration: SilentScrolly.Const.animateDuration, animations: {
                setPosition()
            }, completion: { _ in
                self.silentScrolly?.isNavigationbarAnimateCompleted = true
            })

            animateBottomView(scrollView, isShow: isShow, animated: animated)
        }
    }

    private func animateBottomView(_ scrollView: UIScrollView, isShow: Bool, animated: Bool = true) {
        guard let bottomView = silentScrolly?.bottomView,
            let showBottomViewFrameOriginY = silentScrolly?.showBottomViewFrameOriginY,
            let hideBottomViewFrameOriginY = silentScrolly?.hideBottomViewFrameOriginY,
            let showContentInsetBottom = silentScrolly?.showContentInsetBottom,
            let hideContentInsetBottom = silentScrolly?.hideContentInsetBottom else {
            return
        }

        let eitherBottomViewFrameOriginY = isShow ? showBottomViewFrameOriginY : hideBottomViewFrameOriginY
        let eitherContentInsetBottom = isShow ? showContentInsetBottom : hideContentInsetBottom

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

    private func setNavigationBarContentsAlpha(_ alpha: CGFloat) {
        guard let navigationBar = navigationController?.navigationBar else {
            return
        }
        navigationItem.titleView?.alpha = alpha
        navigationBar.tintColor = navigationBar.tintColor.withAlphaComponent(alpha)
    }
}
