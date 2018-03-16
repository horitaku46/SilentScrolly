//
//  SecondViewController.swift
//  Example
//
//  Created by Takuma Horiuchi on 2018/02/20.
//  Copyright © 2018年 Takuma Horiuchi. All rights reserved.
//

import UIKit
import WebKit

final class SecondViewController: UIViewController, SilentScrollable {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle(showStyle: .lightContent, hideStyle: .default)
    }

    class func make() -> UIViewController {
        let viewController = UIStoryboard(name: "SecondViewController", bundle: nil)
            .instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
        viewController.hidesBottomBarWhenPushed = true
        return viewController
    }

    private var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.ignoresViewportScaleLimits = true
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.load(URLRequest(url: URL(string: "http://www.keyakizaka46.com/s/k46o/diary/member/list?ima=0000")!))
        return webView
    }()

    @IBOutlet weak var toolBar: UIToolbar! {
        didSet {
            toolBar.barTintColor = .darkGray
            toolBar.tintColor = .white
        }
    }

    var silentScrolly: SilentScrolly?

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])

        view.bringSubview(toFront: toolBar)

        let label = UILabel()
        label.text = "Second"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 17)
        navigationItem.titleView = label
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureSilentScrolly(webView.scrollView, followBottomView: toolBar)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showNavigationBar()
    }
}

extension SecondViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        followNavigationBar()
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        hideNavigationBar()
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        showNavigationBar()
        return true
    }
}

extension SecondViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showNavigationBar()
    }
}
