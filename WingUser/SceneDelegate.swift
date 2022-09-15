//
//  SceneDelegate.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/03.
//

import UIKit
import Moya

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

#if DEBUG
    let viewController = UINavigationController(rootViewController: DebugViewController(style: .insetGrouped))
    let appearance = UINavigationBarAppearance().then {
      $0.configureWithDefaultBackground()
    }
    viewController.navigationBar.standardAppearance = appearance
    viewController.navigationBar.scrollEdgeAppearance = appearance
    viewController.navigationBar.compactAppearance = appearance
    if #available(iOS 15.0, *) {
      viewController.navigationBar.compactScrollEdgeAppearance = appearance
    }

    window = UIWindow(frame: UIScreen.main.bounds)
    window?.windowScene = windowScene
    window?.rootViewController = viewController
    window?.makeKeyAndVisible()
#else // RELEASE
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.windowScene = windowScene
    window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
    window?.makeKeyAndVisible()

    let viewController = UINavigationController(rootViewController: MainViewController())
    let appearance = UINavigationBarAppearance().then {
      $0.configureWithOpaqueBackground()
    }
    viewController.navigationBar.standardAppearance = appearance
    viewController.navigationBar.scrollEdgeAppearance = appearance
    viewController.navigationBar.compactAppearance = appearance
    if #available(iOS 15.0, *) {
      viewController.navigationBar.compactScrollEdgeAppearance = appearance
    }

    let realm = try! Realm()
    let user = realm.objects(UserStore.self).first

    print(user?.token)
    print(user?.identifier)

    WSNetwork.request(target: .login(token: user?.token ?? "", identifier: user?.identifier ?? "")) { [weak self] in
      let realm = try! Realm()

      switch $0 {
      case .success(let json):
        print(json)
        if let result = json["result"].bool,
           let token = json["user"]["token"].string {
          if result {
            try! realm.write {
              user?.token = token
            }
            self?.window?.rootViewController = viewController
            return
          }
        }

        guard let token = user?.token,
              let identifier = user?.identifier,
              !token.isEmpty || !identifier.isEmpty else {
                self?.window?.rootViewController = viewController
                return
              }

        try! realm.write {
          user?.token = ""
        }
        self?.window?.rootViewController?.alert(title: "로그인 에러", message: "기기 변동이 감지되어 로그아웃 되었습니다. 다시 로그인 해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          self?.window?.rootViewController = viewController
        }])
      case .failure:
        self?.window?.rootViewController?.alert(title: "로그인 에러", message: "네트워크 상태를 다시 한 번 확인해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel) { _ in
          self?.window?.rootViewController = viewController
        }])
      }
    }
#endif
  }

  func sceneDidDisconnect(_ scene: UIScene) {
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
  }

  func sceneWillResignActive(_ scene: UIScene) {
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
  }

}
