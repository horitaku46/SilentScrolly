//
//  FirstViewController.swift
//  Example
//
//  Created by Takuma Horiuchi on 2018/02/20.
//  Copyright © 2018年 Takuma Horiuchi. All rights reserved.
//

import UIKit
import WebKit

final class FirstViewController: UIViewController, SilentScrollable {

    private var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        let url = URL(string: "http://www.keyakizaka46.com/s/k46o/diary/member/list?ima=0000")
        let urlRequest = URLRequest(url: url!)
        webView.load(urlRequest)
        return webView
    }()

    var silentScrolly: SilentScrolly?

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self
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

        let label = UILabel()
        label.text = "First"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        navigationItem.titleView = label
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSilentScrolly(webView.scrollView, followBottomView: tabBarController?.tabBar)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        orientationChange()
    }

    @objc private func tapRightShowBarButtonItem() {
        let viewController = SecondViewController.make()
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.show(viewController, sender: nil)
    }
}

extension FirstViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        followNavigationBar()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        decideNavigationBarState()
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        showNavigationBar()
        return true
    }
}

extension FirstViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showNavigationBar()
    }
}
