//
//  ViewController.swift
//  VKOAuth
//
//  Created by National Team on 01.11.2021.
//

import UIKit

struct Profile: Codable {
  let first_name: String?
  let last_name: String?
}

struct ProfileResponse: Codable {
  let response: Profile?
}

class ViewController: UIViewController {
  @IBOutlet weak var tokenLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  @IBAction func signIn(_ sender: Any) {
    let vc = WebViewViewController()
    vc.onDidReceiveToken = { [weak self] token in
      self?.tokenLabel.text = "Token: \(token ?? "nil")"
      self?.onReceiveToken(token)
    }
    present(vc, animated: true, completion: nil)
  }
  
  private func onReceiveToken(_ token: String?) {
    guard let url = URL(string: "https://api.vk.com/method/account.getProfileInfo?access_token=\(token ?? "")&v=5.131") else { return }
    
    Task {
      let (data, _) = try await URLSession.shared.data(from: url)
      let profile = try? JSONDecoder().decode(ProfileResponse.self, from: data)
      self.update(with: profile?.response)
    }
  }
  
  @MainActor private func update(with profile: Profile?) {
    tokenLabel.text = "\(tokenLabel.text ?? "")\nUser: \(profile?.first_name ?? "") \(profile?.last_name ?? "")"
  }
}

