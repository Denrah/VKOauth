//
//  WebViewViewController.swift
//  VKOAuth
//
//  Created by National Team on 01.11.2021.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {
  @IBOutlet weak var webView: WKWebView!
  
  var onDidReceiveToken: ((String?) -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    webView.navigationDelegate = self
    
    if let url = URL(string: "https://oauth.vk.com/authorize?client_id=7988922&response_type=token&redirect_uri=https://oauth.vk.com/blank.html") {
      let request = URLRequest(url: url)
      webView.load(request)
    }
    
    // Do any additional setup after loading the view.
  }
}

extension WebViewViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
               decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    guard let url = navigationAction.request.url else {
      decisionHandler(.allow)
      return
    }
    if ((url.host ?? "") + url.path) == "oauth.vk.com/blank.html",
       let newURL = URL(string: url.absoluteString.replacingOccurrences(of: "#", with: "?")) {
      decisionHandler(.cancel)
      let components = URLComponents(url: newURL, resolvingAgainstBaseURL: true)
      let token = components?.queryItems?.first { $0.name == "access_token" }?.value
      onDidReceiveToken?(token)
      dismiss(animated: true, completion: nil)
      return
    }
    decisionHandler(.allow)
  }
}
