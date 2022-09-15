//
//  WebViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/30.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

  private let webView = WKWebView()

  private let url: URL

  init(url: URL) {
    self.url = url
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL.")
  }

  override func loadView() {
    self.view = webView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    webView.load(URLRequest(url: url))
  }

}
