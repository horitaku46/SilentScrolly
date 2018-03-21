//
//  WebViewController.swift
//  Example
//
//  Created by Takuma Horiuchi on 2018/02/20.
//  Copyright © 2018年 Takuma Horiuchi. All rights reserved.
//

import UIKit
import WebKit

final class WebViewController: UIViewController, SilentScrollable {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle(showStyle: .lightContent, hideStyle: .default)
    }

    @IBOutlet weak var webView: WKWebView! {
        didSet {
            webView.navigationDelegate = self
            webView.scrollView.delegate = self
            let url = URL(string: "http://www.keyakizaka46.com/")
            let urlRequest = URLRequest(url: url!)
            webView.load(urlRequest)
        }
    }

    var silentScrolly: SilentScrolly?

    override func viewDidLoad() {
        super.viewDidLoad()

        let rightShowBarButtonItem = UIBarButtonItem(title: "Show",
                                                     style: .plain,
                                                     target: self,
                                                     action: #selector(tapRightShowBarButtonItem))
        navigationItem.setRightBarButton(rightShowBarButtonItem, animated: true)

        let label = UILabel()
        label.text = "Web"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 17)
        navigationItem.titleView = label
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureSilentScrolly(webView.scrollView)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationBarWillDisappear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationBarDidDisappear()
    }

    @objc private func tapRightShowBarButtonItem() {
        let viewController = ToolBarViewController.make()
        navigationController?.show(viewController, sender: nil)
    }
}

extension WebViewController: UIScrollViewDelegate {

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

extension WebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showNavigationBar()
    }
}
