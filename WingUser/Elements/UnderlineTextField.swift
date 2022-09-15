//
//  UnderlineTextField.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/05.
//

import UIKit

class UnderlineTextField: UIView {

  enum Condition {

    case focusIn

    case focusOut

  }

  struct Appearance {

    let underlineColor: CGColor

    init(lineColor: UIColor) {
      self.underlineColor = lineColor.cgColor
    }

  }

  var textField: UITextField!

  private var condition: UnderlineTextField.Condition? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  private var lineLayer: CAShapeLayer!

  private let lineMargin: CGFloat = 8.0

  private let lineWidth: CGFloat = 1.0

  init(
    placeholder: String? = nil,
    clearButtonMode: UITextField.ViewMode = .whileEditing,
    keyboardType type: UIKeyboardType = .default
  ) {
    super.init(frame: .zero)

    commonInit()
    textField.placeholder = placeholder
    textField.clearButtonMode = clearButtonMode
    textField.keyboardType = type
    condition = self.condition ?? .focusOut
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    textField = UITextField().then {
      $0.borderStyle = .none
    }
    lineLayer = CAShapeLayer().then {
      $0.fillColor = UIColor.clear.cgColor
      $0.lineWidth = lineWidth
    }
    addSubview(textField)
    layer.addSublayer(lineLayer)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    guard let condition = condition else {
      return
    }
    let appearance = condition.appearance()

    updateTextField()
    updateLineLayer(appearance)
    updatePin()
  }

  private func updateTextField() {
  }

  private func updateLineLayer(_ appearance: UnderlineTextField.Appearance) {
    lineLayer.do { layer in
      layer.path = UIBezierPath().then { path in
        path.move(to: .zero)
        path.addLine(to: .init(x: bounds.width, y: .zero))
      }.cgPath
      layer.strokeColor = appearance.underlineColor
    }
  }

  private func updatePin() {
    textField.pin.top(lineMargin).start().end().sizeToFit(.width)
    lineLayer.pin.bottom().start().end()
  }

  override var intrinsicContentSize: CGSize {
    return .init(width: bounds.width, height: textField.intrinsicContentSize.height + (lineMargin * 2) + lineWidth)
  }

}

extension UnderlineTextField.Condition {

  func appearance() -> UnderlineTextField.Appearance {
    switch self {
    case .focusIn:
      return .init(lineColor: .systemYellow)
    case .focusOut:
      return .init(lineColor: .systemGray2)
    }
  }

}
