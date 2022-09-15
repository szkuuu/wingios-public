//
//  PasswordFormattedField.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/09.
//

import UIKit

class PasswordFormattedField: UIView {

  private var passwordTextFields: [UITextField]!

  private var containerView: UIView!

  override init(frame: CGRect) {
    super.init(frame: frame)

    commonInit()
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    containerView = UIView()
    addSubview(containerView)

    passwordTextFields = .init(count: 1, element: UITextField().then {
      $0.placeholder = "**"
      $0.font = .monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .regular)
      $0.textAlignment = .center
      $0.borderStyle = .none
      $0.keyboardType = .numberPad
      $0.isSecureTextEntry = true
    })

    passwordTextFields.forEach { textfield in
      containerView.addSubview(textfield)
    }

    backgroundColor = .secondarySystemBackground
    layer.cornerRadius = 5.0
    layer.masksToBounds = true

    passwordTextFields.forEach { textfield in
      textfield.rx
        .text.orEmpty
        .distinctUntilChanged()
        .map { $0.count > 1 }
        .subscribe(onNext: { [weak self] in
          if $0 {
            textfield.text = String(textfield.text?.prefix(2) ?? "")
            self?.endEditing(true)
          }
        }).disposed(by: rx.disposeBag)
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updatePin()
  }

  private func updatePin() {
    containerView.pin.all()
    let passwordTextFieldWidthRatio = (100 / passwordTextFields.count)%

    passwordTextFields.enumerated().forEach { index, textfield in
      switch index {
      case 0:
        textfield.pin
          .start()
          .vCenter()
          .width(passwordTextFieldWidthRatio)
          .sizeToFit(.width)
      default:
        textfield.pin
          .after(of: passwordTextFields[index - 1], aligned: .center)
          .width(passwordTextFieldWidthRatio)
          .sizeToFit(.width)
      }
    }

    invalidateIntrinsicContentSize()
  }

  override var intrinsicContentSize: CGSize {
    let padding: CGFloat = 25.0

    guard let textfieldHeight = passwordTextFields.first?.bounds.height else {
      return .init(width: bounds.width, height: bounds.height)
    }

    return .init(width: bounds.width, height: textfieldHeight + padding)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    updatePin()
    return intrinsicContentSize
  }

  func password() -> String {
    guard let password = passwordTextFields.first?.text else {
      return ""
    }

    return password
  }

}
