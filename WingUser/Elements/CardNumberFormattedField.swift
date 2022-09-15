//
//  CardNumberFormattedField.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/09.
//

import UIKit

class CardNumberFormattedField: UIView {

  private var cardNumberTextFields: [UITextField]!

  private var separatorLabels: [UILabel]!

  private var containerView: UIView!

  private let separator = "-"

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

    cardNumberTextFields = .init(count: 4, element: UITextField().then {
      $0.placeholder = "0000"
      $0.font = .monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .regular)
      $0.textAlignment = .center
      $0.borderStyle = .none
      $0.keyboardType = .numberPad
    })
    separatorLabels = .init(count: cardNumberTextFields.count - 1, element: UILabel().then {
      $0.text = separator
      $0.textAlignment = .center
      $0.textColor = .systemGray4
    })

    cardNumberTextFields.forEach { textfield in
      containerView.addSubview(textfield)
    }
    separatorLabels.forEach { label in
      containerView.addSubview(label)
    }

    backgroundColor = .secondarySystemBackground
    layer.cornerRadius = 5.0
    layer.masksToBounds = true

    cardNumberTextFields.forEach { textfield in
      textfield.rx
        .text.orEmpty
        .distinctUntilChanged()
        .map { $0.count > 3 }
        .subscribe(onNext: { [weak self] in
          if $0 {
            textfield.text = String(textfield.text?.prefix(4) ?? "")
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
    let cardNumberTextFieldWidthRatio = (100 / cardNumberTextFields.count)%

    cardNumberTextFields.enumerated().forEach { index, textfield in
      switch index {
      case 0:
        textfield.pin
          .start()
          .vCenter()
          .width(cardNumberTextFieldWidthRatio)
          .sizeToFit(.width)
      default:
        textfield.pin
          .after(of: cardNumberTextFields[index - 1], aligned: .center)
          .width(cardNumberTextFieldWidthRatio)
          .sizeToFit(.width)
      }
    }
    separatorLabels.enumerated().forEach { index, label in
      label.pin.center(to: cardNumberTextFields[index].anchor.centerEnd).sizeToFit()
    }

    invalidateIntrinsicContentSize()
  }

  override var intrinsicContentSize: CGSize {
    let padding: CGFloat = 25.0

    guard let textfieldHeight = cardNumberTextFields.first?.bounds.height else {
      return .init(width: bounds.width, height: bounds.height)
    }

    return .init(width: bounds.width, height: textfieldHeight + padding)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    updatePin()
    return intrinsicContentSize
  }

  func cardNumber() -> String {
    let first = cardNumberTextFields[0].text?.padding(toLength: 4, withPad: "0", startingAt: 0) ?? "0000"
    let second = cardNumberTextFields[1].text?.padding(toLength: 4, withPad: "0", startingAt: 0) ?? "0000"
    let third = cardNumberTextFields[2].text?.padding(toLength: 4, withPad: "0", startingAt: 0) ?? "0000"
    let fourth = cardNumberTextFields[3].text?.padding(toLength: 4, withPad: "0", startingAt: 0) ?? "0000"

    return "\(first) \(second) \(third) \(fourth)"
  }

}
