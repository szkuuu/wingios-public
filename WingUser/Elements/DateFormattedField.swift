//
//  DateFormattedField.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/09.
//

import UIKit

class DateFormattedField: UIView {

  private var dateTextFields: [UITextField]!

  private var separatorLabels: [UILabel]!

  private var containerView: UIView!

  private let separator = "/"

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

    dateTextFields = .init().with {
      $0.append(UITextField().then {
        $0.placeholder = "MM"
        $0.font = .monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        $0.textAlignment = .center
        $0.borderStyle = .none
        $0.keyboardType = .numberPad
      })
      $0.append(UITextField().then {
        $0.placeholder = "YY"
        $0.font = .monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        $0.textAlignment = .center
        $0.borderStyle = .none
        $0.keyboardType = .numberPad
      })
    }
    separatorLabels = .init(count: dateTextFields.count - 1, element: UILabel().then {
      $0.text = separator
      $0.textAlignment = .center
      $0.textColor = .systemGray4
    })

    dateTextFields.forEach { textfield in
      containerView.addSubview(textfield)
    }
    separatorLabels.forEach { label in
      containerView.addSubview(label)
    }

    backgroundColor = .secondarySystemBackground
    layer.cornerRadius = 5.0
    layer.masksToBounds = true

    dateTextFields.forEach { textfield in
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
    let dateTextFieldWidthRatio = (100 / dateTextFields.count)%

    dateTextFields.enumerated().forEach { index, textfield in
      switch index {
      case 0:
        textfield.pin
          .start()
          .vCenter()
          .width(dateTextFieldWidthRatio)
          .sizeToFit(.width)
      default:
        textfield.pin
          .after(of: dateTextFields[index - 1], aligned: .center)
          .width(dateTextFieldWidthRatio)
          .sizeToFit(.width)
      }
    }
    separatorLabels.enumerated().forEach { index, label in
      label.pin.center(to: dateTextFields[index].anchor.centerEnd).sizeToFit()
    }

    invalidateIntrinsicContentSize()
  }

  override var intrinsicContentSize: CGSize {
    let padding: CGFloat = 25.0

    guard let textfieldHeight = dateTextFields.first?.bounds.height else {
      return .init(width: bounds.width, height: bounds.height)
    }

    return .init(width: bounds.width, height: textfieldHeight + padding)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    updatePin()
    return intrinsicContentSize
  }

  func validDate() -> (month: String, year: String) {
    if let month = dateTextFields[0].text, let year = dateTextFields[1].text {
      return (month, year)
    } else {
      return ("", "")
    }
  }

}
