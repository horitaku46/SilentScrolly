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

    class func make() -> UIViewController {
        let viewController = UIStoryboard(name: "SecondViewController", bundle: nil)
            .instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
        return viewController
    }
    
    @IBOutlet weak var webView: WKWebView! {
        didSet {
            webView.navigationDelegate = self
            webView.scrollView.delegate = self
            let url = URL(string: "http://www.keyakizaka46.com/s/k46o/diary/member/list?ima=0000")
            let urlRequest = URLRequest(url: url!)
            webView.load(urlRequest)
        }
    }

    @IBOutlet weak var toolBar: UIToolbar!

    var silentScrolly: SilentScrolly?

    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel()
        label.text = "Second"
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

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        decideNavigationBarState()
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
