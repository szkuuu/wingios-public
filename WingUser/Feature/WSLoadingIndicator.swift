//
//  WSLoadingIndicator.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/26.
//

/// Wing Application 글로벌 로딩 인디케이터 뷰
class WSLoadingIndicator {

  /// `UIActivityIndicatorView` 를 `UIWindow` 최상단에 배치합니다.
  static func startLoad() {
    DispatchQueue.main.async {
      guard let window = UIApplication.shared.connectedScenes
              .filter({ $0.activationState == .foregroundActive })
              .first(where: { $0 is UIWindowScene })
              .flatMap({ $0 as? UIWindowScene })?.windows
              .first(where: \.isKeyWindow) else {
        return
      }

      let loadingIndicatorView: UIActivityIndicatorView
      if let existedView = window.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
        loadingIndicatorView = existedView
      } else {
        loadingIndicatorView = UIActivityIndicatorView(style: .large).then {
          $0.frame = window.frame
          $0.hidesWhenStopped = true
        }
        window.addSubview(loadingIndicatorView)
      }

      loadingIndicatorView.startAnimating()
    }
  }

  /// `UIActivityIndicatorView` 를 `UIWindow` 으로부터 제거합니다.
  static func stopLoad() {
    DispatchQueue.main.async {
      guard let window = UIApplication.shared.connectedScenes
              .filter({ $0.activationState == .foregroundActive })
              .first(where: { $0 is UIWindowScene })
              .flatMap({ $0 as? UIWindowScene })?.windows
              .first(where: \.isKeyWindow) else {
        return
      }

      window.subviews.filter { $0 is UIActivityIndicatorView }.map { $0 as? UIActivityIndicatorView }.forEach {
        $0?.stopAnimating()
        $0?.removeFromSuperview()
      }
    }
  }

}
