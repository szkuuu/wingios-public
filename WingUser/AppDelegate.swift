//
//  AppDelegate.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/03.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let realm = try! Realm()
    var userStore = realm.objects(UserStore.self)

    if userStore.isEmpty {
      try! realm.write {
        realm.add(UserStore())
      }
      userStore = realm.objects(UserStore.self)
    }

    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
  }

}
