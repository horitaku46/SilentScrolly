<p align="center">
    <img src="https://github.com/horitaku46/Assets/blob/master/SilentScrolly/banner.png" align="center" width="600">
</p>

[![Platform](http://img.shields.io/badge/platform-iOS-blue.svg?style=flat)](https://developer.apple.com/iphone/index.action)
![Swift](https://img.shields.io/badge/Swift-4.0-orange.svg)
[![Cocoapods](https://img.shields.io/badge/Cocoapods-compatible-brightgreen.svg)](https://img.shields.io/badge/Cocoapods-compatible-brightgreen.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-Compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](http://mit-license.org)

## Overview
Scroll to hide navigationBar, tabBar and toolBar.

<p align="center">
    <img src="https://github.com/horitaku46/Assets/blob/master/SilentScrolly/normal.gif" width="300">
</p>

## Features
Adding too much `UIGestureRecognizer` to the `UIView` makes handling difficult, so it was handled by `UIScrollViewDelegate`.

## Translation
Mr. [Gargo](https://github.com/Gargo) translated [this README into Russian](http://gargo.of.by/silentscrolly/)!🙇‍♂️

## Requirements
- Xcode 9.0+
- iOS 10+
- Swift 4.0+

## Installation
### CocoaPods
```ruby
pod 'SilentScrolly'
```
### Carthage
```ruby
github "horitaku46/SilentScrolly"
```
## Usage
**See [Example](https://github.com/horitaku46/SilentScrolly/tree/master/Example), for more details.**

**《１》** If you want to change the color of the statusBar, add `func statusBarStyle(showStyle: UIStatusBarStyle, hideStyle: UIStatusBarStyle)` to the `UINavigationController`.

```swift
import UIKit

final class NavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
```

**《２》** Please describe accordingly as below.


```swift
import UIKit

final class TableViewController: UIViewController, SilentScrollable {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle(showStyle: .lightContent, hideStyle: .default) // Optional
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    var silentScrolly: SilentScrolly?

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        silentDidLayoutSubviews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureSilentScrolly(tableView, followBottomView: tabBarController?.tabBar)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        silentWillDisappear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        silentDidDisappear()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        silentWillTranstion()
    }
}

extension TableViewController: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        silentDidScroll()
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        silentDidZoom() // Optional
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        showNavigationBar() // Optional
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
```

## Author
### Takuma Horiuchi
- [Facebook](https://www.facebook.com/profile.php?id=100008388074028)
- [Twitter](https://twitter.com/horitaku_)
- [GitHub](https://github.com/horitaku46)

## License
`SilentScrolly` is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.
