//
//  MainViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/03.
//

import UIKit

class MainViewController: UITabBarController {

  private lazy var homeViewController: HomeViewController = HomeViewController().then {
    let image = UIImage(systemName: "house")
    $0.tabBarItem = UITabBarItem(title: "홈", image: image, selectedImage: image)
  }

  private lazy var stateViewController: StateViewController = StateViewController().then {
    let image = UIImage(systemName: "minus.plus.batteryblock")
    $0.tabBarItem = UITabBarItem(title: "충전상태", image: image, selectedImage: image)
  }

  private lazy var qrViewController: QrViewController = QrViewController().then {
    let image = UIImage(systemName: "qrcode.viewfinder")
    $0.tabBarItem = UITabBarItem(title: "QR코드", image: image, selectedImage: image)
  }

  private lazy var myPageViewController: MyPageViewController = MyPageViewController().then {
    let image = UIImage(systemName: "person")
    $0.tabBarItem = UITabBarItem(title: "마이페이지", image: image, selectedImage: image)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
    view.backgroundColor = .systemBackground
    navigationItem.titleView = UIImageView(image: .init(named: "logo.wing"))
    tabBar.standardAppearance = UITabBarAppearance().then { appearance in
      appearance.configureWithOpaqueBackground()
    }
    if #available(iOS 15.0, *) {
      tabBar.scrollEdgeAppearance = tabBar.standardAppearance
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewControllers = [homeViewController, stateViewController, qrViewController, myPageViewController]
  }

}

extension MainViewController: UITabBarControllerDelegate {

  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    switch viewController {
    case is QrViewController:
      let realm = try! Realm()

      guard let user = realm.objects(UserStore.self).first else {
        return false
      }

      if !user.token.isEmpty {
        WSNetwork.request(target: .chargeUserCheck(token: user.token)) { [weak self] result in
          switch result {
          case .success(let json):
            if let result = json["result"].bool,
               result {
              self?.present(QrViewController().then {
                $0.modalPresentationStyle = .fullScreen
              }, animated: true)
            } else {
              let errorCode = json["code"].int ?? -1
              let title: String = "QR코드 에러"
              let message: String

              switch errorCode {
              case 801:
                message = "충전규격이 등록되지 않았습니다. 충전규격을 등록해주세요."
              default:
                message = "알 수 없는 오류가 발생하였습니다."
              }
              self?.alert(title: title, message: message, style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel)])
            }
          case .failure:
            self?.alert(title: "QR코드 에러", message: "네트워크 상태를 다시 한 번 확인해주십시오.", style: .alert, actions: [UIAlertAction(title: "확인", style: .cancel)])
          }
        }
      } else {
        self.alert(title: "회원가입이 필요합니다",
                   message: "회원가입 후 이용 가능한 서비스입니다. 가입을 진행하시겠습니까?",
                   style: .alert,
                   actions: [
                    UIAlertAction(title: "가입할래요", style: .default, handler: { [weak self] _ in
                      self?.present(UINavigationController(rootViewController: SignUpPhoneViewController()).then {
                        $0.modalPresentationStyle = .fullScreen
                      }, animated: true)
                    }),
                    UIAlertAction(title: "나중에 할래요", style: .cancel)
                   ])
      }

      return false
    default:
      return true
    }
  }

}
