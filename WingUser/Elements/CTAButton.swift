//
//  CTAButton.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/04.
//

import UIKit

class CTAButton: UIControl {

  enum Condition {

    case normal

    case inactive

    case option(lightForced: Bool)

    case label(focused: Bool)

  }

  struct Appearance {

    let backgroundColor: UIColor

    let layerBorderWidth: CGFloat

    let layerBorderColor: CGColor?

    let textLabelTextColor: UIColor

    let shadowOpacity: Float

    init(backgroundColor: UIColor, textColor: UIColor, borderWidth: CGFloat = 0.0, borderColor: UIColor? = nil, shadowVisible: Bool = false) {
      self.backgroundColor = backgroundColor
      self.layerBorderWidth = borderWidth
      self.layerBorderColor = borderColor?.cgColor
      self.textLabelTextColor = textColor
      self.shadowOpacity = shadowVisible ? 0.1 : 0.0
    }

  }

  private var capacitor: Bool

  var textLabel: UILabel!

  var condition: CTAButton.Condition? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  init(
    text: String? = nil,
    lock: Bool? = nil,
    condition: CTAButton.Condition? = nil
  ) {
    self.capacitor = lock ?? false
    super.init(frame: .zero)

    commonInit()
    self.textLabel.text = text ?? ""
    self.condition = condition ?? .inactive
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    textLabel = UILabel().then { label in
      label.font = .systemFont(ofSize: 16.0, weight: .semibold)
    }
    addSubview(textLabel)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    guard let condition = condition else {
      return
    }
    let appearance = condition.appearance()

    updateContentView(appearance)
    updateTextLabel(appearance)
    updatePin()
  }

  private func updateContentView(_ appearance: CTAButton.Appearance) {
    backgroundColor = appearance.backgroundColor
    layer.borderColor = appearance.layerBorderColor
    layer.borderWidth = appearance.layerBorderWidth

    layer.shadowOffset = .init(width: 3, height: 3)
    layer.shadowRadius = 6
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = appearance.shadowOpacity

    layer.cornerRadius = frame.height / 2
  }

  private func updateTextLabel(_ appearance: CTAButton.Appearance) {
    textLabel.textColor = appearance.textLabelTextColor
  }

  private func updatePin() {
    textLabel.pin.center().sizeToFit()

    invalidateIntrinsicContentSize()
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    updatePin()

    return intrinsicContentSize
  }

  override var intrinsicContentSize: CGSize {
    let defaultVerticalPadding: CGFloat = 8.0
    let defaultHorizontalPadding: CGFloat = 12.0

    return .init(width: textLabel.bounds.width + (defaultHorizontalPadding * 2),
                 height: textLabel.bounds.height + (defaultVerticalPadding * 2))
  }

}

extension CTAButton.Condition {

  func appearance() -> CTAButton.Appearance {
    switch self {
    case .normal:
      return .init(backgroundColor: .systemYellow, textColor: .black)
    case .inactive:
      return .init(backgroundColor: .systemGray3, textColor: .white)
    case .option(let forced):
      if forced {
        return .init(backgroundColor: .clear, textColor: .black, borderWidth: 1.0, borderColor: .black)
      } else {
        return .init(backgroundColor: .clear, textColor: .label, borderWidth: 1.0, borderColor: .label)
      }
    case .label(let focused):
      return focused ?
        .init(backgroundColor: .systemBlue, textColor: .systemBackground, shadowVisible: true)
      : .init(backgroundColor: .systemBackground, textColor: .systemBlue, shadowVisible: true)
    }
  }

}
