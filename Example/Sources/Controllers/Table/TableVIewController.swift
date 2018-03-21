//
//  TableVIewController.swift
//  Example
//
//  Created by Takuma Horiuchi on 2018/03/21.
//  Copyright © 2018年 Takuma Horiuchi. All rights reserved.
//

import UIKit

final class TableViewController: UIViewController, SilentScrollable {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle(showStyle: .lightContent, hideStyle: .default)
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    var silentScrolly: SilentScrolly?

    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel()
        label.text = "Table"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 17)
        navigationItem.titleView = label
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureSilentScrolly(tableView, followBottomView: tabBarController?.tabBar)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWillDisappear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationBarDidDisappear()
    }
}

extension TableViewController: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        followNavigationBar()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        showNavigationBar()
        return true
    }
}

extension TableViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Row: \(indexPath.row)"
        return cell
    }
}
