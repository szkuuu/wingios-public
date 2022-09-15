//
//  UIViewController+Alert.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/23.
//

extension UIViewController {

  func alert(title: String? = nil,
             message: String? = nil,
             style preferredStyle: UIAlertController.Style,
             actions: [UIAlertAction],
             after completionHandler: (() -> Void)? = nil) {
    let alertViewController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: preferredStyle).then { avc in
      precondition(!actions.isEmpty, "actions parameter must contain some actions")

      actions.forEach { action in
        avc.addAction(action)
      }
    }

    self.present(alertViewController, animated: true, completion: completionHandler)
  }

}
