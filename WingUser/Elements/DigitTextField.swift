//
//  DigitTextField.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/10.
//

import UIKit

class DigitTextField: UIView {

  var textfield: UITextField!

  private var captionLabel: UILabel!

  var caption: String? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  init(
    caption: String? = nil,
    placeholder: String? = nil,
    keyboardType: UIKeyboardType = .decimalPad
  ) {
    super.init(frame: .zero)

    commonInit()
    self.caption = caption
    self.textfield.placeholder = placeholder
    self.textfield.keyboardType = keyboardType
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    textfield = UITextField().then {
      $0.font = .systemFont(ofSize: 20.0)
      $0.borderStyle = .none
      $0.textAlignment = .right
    }
    captionLabel = UILabel()

    addSubview(textfield)
    addSubview(captionLabel)

    backgroundColor = .systemGray5
    layer.cornerRadius = 5.0
    layer.masksToBounds = true
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateTextField()
    updateCaptionLabel()
    updatePin()
  }

  private func updateTextField() {

  }

  private func updateCaptionLabel() {
    captionLabel.attributedText = "<gray1><s14>\(caption ?? "")</s14></gray1>".wsAttributed
  }

  private func updatePin() {
    captionLabel.pin.centerEnd(12).sizeToFit()
    textfield.pin
      .centerStart()
      .end(to: captionLabel.edge.start)
      .marginHorizontal(12)
      .sizeToFit(.width)

    invalidateIntrinsicContentSize()
  }

  override var intrinsicContentSize: CGSize {
    let padding: CGFloat = 20.0

    return .init(width: bounds.width, height: textfield.bounds.height + padding)
  }

}
