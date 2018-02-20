//
//  FirstViewController.swift
//  Example
//
//  Created by Takuma Horiuchi on 2018/02/20.
//  Copyright © 2018年 Takuma Horiuchi. All rights reserved.
//

import UIKit
import WebKit

final class FirstViewController: UIViewController, UIScrollViewDelegate {

    private var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        let url = URL(string: "https://www.apple.com/")
        let urlRequest = URLRequest(url: url!)
        webView.load(urlRequest)
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.scrollView.contentInset.top = 64
        webView.scrollView.scrollIndicatorInsets.top = 64
        webView.scrollView.delegate = self
        view.addSubview(webView)

        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: view.topAnchor),
                webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
                ])
        } else {
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: view.topAnchor),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
        }

        let rightShowBarButtonItem = UIBarButtonItem(title: "Show",
                                                     style: .plain,
                                                     target: self,
                                                     action: #selector(tapRightShowBarButtonItem))
        navigationItem.setRightBarButton(rightShowBarButtonItem, animated: true)

        navigationController?.navigationBar.barTintColor = .green
        navigationItem.title = "First"
    }

    @objc private func tapRightShowBarButtonItem() {
        let viewController = SecondViewController.make()
        navigationController?.show(viewController, sender: nil)
    }

    private func calcNavigationBarOriginY(_ contentOffsetY: CGFloat) -> CGFloat {
        if contentOffsetY <= 0 {
            return 20
        } else if 44 <= contentOffsetY {
            return -24
        }
        return 20 - contentOffsetY
    }

    private func calcWebViewInsetY(_ contentOffsetY: CGFloat) -> CGFloat {
        if contentOffsetY <= 0 {
            return 64
        } else if 44 <= contentOffsetY {
            return 20
        }
        return 64 - contentOffsetY
    }

    func calcNavigationBarAlpha(_ contentOffsetY: CGFloat) -> CGFloat {
        if contentOffsetY <= 0 {
            return 1
        } else if 44 <= contentOffsetY {
            return 0
        }
        return 1 - (contentOffsetY / 44)
    }

    private var prevContentOffSetY: CGFloat = 0

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let navigationBar = navigationController?.navigationBar else { return }

        let offSetY = scrollView.contentOffset.y + scrollView.contentInset.top
        webView.scrollView.scrollIndicatorInsets.top = calcWebViewInsetY(offSetY)
        webView.scrollView.contentInset.top = calcWebViewInsetY(offSetY)
        navigationBar.frame.origin.y = calcNavigationBarOriginY(offSetY)

        let alpha = calcNavigationBarAlpha(offSetY)
        navigationItem.titleView?.alpha = alpha
        navigationBar.tintColor = navigationBar.tintColor.withAlphaComponent(alpha)
        if let titleColor = navigationBar.titleTextAttributes?[NSAttributedStringKey.foregroundColor] as? UIColor {
            navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : titleColor.withAlphaComponent(alpha)]
        } else {
            navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black.withAlphaComponent(alpha)]
        }
    }
}
