//
//  CapsuleLabel.swift
//  WingUser
//
//  Created by 차상호 on 2021/11/16.
//

import UIKit

class CapsuleLabel: UIView {

  private var mainLabel: UILabel!

  private let horizontalPadding: CGFloat

  private let verticalPadding: CGFloat

  var text: String? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  var labelColor: UIColor? = nil {
    didSet {
      setNeedsLayout()
    }
  }

  override var backgroundColor: UIColor? {
    didSet {
      setNeedsLayout()
    }
  }

  init(
    text labelText: String? = nil,
    backgroundColor color: UIColor? = nil,
    labelColor: UIColor? = nil,
    vPadding verticalPadding: CGFloat = 10.0,
    hPadding horizontalPadding: CGFloat = 22.0
  ) {
    self.verticalPadding = verticalPadding
    self.horizontalPadding = horizontalPadding

    super.init(frame: .zero)

    commonInit()
    self.text = labelText
    self.labelColor = labelColor
    self.backgroundColor = color
  }

  required init?(coder: NSCoder) {
    fatalError("NOT IMPL")
  }

  private func commonInit() {
    mainLabel = UILabel().then {
      $0.font = .boldSystemFont(ofSize: 14)
    }

    addSubview(mainLabel)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    updateContentView()
    updateMainLabel()
    updatePin()
  }

  private func updateContentView() {
    layer.backgroundColor = backgroundColor?.cgColor
    layer.cornerRadius = bounds.height / 2
    layer.masksToBounds = true
  }

  private func updateMainLabel() {
    mainLabel.text = text
    mainLabel.textColor = labelColor
  }

  private func updatePin() {
    mainLabel.pin.center().sizeToFit()

    invalidateIntrinsicContentSize()
  }

  override var intrinsicContentSize: CGSize {
    .init(width: mainLabel.bounds.width + (horizontalPadding * 2),
          height: mainLabel.bounds.height + (verticalPadding * 2))
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    updatePin()

    return intrinsicContentSize
  }

}
