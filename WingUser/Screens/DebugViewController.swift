//
//  DebugViewController.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/04.
//

import UIKit

struct ViewControllerInformation {
  let title: String
  let subtitle: String?
  let viewController: UIViewController

  init(title: String = "", subtitle: String? = nil, viewController: UIViewController) {
    self.title = title
    self.subtitle = subtitle
    self.viewController = viewController
  }
}

class DebugViewController: UITableViewController {

  private let viewControllerStorage: [ViewControllerInformation] = [
    .init(title: "MainViewController", subtitle: "홈 화면", viewController: MainViewController()),
    .init(title: "SignUpPhoneViewController", subtitle: "회원가입-휴대폰 번호 입력", viewController: SignUpPhoneViewController()),
    .init(title: "SignUpVerifyViewController", subtitle: "회원가입-인증번호 입력", viewController: SignUpVerifyViewController()),
    .init(title: "SignUpPolicyViewController", subtitle: "회원가입-약관동의", viewController: SignUpPolicyViewController()),
    .init(title: "SignUpRequiredViewController", subtitle: "회원가입-개인정보 입력", viewController: SignUpRequiredViewController()),
    .init(title: "SignUpPortRegisterViewController", subtitle: "회원가입-충전포트 등록", viewController: SignUpPortRegisterViewController()),
    .init(title: "SignUpPortStandardViewController", subtitle: "회원가입-충전규격 등록", viewController: SignUpPortStandardViewController()),
    .init(title: "SignUpWhereStandardViewController", subtitle: "회원가입-충전규격 확인 위치", viewController: SignUpWhereStandardViewController()),
    .init(title: "AddressSearchViewController", subtitle: "주소검색", viewController: AddressSearchViewController()),
    .init(title: "ChargeCheckViewController", subtitle: "충전기기 확인", viewController: ChargeCheckViewController()),
    .init(title: "ChargeProcessViewController", subtitle: "충전진행", viewController: ChargeProcessViewController()),
    .init(title: "BillViewController", subtitle: "결제지", viewController: BillViewController()),
    .init(title: "ChargeNotDefinedViewController", subtitle: "충전규격 등록", viewController: ChargeNotDefinedViewController()),
    .init(title: "CardModifyViewController", subtitle: "카드등록/변경", viewController: CardModifyViewController()),
    .init(title: "NoticeListViewController", subtitle: "공지사항 리스트", viewController: NoticeListViewController()),
    .init(title: "NoticeContentViewController", subtitle: "공지사항 내용", viewController: NoticeContentViewController()),
    .init(title: "StationPortListViewController", subtitle: "스테이션 포트 리스트", viewController: StationPortListViewController()),
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "Debug Area"
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewControllerStorage.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let viewInformation = viewControllerStorage[indexPath.row]

    return UITableViewCell(style: .subtitle, reuseIdentifier: nil).then { cell in
      if #available(iOS 14.0, *) {
        cell.contentConfiguration = cell.defaultContentConfiguration().with { configuration in
          configuration.text = viewInformation.title
          configuration.secondaryText = viewInformation.subtitle
        }
      } else {
        cell.textLabel?.text = viewInformation.title
        cell.detailTextLabel?.text = viewInformation.subtitle
      }
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let viewInformation = viewControllerStorage[indexPath.row]

    tableView.deselectRow(at: indexPath, animated: true)
    navigationController?.pushViewController(viewInformation.viewController, animated: true)
  }
  
}
